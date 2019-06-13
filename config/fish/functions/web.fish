function firefox
    command firefox $argv >/dev/null 2>/dev/null &
end

function web
    firefox $argv
end
