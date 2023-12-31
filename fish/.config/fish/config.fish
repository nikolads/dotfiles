set --export FZF_DEFAULT_OPTS "--color=16"

set fish_greeting

bind \cr '__fzf_search_history'

builtin history merge

function print_prompt_pwd
    set -l full_dirs 1
    set -l max_dir_len 6
    set -l color_prompt yellow
    set -l color_missing red

    set -l full_path $argv[1]

    set -l realhome ~
    set -l path (string replace -r "^$realhome(\$|/)" '~$1' $full_path)
    set -l parts (string split "/" $path)

    realpath -e $full_path 1>/dev/null 2>/dev/null; set -l path_exists $status

    set -l short
    set -l full

    if test (count $parts) -gt $full_dirs
        set -l n "-$full_dirs"
        set short $parts[..(math $n - 1)]
        set full $parts[$n..]
    else
        set short
        set full $parts
    end

    set -l result

    for part in $short
        if test (string length $part) -gt $max_dir_len
            set result $result (printf %s… (string sub -l (math $max_dir_len - 1) $part))
        else
            set result $result $part
        end
    end

    set result $result $full

    if test $path_exists -eq 0
        set_color $color_prompt
        printf %s (string join "/" $result)
        set_color normal
    else
        set_color $color_missing
        printf %s (string join "/" $result)
        set_color normal
    end
end

function fish_prompt
    set -l display_status $status
    set -l pwd (prompt_pwd)

    if test $display_status -eq 0
        set_color -r yellow
        printf "✔"
        set_color normal
        printf " "
    else
        set_color -r red
        printf "✗"
        set_color normal
        printf " "
    end

    set -l n_jobs (jobs -g | wc -l)
    if test $n_jobs -gt 0
        set_color brblack
        printf "[%s]" $n_jobs
        set_color normal
        printf " "
    end

    set -l host (if set --query SSH_CONNECTION
       printf "%s:" (hostname)
    end)

    set_color yellow
    # printf %s "$host$pwd "
    printf %s $host
    print_prompt_pwd (pwd)
    printf " "
    set_color normal

    set git_branch (git status 2>/dev/null | head -n 1 | sed 's/On branch \(.*\)/\1/')
    if test -n "$git_branch"
        if test -z (git status --porcelain 2>/dev/null | string collect)
            set git_dirty ""
        else
            set git_dirty "*"
        end

        set_color green
        printf %s "($git_dirty$git_branch) "
        set_color normal
    end

    set_color normal
end

# # When `cd`-ing to a symlink to a directory, `cd` to the resolved path.
# #
# # From some version onwards fish uses a "virtual" PWD.
# # This reverts to the old behavior.
# # See https://github.com/fish-shell/fish-shell/issues/3350
# functions --copy cd _fish_cd
# function cd
#     if test "$argv" = "" -o "$argv" = "-"
#         _fish_cd $argv
#     else
#         _fish_cd (realpath $argv)
#     end
# end

# In some version fish changed the terminal title from "fish <cwd>" to just "<cwd>".
# I want the old title back.
#
# Copied from /usr/share/fish/functions/fish_title.fish
function fish_title
    # emacs' "term" is basically the only term that can't handle it.
    if not set -q INSIDE_EMACS; or string match -vq '*,term:*' -- $INSIDE_EMACS
        # If we're connected via ssh, we print the hostname.
        set -l ssh
        set -q SSH_TTY
        and set ssh "["(prompt_hostname | string sub -l 10 | string collect)"]"
        # An override for the current command is passed as the first parameter.
        # This is used by `fg` to show the true process name, among others.
        if set -q argv[1]
            echo -- $ssh (string sub -l 20 -- $argv[1]) : (prompt_pwd -D 1)
        else
            set -l command (status current-command)
            # # Don't print "fish" because it's redundant
            # if test "$command" = fish
            #     set command
            # end
            echo -- $ssh (string sub -l 20 -- $command) : (prompt_pwd -D 1)
        end
    end
end
