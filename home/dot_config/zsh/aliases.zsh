#
# Shell aliases.
#

# ls — eza if available, else fall back
if command -v eza >/dev/null; then
  alias ls='eza -alh --group-directories-first'
  alias ll='eza -alh --group-directories-first'
  alias tree='eza --tree'
else
  alias ls='ls -alh'
fi

# cat — bat if available
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'

# git
alias gits='git status'
alias gitlog='git log --format="%C(yellow)%h %Cblue%an %Creset%s"'

# ripgrep — skip .git/
alias rg="rg -g '!.git/'"

# Always use color, never page short ls
alias grep='grep --color=auto'
