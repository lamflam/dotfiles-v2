#!/usr/bin/env sh
#
# Bootstrap a fresh machine (Linux server or macOS) from this dotfiles repo.
#
# Usage:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/lamflam/dotfiles-v2/main/scripts/bootstrap.sh)"
#
# Steps:
#   1. Install minimal prereqs (git, curl).
#   2. Install chezmoi to ~/.local/bin (no sudo required).
#   3. `chezmoi init --apply lamflam/dotfiles-v2` — prompts for name/email/work/nested,
#      writes dotfiles, then run_onchange_after_install-packages.sh installs
#      everything else (zsh plugins, neovim, node, etc.).
#

set -eu

REPO="lamflam/dotfiles-v2"
BIN_DIR="$HOME/.local/bin"

echo "▶ Bootstrap: $REPO"

# ------------------------------------------------------------ Prerequisites
case "$(uname -s)" in
  Linux)
    if command -v apt-get >/dev/null 2>&1; then
      echo "▶ Installing prerequisites via apt..."
      sudo apt-get update -qq
      sudo apt-get install -yq --no-install-recommends \
        ca-certificates curl git
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y ca-certificates curl git
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -Sy --noconfirm ca-certificates curl git
    fi
    ;;
  Darwin)
    if ! command -v git >/dev/null 2>&1; then
      echo "▶ Triggering Xcode CLT install (accept the GUI prompt)..."
      xcode-select --install || true
    fi
    ;;
esac

# ------------------------------------------------------------ chezmoi
mkdir -p "$BIN_DIR"
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "▶ Installing chezmoi to $BIN_DIR..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
fi
export PATH="$BIN_DIR:$PATH"

# ------------------------------------------------------------ Apply
# When this script is curl-piped, our stdin is the curl pipe (not a TTY),
# so chezmoi's promptStringOnce / promptBoolOnce in .chezmoi.toml.tmpl
# would silently read EOF and templates referencing .name etc would fail.
# Redirect from /dev/tty so chezmoi can prompt the actual user.
echo "▶ Running chezmoi init --apply $REPO"
if [ -e /dev/tty ]; then
  chezmoi init --apply "$REPO" </dev/tty
else
  chezmoi init --apply "$REPO"
fi

echo
echo "✔ Bootstrap complete."
case "$(uname -s)" in
  Linux)
    echo "  Next:  chsh -s \"\$(command -v zsh)\""
    echo "         then log out / log back in."
    ;;
  Darwin)
    echo "  Next:  open a new terminal — zsh + starship are ready."
    ;;
esac
