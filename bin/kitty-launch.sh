#!/bin/sh

mkdir /tmp/kitty -p
sock=$(mktemp -u /tmp/kitty/XXXXXX.sock)

kitty --listen-on="unix:$sock"
