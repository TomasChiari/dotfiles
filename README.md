# dotfiles

Portable terminal setup: **opencode + LazyVim + tmux + modern CLI tools**.
Targets: macOS (zsh + Ghostty) and WSL Ubuntu (bash). Source machine: Arch/Omarchy.

## What's inside

| Path | What it is |
| :--- | :--- |
| `shared/nvim` | LazyVim config (plugins pinned via `lazy-lock.json`) |
| `shared/tmux` | tmux config (prefix `C-Space`, vi copy mode, Alt-navigation) |
| `shared/starship.toml` | prompt |
| `shared/mise` | tool versions: node, go, opencode |
| `shared/shell` | aliases/env/init shared by bash and zsh (ported from Omarchy) |
| `opencode` | opencode config (provider `local-server`, key via `{file:}`) |
| `mac` | `.zshrc`, Ghostty config, `Brewfile` |
| `wsl` | `.bashrc`, apt package list + install notes |

## Install

```bash
git clone <this-repo> <anywhere>/dotfiles   # clone wherever you like
cd <anywhere>/dotfiles
./install.sh            # add --dry-run to preview
```

The shell rc files resolve the repo location from the symlink target at
startup, so the clone path does not matter. Set `$DOTFILES` explicitly only
if you ever bypass the symlinks.

The installer backs up any existing config to `*.bak.<timestamp>` before linking.

### API key (required once per machine)

The opencode provider key is **not** in the repo. Create it manually:

```bash
mkdir -p ~/.secrets
$EDITOR ~/.secrets/local-ai-key   # paste the key, single line
chmod 600 ~/.secrets/local-ai-key
```

### macOS

`install.sh` links `~/.zshrc` and the Ghostty config, then runs
`brew bundle` (neovim, tmux, starship, mise, fzf, ripgrep, fd, bat, eza,
zoxide, btop, lazygit, lazydocker, findutils, Ghostty cask, JetBrainsMono
Nerd Font).

### WSL (Ubuntu)

`install.sh` links `~/.bashrc`. Packages: see `wsl/packages.txt` —
apt for the basics, official installers for mise/starship/eza/zoxide.
Install **JetBrainsMono Nerd Font in Windows** and select it in Windows
Terminal settings.

## Post-install

```bash
mise install        # tool versions from shared/mise/config.toml
nvim                # first run syncs plugins (also done by install.sh)
t                   # tmux session "Work"
c                   # opencode
```

## Notes

- `shared/nvim/lua/config/remote_clipboard.lua` uses OSC52 inside
  tmux/SSH and falls back gracefully — works on macOS and WSL as-is.
- The Omarchy machine itself is intentionally left untouched; this repo
  is only the *source*. If you ever want this machine to consume the
  repo too, re-run `install.sh` here (it will back up and link).
