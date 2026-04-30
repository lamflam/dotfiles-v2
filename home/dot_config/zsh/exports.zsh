#
# Environment variables.
#

export GPG_TTY=$(tty)
export LESS='-R --mouse'
export LESSHISTFILE=-

# fzf + ripgrep
if command -v rg >/dev/null && command -v fzf >/dev/null; then
  export FZF_DEFAULT_COMMAND="rg --hidden --files -g '!.git/'"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
  # Colors omitted on purpose — fzf inherits the terminal palette.
  export FZF_DEFAULT_OPTS='
    --bind ctrl-alt-k:preview-up,ctrl-alt-j:preview-down
    --bind alt-up:preview-up,alt-down:preview-down
    --bind pgup:preview-page-up,pgdn:preview-page-down
  '
fi

# Local-only overrides
[ -r "$HOME/.config/zsh/exports.local.zsh" ] && \
  source "$HOME/.config/zsh/exports.local.zsh"
