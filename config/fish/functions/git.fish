function git
    if test $argv[1] = "log"
        command /usr/bin/git --no-pager log --pretty=py-oneline --color=always $argv[2..-1] | $HOME/bin/git-log-fmt.py
    else
        command /usr/bin/git $argv 
    end
end

