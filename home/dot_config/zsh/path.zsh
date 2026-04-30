#
# PATH — keep entries unique, prepend most-specific dirs first.
#
add_to_path() {
  local dir="${1/#\~/$HOME}"
  [ -d "$dir" ] || return 1
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"
