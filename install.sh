#!/usr/bin/env bash
#
# Dotfiles installer — creates symlinks for nvim, tmux, starship, mise,
# opencode and the shell rc files. Existing files are backed up with a
# timestamp suffix before being replaced.
#
# Usage:
#   ./install.sh            # install for the current OS
#   ./install.sh --dry-run  # show what would happen, change nothing
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
run()   { $DRY_RUN && printf '  $ %s\n' "$*" || eval "$@"; }

# link <source-in-repo> <destination>
link() {
  local src="$DOTFILES/$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    warn "missing source: $src (skipped)"
    return
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    info "already linked: $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="$dst.bak.$(date +%s)"
    warn "backing up $dst -> $backup"
    run mv "$dst" "$backup"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  info "linked $dst -> $src"
}

OS="$(uname -s)"
IS_WSL=false
[[ -f /proc/version ]] && grep -qi microsoft /proc/version && IS_WSL=true
info "dotfiles: $DOTFILES"
info "os: $OS $($IS_WSL && echo '(WSL)')"
$DRY_RUN && warn "dry-run mode, nothing will change"

# --- Shared configs (all platforms) ----------------------------------------
link "shared/nvim"            "$HOME/.config/nvim"
link "shared/tmux"            "$HOME/.config/tmux"
link "shared/starship.toml"   "$HOME/.config/starship.toml"
link "shared/mise"            "$HOME/.config/mise"
link "opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
link "opencode/tui.json"      "$HOME/.config/opencode/tui.json"

# --- OS-specific -----------------------------------------------------------
if [[ "$OS" == "Darwin" ]]; then
  link "mac/zshrc"          "$HOME/.zshrc"
  link "mac/ghostty.config" "$HOME/.config/ghostty/config"

  if command -v brew &>/dev/null; then
    info "installing packages with brew bundle..."
    run brew bundle --file "$DOTFILES/mac/Brewfile"
  else
    warn "homebrew not found: https://brew.sh (then re-run install.sh)"
  fi
elif [[ "$OS" == "Linux" ]]; then
  if $IS_WSL; then
    link "wsl/bashrc" "$HOME/.bashrc"
    info "install apt packages listed in wsl/packages.txt, then the tools"
    info "without apt packages (mise, starship, eza, zoxide) per that file."
  else
    info "native Linux detected (not WSL) — skipping shell rc link."
    info "on the Omarchy machine the repo is source-only; link manually if wanted."
  fi
fi

# --- Toolchain -------------------------------------------------------------
if command -v mise &>/dev/null; then
  info "installing mise tools (node, go, opencode)..."
  run mise install
else
  warn "mise not found, skipping tool install (see README)"
fi

if command -v nvim &>/dev/null; then
  info "bootstrapping neovim plugins (lazy.nvim sync)..."
  if $DRY_RUN; then
    printf '  $ nvim --headless "+Lazy! sync" +qa\n'
  else
    nvim --headless "+Lazy! sync" +qa
  fi
fi

info "done."
info "remember: put your local AI server key in ~/.secrets/local-ai-key (chmod 600)"

# --- Shell check -----------------------------------------------------------
if [[ "$OS" == "Linux" ]] && $IS_WSL; then
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  bash_path="$(command -v bash)"
  if [[ "$current_shell" != "$bash_path" ]]; then
    warn "you are using $(basename "$current_shell") but the WSL config is made for bash."
    if $DRY_RUN; then
      printf '  $ sudo chsh -s %s %s\n' "$bash_path" "$USER"
    elif sudo chsh -s "$bash_path" "$USER"; then
      info "login shell changed to bash (restarts on next login)"
    else
      warn "could not change the shell. To do it manually run:"
      warn "  sudo chsh -s $bash_path \$USER"
    fi
  fi
fi
