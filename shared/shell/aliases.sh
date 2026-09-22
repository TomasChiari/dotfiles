# Aliases and functions shared by bash and zsh.
# Ported from the Omarchy defaults, without omarchy-specific tooling.

# Ubuntu ships bat/fd under different names
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
  alias bat='batcat'
fi
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  alias fd='fdfind'
fi

# File system ---------------------------------------------------------------
if command -v eza &>/dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

# Fuzzy file finder with preview
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi
alias eff='$EDITOR "$(ff)"'

# Send a file over ssh, picked with ff (recent files first).
# Needs GNU find: on macOS `brew install findutils` provides `gfind`.
sff() {
  if [ $# -eq 0 ]; then echo "Usage: sff <destination> (e.g. sff host:/tmp/)"; return 1; fi
  local find_cmd="find"
  if [[ "$OSTYPE" == darwin* ]]; then
    if command -v gfind &>/dev/null; then find_cmd="gfind"; else echo "sff needs GNU find: brew install findutils"; return 1; fi
  fi
  local file
  file=$("$find_cmd" . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) && [ -n "$file" ] && scp "$file" "$1"
}

# Smart cd backed by zoxide
if command -v zoxide &>/dev/null; then
  alias cd="zd"
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi

      printf "\U000F17A9 "
      pwd
    fi
  }
fi

# Open files/URLs with the OS default handler
if [[ "$OSTYPE" == darwin* ]]; then
  # macOS already provides `open`
  :
elif grep -qi microsoft /proc/version 2>/dev/null; then
  open() (wslview "$@" >/dev/null 2>&1 &)
else
  open() (xdg-open "$@" >/dev/null 2>&1 &)
fi

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias c='opencode'
alias d='docker'
alias t='tmux attach || tmux new -s Work'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
