if test -f $HOME/.profile
    source $HOME/.profile
end

set fish_greeting
set fish_prompt_pwd_dir_length 4

function fish_prompt
    set -l pwd (prompt_pwd)
    
    set -l host (if set --query SSH_CONNECTION
       printf "%s:" (hostname)
    end)

    set_color yellow
    printf "$host$pwd "
    set_color normal
end
