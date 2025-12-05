#!/bin/bash
# SSH 鍵セットアップスクリプト、GitHub にパスワードなしで接続するための公開鍵認証を設定

set -e

echo "🔐 SSH 鍵を生成します..."

# SSH 鍵のコメントに使用、どのアカウント用かわかりやすくなる
read -p "GitHub のメールアドレス: " email

# Ed25519 アルゴリズムで鍵を生成（RSA より安全で高速）
ssh-keygen -t ed25519 -C "$email"

# ssh-agent（鍵を管理するデーモン）を起動
eval "$(ssh-agent -s)"
# 鍵を ssh-agent に登録、--apple-use-keychain で Mac 再起動後も有効
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# ~/.ssh/config を作成（SSH クライアントの設定）
cat > ~/.ssh/config << 'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentitiesOnly yes
EOF

# ディレクトリは所有者のみアクセス可
chmod 700 ~/.ssh
# config は所有者のみ読み書き可
chmod 600 ~/.ssh/config
# 秘密鍵は所有者のみ読み書き可（絶対に公開しない）
chmod 600 ~/.ssh/id_ed25519
# 公開鍵は誰でも読み取り可（GitHub に登録する）
chmod 644 ~/.ssh/id_ed25519.pub

# 公開鍵をクリップボードにコピー
cat ~/.ssh/id_ed25519.pub | pbcopy

echo ""
echo "✅ SSH 鍵の生成完了！"
echo "📋 公開鍵がクリップボードにコピーされました"
echo ""
echo "👉 GitHub に登録: https://github.com/settings/ssh/new"
echo "👉 接続テスト: ssh -T git@github.com"
