#!/bin/bash

SELECTED=$(pactl list short sinks |\
	awk '{print $1 " " $2 " " $7}' |\
	column -t |\
	sort -k3 -r |\
	rofi -dmenu -i |\
	awk '{print $2}'
)
echo $SELECTED
pactl set-default-sink $SELECTED
