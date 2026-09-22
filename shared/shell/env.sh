# Environment variables shared by bash and zsh.
# Sourced from mac/zshrc and wsl/bashrc.

# Editor used by CLI tools
export EDITOR="${EDITOR:-nvim}"
export SUDO_EDITOR="$EDITOR"

# Color man pages with bat
if command -v bat &>/dev/null; then
  export MANROFFOPT="-c"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export BAT_THEME=ansi
fi

# ~/.local/bin for user-installed tools (mise shims land here too)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac
