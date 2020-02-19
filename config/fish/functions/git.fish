function git
    # set -l pretty_full "%C(red)%h%C(reset) - %C(green)(%cr)%C(reset) %C(8 bold){{{author:%an}}}%C(reset)  %C(auto)%D%C(reset)%n%B"
    # set -l pretty_oneline "%C(red)%h%C(reset) %C(green){{{age:%cr}}}%C(reset) %C(8 bold){{{author:%an}}}%C(reset) - %s  %C(auto)%D%C(reset)"
    set -l pretty_oneline "%C(red)%h%C(reset) %C(green){{{age:%cr}}}%C(reset) %C(8 bold){{{email:%ae}}}%C(reset) - %s  %C(auto)%D%C(reset)"

    if test (count $argv) -lt 1
        command git
        return
    end

    switch $argv[1]
        case "log"
            if /usr/bin/test -t 1
                command git --no-pager log --pretty="format:$pretty_oneline" --color=always $argv[2..-1] | $HOME/bin/git-log-fmt.py
            else
                command git --no-pager log --pretty="format:$pretty_oneline" $argv[2..-1] | $HOME/bin/git-log-fmt.py
            end


        case "*"
            command git $argv
    end
end
