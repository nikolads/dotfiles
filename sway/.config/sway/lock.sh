#!/bin/sh

# Screen lock command
if ! pgrep -x swaylock; then
    # --indicator-radius is workaroud for https://github.com/swaywm/swaylock/issues/168
    swaylock --daemonize --image $HOME/pictures/lock-screen --scaling stretch --indicator-radius 80
fi

