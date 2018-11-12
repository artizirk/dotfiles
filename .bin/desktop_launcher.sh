#!/bin/bash
oIFS=$IFS
IFS=:
data_dirs=($XDG_DATA_DIRS)
IFS=$oIFS
data_dirs+=("~/.local/share")
(
    for folder in ${data_dirs[*]}; do 
        find ${folder%/}/applications -name \*.desktop;
    done
) | xargs basename -s .desktop -a | fzf | xargs -r swaymsg -t command exec gtk-launch

