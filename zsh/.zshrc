# モダン .zshrc (2025)、ターミナル起動時に読み込まれるシェル設定ファイル

# 日本語環境、文字化け防止
export LANG=ja_JP.UTF-8
# git commit 等でエディタが開くときに vim を使用
export EDITOR=vim

# Homebrew パス（Apple Silicon は /opt/homebrew、Intel は /usr/local）
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# mise（Node.js/Python 等のバージョン管理、nodebrew/pyenv/rbenv を統一）
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Homebrew の補完定義を追加
if type brew &>/dev/null; then
  fpath=($(brew --prefix)/share/zsh-completions $fpath)
fi

# zsh 補完システムを初期化
autoload -Uz compinit
# -u で安全でないディレクトリの警告を抑制
compinit -u

# 小文字入力で大文字もマッチ（git → Git も補完）
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 親ディレクトリを補完候補から除外
zstyle ':completion:*' ignore-parents parent pwd ..
# 補完候補をメニュー形式で表示、矢印キーで選択可能
zstyle ':completion:*' menu select

# 履歴ファイルの場所
HISTFILE=~/.zsh_history
# メモリ上に保持する履歴数
HISTSIZE=100000
# ファイルに保存する履歴数
SAVEHIST=100000

# 複数ターミナル間で履歴を共有
setopt share_history
# 重複するコマンドは古い方を削除
setopt hist_ignore_all_dups
# スペースで始まるコマンドを履歴に残さない（秘密のコマンド用）
setopt hist_ignore_space
# 余分な空白を削除して履歴に保存
setopt hist_reduce_blanks
# コマンド実行直後に履歴に追加（終了時ではなく）
setopt inc_append_history

# 日本語ファイル名を表示可能に
setopt print_eight_bit
# ビープ音を鳴らさない
setopt no_beep
# Ctrl+S/Ctrl+Q のフロー制御を無効化
setopt no_flow_control
# Ctrl+D でシェルを終了しない
setopt ignore_eof
# コマンドラインでも # 以降をコメントとして扱う
setopt interactive_comments
# ディレクトリ名だけで cd（cd 省略可能）
setopt auto_cd
# cd 時に自動で pushd（cd - で戻れる）
setopt auto_pushd
# pushd で重複を無視
setopt pushd_ignore_dups
# 拡張グロブを有効化（^, ~, # などが使える）
setopt extended_glob
# グロブがマッチしなくてもエラーにしない
setopt nonomatch

# Emacs キーバインドを使用（Ctrl+A で行頭、Ctrl+E で行末など）
bindkey -e

autoload -Uz select-word-style
select-word-style default
# 単語の区切り文字を指定
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# ↑キーで履歴を前方検索（入力中の文字でフィルタ）
bindkey "^[[A" history-beginning-search-backward
# ↓キーで履歴を後方検索
bindkey "^[[B" history-beginning-search-forward

# ¥入力時に自動で \ に変換（JIS キーボード対応）
bindkey -s '¥' '\\'

# Ctrl+J で改行を入力
bindkey '^J' self-insert

# fzf のキーバインドと補完を有効化（Ctrl+R で履歴検索、Ctrl+T でファイル検索）
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

# fzf のカラー設定（Tokyo Night テーマ）
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
'

# fzf のファイル検索に fd を使用（.gitignore を尊重、高速）
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# zoxide（cd の代替、z foo で過去に行った foo を含むディレクトリにジャンプ）
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Starship プロンプト（Git ブランチ、Node バージョン等を表示するカスタムプロンプト）
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# zsh を再読み込み
alias reload='exec zsh -l'
# 画面クリア
alias c='clear'

# 削除前に確認（誤削除防止）
alias rm='rm -i'
# コピー前に確認（上書き防止）
alias cp='cp -i'
# 移動前に確認（上書き防止）
alias mv='mv -i'
# 親ディレクトリも一緒に作成
alias mkdir='mkdir -p'

# sudo の後のエイリアスも展開（sudo ll が使える）
alias sudo='sudo '

# ls をアイコン付きの eza に置き換え（インストールされている場合）
if command -v eza &> /dev/null; then
  alias ls='eza --icons'
  # 隠しファイル含む
  alias la='eza -a --icons'
  # 詳細表示 + Git status
  alias ll='eza -l --icons --git'
  # 詳細 + 隠しファイル + Git status
  alias lla='eza -la --icons --git'
  # ツリー表示（2階層まで）
  alias lt='eza --tree --icons --level=2'
else
  # フォールバック（macOS 標準）
  alias ls='ls -G -F'
  alias la='ls -a'
  alias ll='ls -l'
fi

# cat をシンタックスハイライト付きの bat に置き換え
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
  # ページング付き（長いファイル用）
  alias catp='bat'
fi

# grep を高速な ripgrep に置き換え
if command -v rg &> /dev/null; then
  alias grep='rg'
fi

# find をシンプルな fd に置き換え
if command -v fd &> /dev/null; then
  alias find='fd'
fi

# 出力をページャで表示（例: cat file L）
alias -g L='| less'
# 出力を grep でフィルタ（例: ps aux G node）
alias -g G='| grep'
# 先頭だけ表示（例: ls H）
alias -g H='| head'
# 末尾だけ表示（例: ls T）
alias -g T='| tail'
# JSON を整形（例: curl api J）
alias -g J='| jq .'
# fzf で選択（例: ls F）
alias -g F='| fzf'

# macOS 用クリップボード操作
if [[ "$OSTYPE" == darwin* ]]; then
  # 出力をクリップボードにコピー（例: cat file C）
  alias -g C='| pbcopy'
  # クリップボードの内容を貼り付け
  alias -g P='pbpaste'
else
  alias -g C='| xsel --clipboard --input'
  alias -g P='xsel --clipboard --output'
fi

# Git エイリアス
alias g='git'
alias ga='git add'
# 全ファイルをステージング
alias gaa='git add --all'
# コミット（メッセージ付き）
alias gc='git commit -m'
# 直前のコミットを修正
alias gca='git commit --amend'
# 差分表示
alias gd='git diff'
# ステージ済みの差分
alias gds='git diff --staged'
# 短縮形式でステータス表示
alias gs='git status -sb'
alias gp='git push'
# 安全な強制プッシュ
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gb='git branch'
# リモートブランチも表示
alias gba='git branch -a'
alias gco='git checkout'
# ブランチ切り替え（新コマンド）
alias gsw='git switch'
# 新ブランチ作成して切り替え
alias gsc='git switch -c'
# 直近 20 件を 1 行ずつ表示
alias gl='git log --oneline -20'
# グラフ形式で全ブランチ表示
alias glog='git log --graph --oneline --all'
# 全リモートから取得、削除されたブランチを掃除
alias gf='git fetch --all --prune'
# 変更を一時退避
alias gst='git stash'
# 退避した変更を復元
alias gstp='git stash pop'
alias grb='git rebase'
# 対話的リベース
alias grbi='git rebase -i'

# npm エイリアス
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
# yarn エイリアス
alias yi='yarn install'
alias yr='yarn run'

# ターミナル Git GUI を lg で起動
alias lg='lazygit'

# Docker エイリアス
alias d='docker'
alias dc='docker compose'
# バックグラウンドで起動
alias dcu='docker compose up -d'
# 停止して削除
alias dcd='docker compose down'
# ログをフォロー
alias dcl='docker compose logs -f'
# 実行中コンテナ一覧
alias dps='docker ps'

# Laravel Artisan エイリアス
alias art='php artisan'
alias artm='php artisan migrate'
# DB をリセットして再作成
alias artmf='php artisan migrate:fresh --seed'

# Laravel のキャッシュを全てクリアする関数
function laravelclear() {
  php artisan cache:clear
  php artisan config:clear
  php artisan route:clear
  php artisan view:clear
  echo "All Laravel caches cleared!"
}

# Claude Code を確認なしで実行（ローカル開発用、本番では使わない）
alias cc='claude --dangerously-skip-permissions'

# ディレクトリを作成して移動
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# 指定ポートを使用しているプロセスを表示
function port() {
  lsof -i :"$1"
}

# 指定ポートを使用しているプロセスを強制終了
function killport() {
  lsof -ti :"$1" | xargs kill -9
}

# 現在のリポジトリを GitHub で開く
function ghopen() {
  local url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/.git$//')
  if [[ -n "$url" ]]; then
    open "$url"
  else
    echo "Not a git repository or no remote found"
  fi
}

# fzf でブランチを選択してチェックアウト
function fbr() {
  local branches branch
  branches=$(git branch -a | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf --height 40% --reverse) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
}

# fzf でディレクトリを選択して移動
function fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse) &&
  cd "$dir"
}

# ローカル設定（API キー等の機密情報はここに書く、git 管理外）
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# vim:set ft=zsh:

# ローカルにインストールしたコマンドを優先
export PATH="$HOME/.local/bin:$PATH"
