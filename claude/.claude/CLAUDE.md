  # Claude Code 設定

  ## 会話
  - 日本語、敬語で会話

  ## Git
  - `/commit-push` 実行時のみ commit/push
  - 自動 commit/push 禁止

  ## データベース
  - リセット系コマンドは明示的許可が必要
  - マイグレーション実行前に確認
  - 本番環境操作は絶対禁止

  ## 通知
  - タスク完了時：
    terminal-notifier -title "Claude Code" -message "完了: [概要]" -sound default -activate "com.mitchellh.ghostty"

  ## 禁止
  - .env 内容の出力
  - rm -rf の安易な使用
  - 本番環境への操作