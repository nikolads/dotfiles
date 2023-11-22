#!/usr/bin/fish

set script_dir (dirname (realpath (status --current-filename)))

set choices
set choices $choices "Suspend"
set choices $choices "Hibernate"
set choices $choices "Poweroff"
set choices $choices "Reboot"

set commands
set commands $commands "systemctl suspend"
set commands $commands "systemctl hibernate"
set commands $commands "systemctl poweroff"
set commands $commands "systemctl reboot"

set selected (
    string join \n $choices |
    rofi -normal-window -dmenu -p "power" -format "d" -no-custom -markup-rows
)

if test $status
    sh -c $commands[$selected]
end

