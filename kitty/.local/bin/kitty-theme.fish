#!/usr/bin/env fish

function help
    echo "Usage: kitty-theme.fish COMMAND"
    echo
    echo "Commands:"
    echo "  light       Switch to light theme"
    echo "  dark        Switch to dark theme"
    echo "  toggle      Toggle between light and dark theme"
    echo "  reload      Reload config for currently active theme"

    exit 1
end

set light_theme "theme-light-solarized.conf"
set dark_theme "theme-dark-gruvbox.conf"

set command $argv[1]
switch $command
    case "light"
        ln -sf $light_theme $HOME/.config/kitty/current-theme.conf

    case "dark"
        ln -sf $dark_theme $HOME/.config/kitty/current-theme.conf

    case "toggle"
        switch (readlink $HOME/.config/kitty/current-theme.conf)
            case $light_theme
                ln -sf $dark_theme $HOME/.config/kitty/current-theme.conf

            case $dark_theme
                ln -sf $light_theme $HOME/.config/kitty/current-theme.conf
        end

    case "reload"

    case "*"
        help
end

for sock in /tmp/kitty/*.sock
    kitty @ --to=unix:$sock set-colors --all --configured $HOME/.config/kitty/current-theme.conf &
end

