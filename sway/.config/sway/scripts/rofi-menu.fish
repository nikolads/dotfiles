#!/usr/bin/fish

set script_dir (dirname (realpath (status --current-filename)))

set choices
set choices $choices "Output"
set choices $choices "Screenshot"
set choices $choices "Power"

set commands
set commands $commands "$script_dir/rofi-command-output.fish"
set commands $commands "$script_dir/rofi-screenshot.fish"
set commands $commands "$script_dir/rofi-power.fish"

set selected (
    string join \n $choices |
    rofi -normal-window -dmenu -p "menu" -format "d" -no-custom -markup-rows
)

if test $status
    exec $commands[$selected]
end
