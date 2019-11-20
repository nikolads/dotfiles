#!/usr/bin/env fish

switch (readlink $HOME/.config/kitty/current-theme.conf)
    case "theme-light-solarized.conf"
        ln -sf theme-dark-solarized.conf $HOME/.config/kitty/current-theme.conf
        
    case "theme-dark-solarized.conf"
        ln -sf theme-light-solarized.conf $HOME/.config/kitty/current-theme.conf
end

for sock in /tmp/kitty/*.sock
    kitty @ --to=unix:$sock set-colors --all --configured $HOME/.config/kitty/current-theme.conf
end

