#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  backup: $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    echo "  linked: $dst -> $src"
}

echo "==> dotfiles: $DOTFILES_DIR"

# ホームディレクトリ直下
link "$DOTFILES_DIR/.Brewfile"   "$HOME/.Brewfile"
link "$DOTFILES_DIR/.zprofile"   "$HOME/.zprofile"
link "$DOTFILES_DIR/.zshrc"      "$HOME/.zshrc"

# .claude
link "$DOTFILES_DIR/.claude/settings.json"           "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/.claude/custom-shell/status.sh"  "$HOME/.claude/custom-shell/status.sh"

# .grip
link "$DOTFILES_DIR/.grip/settings.py"  "$HOME/.grip/settings.py"

# .config
link "$DOTFILES_DIR/.config/aquaproj-aqua/aqua.yaml"  "$HOME/.config/aquaproj-aqua/aqua.yaml"
link "$DOTFILES_DIR/.config/cmux/settings.json"        "$HOME/.config/cmux/settings.json"
link "$DOTFILES_DIR/.config/git/config"                "$HOME/.config/git/config"
link "$DOTFILES_DIR/.config/gwq/config.toml"           "$HOME/.config/gwq/config.toml"
link "$DOTFILES_DIR/.config/nvim/init.lua"             "$HOME/.config/nvim/init.lua"
link "$DOTFILES_DIR/.config/starship.toml"             "$HOME/.config/starship.toml"
link "$DOTFILES_DIR/.config/yazi/yazi.toml"            "$HOME/.config/yazi/yazi.toml"
link "$DOTFILES_DIR/.config/yazi/keymap.toml"          "$HOME/.config/yazi/keymap.toml"
link "$DOTFILES_DIR/.config/yazi/mo-preview.sh"      "$HOME/.config/yazi/mo-preview.sh"

# scripts -> ~/bin
mkdir -p "$HOME/bin"
link "$DOTFILES_DIR/bin/cmux-setup"      "$HOME/bin/cmux-setup"
link "$DOTFILES_DIR/bin/git-watch"       "$HOME/bin/git-watch"

echo ""
echo "Done."
