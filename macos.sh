#!/bin/bash
# macOS システム設定をコマンドで変更、GUI の設定アプリを開かずに一括設定

# キーを押してからリピート開始までの時間、12 は約 180ms（システム設定より速い）
defaults write -g InitialKeyRepeat -int 12
# キーリピート間隔、2 は約 30ms（最速レベル）
defaults write -g KeyRepeat -int 2

# トラックパッドのカーソル移動速度を 1.5 倍に（0.0〜3.0、デフォルトは 1.0）
defaults write -g com.apple.trackpad.scaling -float 1.5

# App Exposé を有効化（3本指で下スワイプで同じアプリの全ウィンドウを一覧表示）
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Mission Control でデスクトップの自動並び替えを無効化（ウィンドウの位置が勝手に変わるのを防ぐ）
defaults write com.apple.dock mru-spaces -bool false

# Dock を再起動して設定を反映
killall Dock

echo "✅ macOS 設定完了（キーリピートは再ログイン後に反映）"
