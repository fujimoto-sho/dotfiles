# Claude Code プロジェクト設定（このファイルを読んで Claude Code が動作ルールを理解する）

## 環境
- macOS (Apple Silicon)
- zsh / Ghostty
- mise（ランタイム管理）

## 会話
- 常に日本語、敬語で会話すること

## Git
- `/commit-push` コマンドが実行された場合のみ commit/push する
- 「コミットして」と言われても `/commit-push` の使用を案内する
- 自動的にコミットやプッシュを行わない

## GitHub
- GitHub リソース取得は `mcp__github__` ツールを優先
- WebFetch/WebSearch より MCP を使う

## コード
- TypeScript strict
- 不要な空白は削除
- ファイル末尾に改行を入れる
- 変更後は型チェック・ビルド確認

## database
- データベースのリセット(drop, truncate, delete all, supabase db resetなど)は明示的な許可なく実行しないこと
- マイグレーションの実行前に必ず確認を取ること
- 本番環境のデータに影響を与える操作は禁止

# 通知
- タスク完了時は必ず以下を実行：
```
  terminal-notifier -title "Claude Code" -message "完了: [実行したタスクの概要]" -sound default -activate "com.mitchellh.ghostty"
```

## 禁止
- .env の内容を出力しない
- rm -rf は慎重に
- node_modules は編集しない
- /commit-push は自動で実行しない
- 本番環境に影響を与える操作は"絶対に禁止"
