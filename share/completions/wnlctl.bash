_wnlctl_completion() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    local files=("$XDG_RUNTIME_DIR"/wnl_slot_*.pid)
    local numbers=()
    for file in "${files[@]}"; do
      if [[ $file =~ "$XDG_RUNTIME_DIR"/wnl_slot_([0-9]+).pid ]]; then
        numbers+=("${BASH_REMATCH[1]}")
      fi
    done
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -W "${numbers[*]}" -- "$cur") )
  fi
}

complete -F _wnlctl_completion wnlctl
