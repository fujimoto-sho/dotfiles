#!/bin/bash
# macOS 開発環境セットアップスクリプト、新しい Mac で実行すると Homebrew から各種ツールまで一括インストール

set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "🚀 dotfiles インストール開始..."

# Homebrew インストール（macOS 用パッケージマネージャー、これがないと他のツールが入らない）
if ! command -v brew &> /dev/null; then
  echo "📦 Homebrew をインストール中..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon は /opt/homebrew、Intel は /usr/local にインストールされる
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

brew doctor || true
brew update

# Brewfile からパッケージインストール
echo "📦 パッケージをインストール中..."
brew bundle --file="$DOTFILES_DIR/Brewfile" || true

# fzf キーバインド設定（Ctrl+R で履歴検索、Ctrl+T でファイル検索が使えるようになる）
echo "⌨️  fzf キーバインドを設定中..."
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

# mise でランタイム設定（Node.js/Python のバージョン管理、nodenv/pyenv の統合版）
echo "🔧 mise でランタイムを設定中..."
if command -v mise &> /dev/null; then
  mise use --global node@lts
  mise use --global python@3.13
fi

# Claude Code インストール（ターミナルで claude コマンドが使える AI コーディングエージェント）
echo "🤖 Claude Code をインストール中..."
if command -v npm &> /dev/null; then
  npm install -g @anthropic-ai/claude-code
else
  echo "⚠️  npm が見つかりません。mise で Node.js をインストール後に再実行してください"
fi

echo "🔗 dotfiles をリンク中..."
cd "$DOTFILES_DIR"

# バックアップ先ディレクトリ（日時付きで上書き防止）
backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Stow でリンクを作成するファイル一覧
files_to_backup=(
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/.config/starship.toml"
  "$HOME/.config/ghostty/config"
  "$HOME/.claude/settings.json"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.claude/commands/commit-push.md"
)

for file in "${files_to_backup[@]}"; do
  if [[ -L "$file" ]]; then
    rm "$file"
  elif [[ -f "$file" ]]; then
    echo "  📁 バックアップ: $file"
    mkdir -p "$backup_dir/$(dirname "${file#$HOME/}")"
    mv "$file" "$backup_dir/${file#$HOME/}"
  fi
done

# Stow でシンボリックリンク作成（例: stow zsh → ~/.dotfiles/zsh/.zshrc が ~/.zshrc にリンク）
stow -v zsh
stow -v starship
stow -v ghostty
stow -v git
stow -v claude

# Cursor の設定をリンク
mkdir -p "$HOME/.config/cursor/User"
ln -sf "$DOTFILES_DIR/cursor/.config/cursor/User/settings.json" "$HOME/.config/cursor/User/settings.json"
ln -sf "$DOTFILES_DIR/cursor/.config/cursor/User/keybindings.json" "$HOME/.config/cursor/User/keybindings.json"

# macOS 設定を適用（キーリピート速度、トラックパッド速度など）
echo "🍎 macOS 設定を適用中..."
source "$DOTFILES_DIR/macos.sh"

# Cursor 拡張機能インストール
echo "🔌 Cursor 拡張機能をインストール中..."
if command -v cursor &> /dev/null; then
  # 日本語 UI
  cursor --install-extension MS-CEINTL.vscode-language-pack-ja
  # コードフォーマッター、保存時に自動整形
  cursor --install-extension esbenp.prettier-vscode
  # JavaScript/TypeScript の静的解析
  cursor --install-extension dbaeumer.vscode-eslint
  # HTML/JSX のタグ名を連動編集
  cursor --install-extension formulahendry.auto-rename-tag
  # Tailwind CSS のクラス名補完
  cursor --install-extension bradlc.vscode-tailwindcss
  # ファイルアイコンテーマ
  cursor --install-extension pkief.material-icon-theme
  # Git 履歴を可視化、各行に誰がいつ変更したか表示
  cursor --install-extension eamodio.gitlens
  # エラーを行内に直接表示
  cursor --install-extension usernamehw.errorlens
  # スペルチェッカー
  cursor --install-extension streetsidesoftware.code-spell-checker
  # TypeScript エラーを読みやすく整形
  cursor --install-extension yoavbls.pretty-ts-errors
  # React スニペット、rafce で関数コンポーネント
  cursor --install-extension dsznajder.es7-react-js-snippets
fi

brew cleanup || true

echo ""
echo "✅ dotfiles インストール完了！"
echo ""
echo "📝 次のステップ:"
echo "  1. ターミナルを再起動（または exec zsh）"
echo "  2. SSH 設定: cd ~/.dotfiles && ./ssh/setup.sh"
echo "  3. Git 設定: git config --global user.name 'Your Name'"
echo "  4. 手動インストール: Dropbox, 1Password, Spark, Xcode"
echo ""
