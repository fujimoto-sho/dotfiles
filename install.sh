#!/bin/bash
# macOS 開発環境セットアップスクリプト

set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "🚀 dotfiles インストール開始..."

# Homebrew インストール
if ! command -v brew &> /dev/null; then
  echo "📦 Homebrew をインストール中..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

brew doctor || true
brew update

# Brewfile からパッケージインストール
echo "📦 パッケージをインストール中..."
brew bundle --file="$DOTFILES_DIR/Brewfile" || true

# dotfilesをリンク
echo "🔗 dotfiles をリンク中..."
cd "$DOTFILES_DIR"

backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

files_to_backup=(
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/.config/starship.toml"
  "$HOME/.config/ghostty/config"
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  "$HOME/.claude/settings.json"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.claude/commands"
  "$HOME/.gemini/GEMINI.md"
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

stow -v zsh
stow -v starship
stow -v ghostty
stow -v git
stow -v claude
stow -v gemini

# ghostty の設定をリンク（macOS用パス）
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Cursor の設定をリンク
mkdir -p "$HOME/.config/cursor/User"
ln -sf "$DOTFILES_DIR/cursor/.config/cursor/User/settings.json" "$HOME/.config/cursor/User/settings.json"
ln -sf "$DOTFILES_DIR/cursor/.config/cursor/User/keybindings.json" "$HOME/.config/cursor/User/keybindings.json"

# stow後にfzf設定
echo "⌨️  fzf キーバインドを設定中..."
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

# mise でランタイム設定
echo "🔧 mise でランタイムを設定中..."
if command -v mise &> /dev/null; then
  mise use --global node@lts
  mise use --global python@3.13
  mise use --global java@17
fi

# Claude Code インストール
echo "🤖 Claude Code をインストール中..."
if command -v npm &> /dev/null; then
  npm install -g @anthropic-ai/claude-code
else
  echo "⚠️  npm が見つかりません。mise で Node.js をインストール後に再実行してください"
fi

# Claude Code プラグインインストール
echo "🔌 Claude Code プラグインをインストール中..."
if command -v claude &> /dev/null; then
  claude mcp add-from-claude-app || true
  claude /plugin install example-skills || true
fi

# macOS 設定を適用
echo "🍎 macOS 設定を適用中..."
source "$DOTFILES_DIR/macos.sh"

# Cursor 拡張機能インストール
echo "🔌 Cursor 拡張機能をインストール中..."
if command -v cursor &> /dev/null; then
  cursor --install-extension MS-CEINTL.vscode-language-pack-ja
  cursor --install-extension esbenp.prettier-vscode
  cursor --install-extension dbaeumer.vscode-eslint
  cursor --install-extension formulahendry.auto-rename-tag
  cursor --install-extension bradlc.vscode-tailwindcss
  cursor --install-extension pkief.material-icon-theme
  cursor --install-extension eamodio.gitlens
  cursor --install-extension usernamehw.errorlens
  cursor --install-extension streetsidesoftware.code-spell-checker
  cursor --install-extension yoavbls.pretty-ts-errors
  cursor --install-extension dsznajder.es7-react-js-snippets
fi

# raycastの実行権限
chmod +x ~/.dotfiles/raycast/script-commands/open-url-in-chrome.sh

brew cleanup || true

echo ""
echo "✅ dotfiles インストール完了！"
echo ""
echo "📝 次のステップ:"
echo "  1. ターミナルを再起動（または exec zsh）"
echo "  2. SSH 設定: cd ~/.dotfiles && ./ssh/setup.sh"
echo "  3. Git 設定: git config --global user.name 'Your Name'"
echo "  4. 手動インストール: README参照"
echo ""