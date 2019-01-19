# Bypass the default behaviour of specifying --indicator-style=classify to ls
function ls
    command ls --color=auto $argv
end

