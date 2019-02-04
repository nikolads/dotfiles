#!/usr/bin/bash

# Gnome 3 configuration

# Switch windows instead of application groups
gsettings set org.gnome.desktop.wm.keybindings switch-applications '[]'
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab', '<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"

# Customize workspaces
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

# Disable "Activities" shortcut so that '<Super>' alone doesn't do anything
gsettings set org.gnome.mutter overlay-key ""

# Set "Nigth Light" temperature
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 5000

# TODO: Stop sounds when using the volume-up/volume-down keys.
# They can be disabled from the GUI: Settings > Sound Effects
