#!/usr/bin/bash

function link_files {
	src_directory=$1
	dst_directory=$2

	pushd $src_directory >/dev/null

	for f in $(find . -type f); do
		src=$(readlink -m "$PWD/$f")
		dst=$(readlink -m "$dst_directory/$f")

		if [ ! -e "$dst" ]; then
			mkdir -p $(dirname "$dst")
			ln -sv "$src" "$dst"
		fi
	done

	popd >/dev/null
}

link_files home $HOME
link_files bin $HOME/bin
link_files config $HOME/.config
