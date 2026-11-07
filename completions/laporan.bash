_laporan_completions() {
    local cur prev words cword
    _init_completion || return

    local commands="mcp build pdf docx init import preset stats audit citations doctor bundle setup sync-hosts uninstall check test view watch clean help"
    local presets="standard skripsi-4433 ui-skripsi itb-ta ugm-skripsi its-skripsi unpad-skripsi ub-skripsi undip-skripsi unair-skripsi ipb-ppki telkom-ta jurnal-uajy jurnal-standar"
    local preset_subcmds="list scan show diff validate apply"

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    case "${words[1]}" in
        preset)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "$preset_subcmds" -- "$cur") )
                return 0
            elif [[ $cword -ge 3 ]]; then
                case "${words[2]}" in
                    show|apply|diff|validate)
                        COMPREPLY=( $(compgen -W "$presets" -- "$cur") )
                        return 0
                        ;;
                    scan)
                        COMPREPLY=( $(compgen -f -X '!*.pdf' -- "$cur") )
                        return 0
                        ;;
                esac
            fi
            ;;
        citations)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "verify" -- "$cur") )
                return 0
            fi
            ;;
        import|ingest)
            COMPREPLY=( $(compgen -f -- "$cur") )
            return 0
            ;;
    esac
}

complete -F _laporan_completions laporan
complete -F _laporan_completions ./laporan
