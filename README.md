# dotfiles

macOS 開発環境セットアップ用 dotfiles

## クイックスタート

```bash
# 1. クローン
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles

# 2. インストール
cd ~/.dotfiles
chmod +x install.sh
./install.sh

# 3. SSH 設定
chmod +x ssh/setup.sh
./ssh/setup.sh

# 4. Git 設定
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## 含まれる設定

| ツール | ファイル |
|--------|----------|
| zsh | `.zshrc` |
| Starship | `.config/starship.toml` |
| Ghostty | `.config/ghostty/config` |
| Git | `.gitconfig` |
| Cursor | `settings.json`, `keybindings.json` |
| Claude Code | `settings.json`, `CLAUDE.md`, `commands/commit-push.md` |

## 手動インストール

- Dropbox
- 1Password
- Spark
- Xcode

## Karabiner-Elements 設定

Simple Modifications:
- `英数` → `left_command`
- `かな` → `right_command`
- `¥` → `\`

Complex Modifications:
- コマンドキー単体で押した時に、英数/かなキーを送信
- JIS to US

## ローカル設定

`~/.zshrc.local` に API キーなどを記述（git 管理外）
