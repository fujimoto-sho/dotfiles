#!/bin/bash
#
# review-loop.sh - Claude CodeとCodexを連携したレビューサイクル
#
# 使い方:
#   review-loop.sh "実装タスクの説明"
#   review-loop.sh --max-iterations 3 "実装タスクの説明"
#   review-loop.sh --files "src/main.ts" "バグ修正"
#
# 動作:
#   1. Claude Codeで実装/修正
#   2. Codexでレビュー
#   3. 問題がなければ終了、あれば修正してループ（最大N回）
#

set -euo pipefail

# デフォルト設定
MAX_ITERATIONS=5
TARGET_FILES=""
TASK=""
REVIEW_LOG_DIR="${HOME}/.local/share/review-loop"
VERBOSE=false

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] "タスクの説明"

Claude CodeとCodexを連携したレビューサイクルを実行します。

Options:
  -m, --max-iterations N   最大繰り返し回数 (デフォルト: 5)
  -f, --files FILES        対象ファイル（カンマ区切り）
  -v, --verbose            詳細な出力
  -h, --help               このヘルプを表示

Examples:
  $(basename "$0") "ユーザー認証機能を実装"
  $(basename "$0") -m 3 "バグ修正: ログインエラー"
  $(basename "$0") -f "src/auth.ts,src/user.ts" "認証ロジックのリファクタリング"

EOF
    exit 0
}

# 引数パース
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        -f|--files)
            TARGET_FILES="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            ;;
        *)
            TASK="$1"
            shift
            ;;
    esac
done

# タスク必須チェック
if [[ -z "$TASK" ]]; then
    log_error "タスクの説明が必要です"
    show_help
fi

# ログディレクトリ作成
mkdir -p "$REVIEW_LOG_DIR"
SESSION_ID=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="${REVIEW_LOG_DIR}/${SESSION_ID}"
mkdir -p "$SESSION_LOG_DIR"

log_info "セッションID: ${SESSION_ID}"
log_info "ログディレクトリ: ${SESSION_LOG_DIR}"

# レビュー結果を解析してLGTMかどうか判定
is_lgtm() {
    local review_output="$1"

    # LGTMパターンをチェック（大文字小文字を無視）
    if echo "$review_output" | grep -iE "(lgtm|looks good|no issues|問題なし|問題ありません)" > /dev/null; then
        return 0
    fi

    # 重大な問題がないかチェック
    if echo "$review_output" | grep -iE "(critical|error|bug|security|セキュリティ|バグ|エラー|修正が必要)" > /dev/null; then
        return 1
    fi

    # 軽微な指摘のみの場合もLGTMとみなす
    if echo "$review_output" | grep -iE "(minor|suggestion|考慮|提案)" > /dev/null; then
        if ! echo "$review_output" | grep -iE "(must|should|required|必須)" > /dev/null; then
            return 0
        fi
    fi

    return 1
}

# メインループ
iteration=1
while [[ $iteration -le $MAX_ITERATIONS ]]; do
    echo ""
    log_info "=========================================="
    log_info "イテレーション ${iteration}/${MAX_ITERATIONS}"
    log_info "=========================================="

    # Claude Codeで実装/修正
    log_info "Claude Codeで実装中..."

    CLAUDE_PROMPT="$TASK"
    if [[ $iteration -gt 1 && -f "${SESSION_LOG_DIR}/review_${iteration-1}.txt" ]]; then
        REVIEW_FEEDBACK=$(cat "${SESSION_LOG_DIR}/review_$((iteration-1)).txt")
        CLAUDE_PROMPT="以下のレビュー指摘を修正してください:\n\n${REVIEW_FEEDBACK}\n\n元のタスク: ${TASK}"
    fi

    if [[ -n "$TARGET_FILES" ]]; then
        CLAUDE_PROMPT="${CLAUDE_PROMPT}\n\n対象ファイル: ${TARGET_FILES}"
    fi

    # Claude Code実行（非インタラクティブモード）
    CLAUDE_OUTPUT_FILE="${SESSION_LOG_DIR}/claude_${iteration}.txt"

    if $VERBOSE; then
        echo -e "$CLAUDE_PROMPT" | claude -p 2>&1 | tee "$CLAUDE_OUTPUT_FILE"
    else
        echo -e "$CLAUDE_PROMPT" | claude -p > "$CLAUDE_OUTPUT_FILE" 2>&1
    fi

    CLAUDE_EXIT_CODE=$?

    if [[ $CLAUDE_EXIT_CODE -ne 0 ]]; then
        log_error "Claude Codeの実行に失敗しました (exit code: ${CLAUDE_EXIT_CODE})"
        cat "$CLAUDE_OUTPUT_FILE"
        exit 1
    fi

    log_success "Claude Codeの実装完了"

    # 変更があるか確認
    if ! git diff --quiet 2>/dev/null && ! git diff --cached --quiet 2>/dev/null; then
        log_info "変更を検出しました"
    else
        if git status --porcelain | grep -q '^??'; then
            log_info "新規ファイルを検出しました"
        else
            log_warn "変更が検出されませんでした"
            if [[ $iteration -eq 1 ]]; then
                log_error "初回で変更がないため終了します"
                exit 1
            fi
            log_success "修正完了（変更なし）"
            break
        fi
    fi

    # Codexでレビュー
    log_info "Codexでレビュー中..."

    REVIEW_OUTPUT_FILE="${SESSION_LOG_DIR}/review_${iteration}.txt"

    if $VERBOSE; then
        codex review --uncommitted "コードをレビューしてください。問題がなければ「LGTM」と回答してください。問題があれば具体的な修正点を指摘してください。" 2>&1 | tee "$REVIEW_OUTPUT_FILE"
    else
        codex review --uncommitted "コードをレビューしてください。問題がなければ「LGTM」と回答してください。問題があれば具体的な修正点を指摘してください。" > "$REVIEW_OUTPUT_FILE" 2>&1
    fi

    CODEX_EXIT_CODE=$?

    if [[ $CODEX_EXIT_CODE -ne 0 ]]; then
        log_warn "Codexの実行でエラーが発生しました (exit code: ${CODEX_EXIT_CODE})"
        cat "$REVIEW_OUTPUT_FILE"
    fi

    REVIEW_CONTENT=$(cat "$REVIEW_OUTPUT_FILE")

    log_info "レビュー結果:"
    echo "----------------------------------------"
    cat "$REVIEW_OUTPUT_FILE"
    echo "----------------------------------------"

    # LGTMかどうか判定
    if is_lgtm "$REVIEW_CONTENT"; then
        log_success "レビューがLGTMと判定されました！"
        break
    fi

    if [[ $iteration -eq $MAX_ITERATIONS ]]; then
        log_warn "最大イテレーション回数に達しました"
        log_warn "最終レビュー結果は ${REVIEW_OUTPUT_FILE} を確認してください"
        break
    fi

    log_info "修正が必要です。次のイテレーションに進みます..."
    ((iteration++))
done

echo ""
log_info "=========================================="
log_info "サマリー"
log_info "=========================================="
log_info "セッションID: ${SESSION_ID}"
log_info "イテレーション回数: ${iteration}"
log_info "ログディレクトリ: ${SESSION_LOG_DIR}"

# 通知
if command -v terminal-notifier &> /dev/null; then
    terminal-notifier -title "Claude Code" -message "完了: review-loop (${iteration}回)" -sound default -activate "com.mitchellh.ghostty"
fi

log_success "完了しました"
