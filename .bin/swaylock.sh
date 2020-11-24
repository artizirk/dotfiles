#!/bin/bash
# Uses forked swaylock https://github.com/mortie/swaylock-effects
bg=$1
exec swaylock \
	--clock \
	--datestr "%Y-%m-%d" \
	--indicator \
	--scaling tile \
	--hide-keyboard-layout \
	--font "Terminus" \
	--font-size 28 \
	--text-color ffffff \
	--inside-color 435366 \
	--separator-color 435366 \
	--ring-color 435366 \
	--line-uses-ring \
	--image $bg
