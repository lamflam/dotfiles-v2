# dotfiles-v2

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).
Targets macOS laptops and Linux servers (Hetzner / Digital Ocean).

## Bootstrap a new machine

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/lamflam/dotfiles-v2/main/scripts/bootstrap.sh)"
```

The script:

1. Installs minimal prereqs (`git`, `curl`) via apt/dnf/pacman on Linux,
   triggers Xcode CLT install on macOS.
2. Drops `chezmoi` into `~/.local/bin` (no sudo).
3. Runs `chezmoi init --apply lamflam/dotfiles-v2` — prompts you, writes
   files, and the post-apply script installs everything else (Brewfile on
   macOS / apt + upstream tarballs on Linux).

If you already have `chezmoi` and prefer to skip the bootstrap script:

```sh
chezmoi init --apply lamflam/dotfiles-v2
```

On first run chezmoi prompts for:

- `name`, `email` — git identity
- `work` — pulls in a private work overlay repo (off by default)
- `nested` — true on remote machines that run inside laptop tmux (switches
  tmux prefix to `C-z` and pane-nav to `M-hjkl` to avoid conflicts)

## Layout

- `home/` — chezmoi source state. Templated files have a `.tmpl` suffix.
- `home/dot_config/zsh/` — modular zsh config sourced from `dot_zshrc.tmpl`.
- `home/dot_config/{tmux,git,nvim,starship,ghostty}/` — tool configs.
- `home/.chezmoiscripts/` — `run_onchange_*` package install scripts.
- `.chezmoiexternal.toml.tmpl` — pulls private work overlay when `work=true`.

## Daily use

```sh
chezmoi edit ~/.zshrc        # edit a managed file in the source dir
chezmoi diff                 # preview pending changes
chezmoi apply                # apply changes to $HOME
chezmoi cd                   # cd to source dir
```
