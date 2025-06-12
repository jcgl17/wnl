# taken directly from /usr/share/bash-completion/completions/watch

_comp_cmd_watch()
{
    local cur prev words cword was_split
    _comp_initialize -s -- "$@" || return

    local offset=0 i
    local noargopts='!(-*|*[dn]*)'
    # shellcheck disable=SC2254
    for ((i = 1; i <= cword; i++)); do
        case ${words[i]} in
            --help | --version | -${noargopts}h)
                return
                ;;
            --interval | -${noargopts}n)
                ((i++))
                continue
                ;;
            -*)
                continue
                ;;
        esac
        offset=$i
        break
    done

    if ((offset > 0)); then
        _comp_command_offset $offset
        return
    fi

    # shellcheck disable=SC2254
    case $prev in
        --differences | -${noargopts}d)
            [[ $cur != -* ]] &&
                _comp_compgen -- -W 'cumulative'
            return
            ;;
        --interval | -${noargopts}n)
            return
            ;;
    esac

    [[ $was_split ]] && return

    if [[ $cur == -* ]]; then
        _comp_compgen_help
        [[ ${COMPREPLY-} == *= ]] && compopt -o nospace
        return
    fi
} &&
    complete -F _comp_cmd_watch wnl
