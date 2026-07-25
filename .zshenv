# aqua の設定 (non-interactive shell でも aqua shim が解決できるよう .zshenv に置く)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export AQUA_ROOT_DIR="$XDG_DATA_HOME/aquaproj-aqua"
export PATH="$AQUA_ROOT_DIR/bin:$PATH"
export AQUA_CONFIG="$XDG_CONFIG_HOME/aquaproj-aqua/aqua.yaml"
export AQUA_GLOBAL_CONFIG="$XDG_CONFIG_HOME/aquaproj-aqua/aqua.yaml"
export AQUA_PROGRESS_BAR=true
