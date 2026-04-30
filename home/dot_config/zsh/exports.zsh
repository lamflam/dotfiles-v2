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
  export FZF_DEFAULT_OPTS='
    --color=fg:#d4be98,bg:#282828,hl:#a9b665
    --color=fg+:#d4be98,bg+:#32302f,hl+:#e78a4e
    --color=info:#7daea3,prompt:#d8a657,pointer:#ea6962
    --color=marker:#ea6962,spinner:#a9b665,header:#7daea3
    --bind ctrl-alt-k:preview-up,ctrl-alt-j:preview-down
    --bind alt-up:preview-up,alt-down:preview-down
    --bind pgup:preview-page-up,pgdn:preview-page-down
  '
fi

# Local-only overrides
[ -r "$HOME/.config/zsh/exports.local.zsh" ] && \
  source "$HOME/.config/zsh/exports.local.zsh"
