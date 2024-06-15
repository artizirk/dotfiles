#!/bin/bash
OLD_VOL=0
pactl subscribe | grep --line-buffered "sink" |
while read; do
	VOL=$(amixer get Master | grep -Po "[0-9]+(?=%)" | tail -1)
	if [[ $VOL != $OLD_VOL ]]; then
		swayosd-client --output-volume=+0
		OLD_VOL=$VOL
	fi
done
