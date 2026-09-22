# Tool initialization shared by bash and zsh.
# Sourced last, after env.sh and aliases.sh.

# Detect shell name for tool hooks
if [ -n "$ZSH_VERSION" ]; then
  _dotfiles_shell="zsh"
else
  _dotfiles_shell="bash"
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate "$_dotfiles_shell")"
fi

# Prompt (interactive shells only)
if [[ $- == *i* ]] && [[ ${TERM:-} != "dumb" ]] && command -v starship &>/dev/null; then
  eval "$(starship init "$_dotfiles_shell")"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init "$_dotfiles_shell")"
fi

# fzf completion + keybindings (Ctrl-T, Ctrl-R, Alt-C)
if command -v fzf &>/dev/null; then
  if [[ "$_dotfiles_shell" == "zsh" ]]; then
    # Homebrew on macOS
    [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
    [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    # Homebrew on Intel macs
    [[ -f /usr/local/opt/fzf/shell/completion.zsh ]] && source /usr/local/opt/fzf/shell/completion.zsh
    [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]] && source /usr/local/opt/fzf/shell/key-bindings.zsh
  else
    # Debian/Ubuntu
    [[ -f /usr/share/bash-completion/completions/fzf ]] && source /usr/share/bash-completion/completions/fzf
    [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]] && source /usr/share/doc/fzf/examples/key-bindings.bash
    # Arch layout
    [[ -f /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash
    [[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
  fi
fi

unset _dotfiles_shell
