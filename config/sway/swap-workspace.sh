#!/bin/sh

focused_output=$(swaymsg -t get_workspaces | jq '.[] | select(.focused) | .output')
target_workspace=$1
target_output=$(swaymsg -t get_workspaces | jq '.[] | select(.name == "'$1'") | .output')

if test -n "$target_output"; then
    swaymsg move workspace to output $target_output
    swaymsg workspace $target_workspace
    swaymsg move workspace to output $focused_output
else
    swaymsg workspace $target_workspace
fi
