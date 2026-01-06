# Claude Code 設定

## 会話

- 日本語、敬語で会話

## Git

- 自動 commit/push 禁止

## データベース

- リセット系コマンドは明示的許可が必要
- マイグレーション実行前に確認
- 本番環境操作は絶対禁止

## ツール実行

- 独立したツール呼び出しは**必ず並列実行**（1 メッセージに複数ツール）

## コード変更

- **変更は依頼された範囲のみ**。関係ない箇所を触らない
- 勝手なリファクタリング・改善・コメント追加は禁止
- 「ついでに」の修正はしない。必要なら提案して確認を取る

## 利用可能な CLI ツール

- **検索**: `rg`(grep), `fd`(find)
- **表示**: `eza`(ls), `jq`(JSON)
- **API**: `http`(httpie)
- **開発**: `mise`, `pod`, `fastlane`
- **通知**: `terminal-notifier`

## 通知

- タスク完了時：
  terminal-notifier -title "Claude Code" -message "完了: [概要]" -sound default -activate "com.mitchellh.ghostty"

## 禁止

- .env 内容の出力
- rm -rf の安易な使用
- 本番環境への操作
