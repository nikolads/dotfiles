function git
    if test (count $argv) -lt 1
        command git
        return
    end

    switch $argv[1]
        case "log"
            if /usr/bin/test -t 1
                command git --no-pager log --pretty=py-oneline --color=always $argv[2..-1] | eval $HOME/bin/git-log-fmt.py
            else
                command git --no-pager log --pretty=py-oneline $argv[2..-1] | eval $HOME/bin/git-log-fmt.py
            end

   
        case "*"
            command git $argv 
    end
end
