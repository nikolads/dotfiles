#!/usr/bin/fish

set script_dir (dirname (realpath (status --current-filename)))

set screenshot_dir (xdg-user-dir PICTURES)"/screenshot"
set screenshot_dir_short (printf "%s" $screenshot_dir | sed "s|^$HOME|~|")

set choices
set choices $choices "Screenshot area <small><i>(copy to clipboard)</i></small>"
set choices $choices "Screenshot area <small><i>(save to $screenshot_dir_short)</i></small>"
set choices $choices "Screenshot output <small><i>(focused, copy to clipboard)</i></small>"
set choices $choices "Screenshot output <small><i>(focused, save to $screenshot_dir_short)</i></small>"
set choices $choices "Pick color"

set selected_index (
    string join \n $choices |
    rofi -normal-window -dmenu -p "screenshot" -format "d" -no-custom -markup-rows
)

function pick_pixel
    tail --bytes 3 | xxd -p -g 0 | read pixel

    if test $status != "0"
        return
    end

    set output (echo "$pixel" | python3 $script_dir/color_convert.py)

    set srgb_hex (string join \n $output | head -n 1)
    set srgb (string join \n $output | head -n 2 | tail -n 1)
    set rgb (string join \n $output | head -n 3 | tail -n 1)
    set hsv (string join \n $output | head -n 4 | tail -n 1)
    set hsl (string join \n $output | head -n 5 | tail -n 1)

    set selection (string join \n \
        "<span foreground=\"#$srgb_hex\">■</span> #$srgb_hex <small><i>(non-linear sRGB, hex)</i></small>" \
        "<span foreground=\"#$srgb_hex\">■</span> $srgb <small><i>(non-linear sRGB)</i></small>" \
        "<span foreground=\"#$srgb_hex\">■</span> $rgb <small><i>(linear sRGB)</i></small>" \
        "<span foreground=\"#$srgb_hex\">■</span> $hsv <small><i>(HSV)</i></small>" \
        "<span foreground=\"#$srgb_hex\">■</span> $hsl <small><i>(HSL)</i></small>" |
        rofi -normal-window -dmenu -p "pixel (select to copy)" -format "d" -no-custom -markup-rows)

    switch $selection
        case "1"
            printf "#$srgb_hex" | wl-copy
        case "2"
            printf $srgb | wl-copy
        case "3"
            printf $rgb | wl-copy
        case "4"
            printf $hsv | wl-copy
        case "5"
            printf $hsl | wl-copy
    end
end

switch $selected_index
    case "1"
        slurp | grim -g - - | wl-copy
    case "2"
        mkdir -p $screenshot_dir
        slurp | env GRIM_DEFAULT_DIR=$screenshot_dir grim -g -
    case "3"
        set output (swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
        grim -o $output - | wl-copy
    case "4"
        mkdir -p $screenshot_dir
        set output (swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
        env GRIM_DEFAULT_DIR=$screenshot_dir grim -o $output
    case "5"
        slurp -p | grim -g - -t ppm - | pick_pixel
end

