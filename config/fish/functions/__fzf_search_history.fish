# Credits: https://github.com/PatrickF1/fzf.fish
function __fzf_search_history --description "Search command history using fzf. Replace the commandline with the selected command."
    # history merge incorporates history changes from other fish sessions
    builtin history merge

    set command_selected (builtin history --null | fzf --read0 --tiebreak=index --query=(commandline))

    if test $status -eq 0
        commandline --replace $command_selected
    end
end
