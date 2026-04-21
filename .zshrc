# 1. Homebrew の初期化 (これを最優先にしないと brew prefix 等が動きません)
eval "$(/opt/homebrew/bin/brew shellenv)"
# brew のパスを変数に入れておく (高速化 & エラー防止)
BREW_PREFIX=$(brew --prefix)

# 2. aqua の設定 (PATH を通す)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export AQUA_ROOT_DIR="$XDG_DATA_HOME/aquaproj-aqua"
export PATH="$AQUA_ROOT_DIR/bin:$PATH"
export AQUA_CONFIG="$XDG_CONFIG_HOME/aquaproj-aqua/aqua.yaml"
export AQUA_PROGRESS_BAR=true

# 3. 補完の設定
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# 4. Zsh 基本設定
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# 5. プラグインの読み込み (brew prefix を使うので Homebrew 設定の後である必要あり)
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $BREW_PREFIX/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# source $BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

source <(aqua completion zsh)

alias agi='aqua g -i'

# Go
## Go 1.26 向け環境変数設定
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
## PATHにGOBINを追加（go installしたツールがどこでも動くようにする）
export PATH=$PATH:$GOBIN

## Goのプロキシ設定（ダウンロードを高速化し、ビルドを安定させる）
export GOPROXY=https://proxy.golang.org,direct

# history incremental search

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# terminfo を使って、どんなターミナルでも矢印キーを認識させる
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# Zsh history incremental search
function fzf-select-history() {
    # 履歴を重複なく、番号なしで取得し、fzfに渡す
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --prompt="History > " --height=40% --reverse)
    # カーソルを末尾に移動
    CURSOR=$#BUFFER
    # 画面を再描画
    zle reset-prompt
}

## ウィジェットとして登録
zle -N fzf-select-history

## ショートカットキー（Ctrl + r）に割り当て
bindkey '^r' fzf-select-history

# Repository incremental search
function ghq-path() {
    ghq list --full-path | fzf
}

function fzf-ghq-widget() {
    local moveto
    moveto=$(ghq-path)
    cd "${moveto}" || exit 1

    # rename session if in tmux
    if [[ -n ${TMUX} ]]; then
        local repo_name
        repo_name="${moveto##*/}"

        tmux rename-session "${repo_name//./-}"
    fi
}

zle -N fzf-ghq-widget
bindkey '^g' fzf-ghq-widget

# alias
alias vim='nvim'
alias g='git'
alias gplo='git pull origin'
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
fi

# starship
eval "$(starship init zsh)"

# Claude
export PATH="$HOME/.local/bin:$PATH"

# awsp
alias awsp="source _awsp"

# gcloud profile switch
gcpp() {
  local config=$(gcloud config configurations list --format='value(name)' | fzf --prompt='GCP Profile> ')
  if [ -n "$config" ]; then
    gcloud config configurations activate "$config"
  fi
}

# Env
export EDITOR=nvim

# Custom scripts
export PATH="$PATH:$HOME/bin"

# direnv
eval "$(direnv hook zsh)"
