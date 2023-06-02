#!/bin/sh
# src: https://codeberg.org/trill/dotfiles/src/branch/master/.local/bin/i3blocks/pipewire-sink.sh

# `pactl list sinks` shows sink properties with a mix of english language and local language
# defined by LANG env var, so we unset the var to guarantee only the fallback language is used
unset LANG;
sink_list="$(wpctl status | sed -n '/^Audio/,/Sink endpoints:/p' | sed -n '/Sinks:/,/|\s*$/p' | head -n -2 | tail -n +2 | tr -d '│')"


CONTENT="$sink_list"
OPTION_SELECTED=$(echo "$CONTENT" \
  | rofi -dmenu -location 2  \
  | sed -e 's/[^0-9]*\([0-9]*\).*/\1/g')

echo ""
if ! [[ -z "$OPTION_SELECTED" ]]; then
    wpctl set-default "$OPTION_SELECTED"
fi

