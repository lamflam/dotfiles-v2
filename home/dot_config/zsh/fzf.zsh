#
# fzf shell integration — keys + completion.
# Tries `fzf --zsh` (0.48+) first, then falls back to file-based sources.
#

if command -v fzf >/dev/null; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  elif [ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    source /opt/homebrew/opt/fzf/shell/completion.zsh
  elif [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -r /usr/share/zsh/vendor-completions/_fzf ] && \
      source /usr/share/zsh/vendor-completions/_fzf
  elif [ -r "$HOME/.fzf.zsh" ]; then
    source "$HOME/.fzf.zsh"
  fi
fi
