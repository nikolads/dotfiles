if test -f $HOME/.profile
    source $HOME/.profile
end

set --export FZF_DEFAULT_OPTS "--color=16"

set fish_greeting
set fish_prompt_pwd_dir_length 4

bind \cr '__fzf_search_history'

function fish_prompt
    set -l pwd (prompt_pwd)

    set -l host (if set --query SSH_CONNECTION
       printf "%s:" (hostname)
    end)

    set_color yellow
    printf "$host$pwd "
    set_color normal

    set git_branch (git status 2>/dev/null | head -n 1 | sed 's/On branch \(.*\)/\1/')
    if test -n "$git_branch"
        set_color green
        printf "($git_branch) "
        set_color normal
    end
end
