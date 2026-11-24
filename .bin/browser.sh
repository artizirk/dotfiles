#!/bin/zsh

for firefox_bin in firefox-devedition firefox-developer-edition; do
	if builtin whence -p $firefox_bin; then
		exec swaymsg exec $firefox_bin "$@"
	fi
done
