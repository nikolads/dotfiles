#!/usr/bin/fish

set outputs (
    swaymsg -t get_outputs |
    jq '.[] | {name, active, scale}'
)

set outputs_display (
    echo $outputs |
    jq -r '{ name,
             state: [ if .active then "enabled" else "disabled" end,
                      if .scale == null then empty else "scale \(.scale)" end ] }
           | "\(.name)" + " <small><i>(" + (.state | join(", ")) + ")</i></small>"'
)

set selected_output (
    string join \n $outputs_display |
    rofi -dmenu -normal-window -p "output" -markup-rows |
    cut -f 1 -d " "
)

if test -z $selected_output
    exit
end

set arguments
switch (echo $outputs | jq "select(.name == \"$selected_output\") | .active")
    case "false"
        set arguments $arguments "enable"
    case "true"
        # prevent accidentally turning off all displays
        switch (echo $outputs | jq -s "map(select(.active == true)) | length")
            case "1"
                set arguments $arguments "scale 1" "scale 1.25"
            case "*"
                set arguments $arguments "disable" "scale 1" "scale 1.25"
        end
end

set selected_command (
    string join \n "swaymsg -t command output $selected_output "{$arguments} |
    rofi -dmenu -normal-window -p "run"
)

if test -z $selected_command
    exit
end

/bin/sh -c "$selected_command"
