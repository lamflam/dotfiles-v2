#
# Shell functions.
#

# ssh — wraps the binary to install ghostty terminfo on remote on first
# connect. Defined here (not via Ghostty's parent-shell integration) so the
# behavior is the same in tmux subshells, screen, scripts, etc.
ssh() {
  if [[ "$TERM" == "xterm-ghostty" ]] && command -v infocmp >/dev/null 2>&1; then
    local host
    host=$(command ssh -G "$@" 2>/dev/null | awk '/^hostname / {print $2; exit}')
    if [[ -n "$host" ]]; then
      local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/ghostty-terminfo"
      local marker="$cache_dir/$host"
      if [[ ! -f "$marker" ]]; then
        if infocmp -x xterm-ghostty 2>/dev/null \
            | command ssh -T -o LogLevel=ERROR "$host" \
                'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo - >/dev/null 2>&1'
        then
          mkdir -p "$cache_dir"
          touch "$marker"
        fi
      fi
    fi
  fi
  command ssh "$@"
}

# Search-and-replace across files matched by ripgrep.
#   rgr 'oldText' 'newText'
rgr() {
  if [ $# -ne 2 ]; then
    echo "usage: rgr <from> <to>" >&2
    return 1
  fi
  rg -0 -l "$1" | RGR_FROM="$1" RGR_TO="$2" \
    xargs -0 perl -pi -e 's/$ENV{RGR_FROM}/$ENV{RGR_TO}/g'
}

# mkdir + cd
mkcd() { mkdir -p "$1" && cd "$1"; }

# fzf-driven git helpers (kept from work dotfiles)
_in_git_repo() { git rev-parse HEAD >/dev/null 2>&1; }

gf() {
  _in_git_repo || return
  git -c color.status=always status --short |
    fzf --height 50% --border -m --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
    cut -c4- | sed 's/.* -> //'
}

gb() {
  _in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --height 50% --border --ansi --multi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
    sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##'
}

gl() {
  _in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
    fzf --height 50% --border --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'CTRL-S to toggle sort' \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
    grep -o "[a-f0-9]\{7,\}"
}
