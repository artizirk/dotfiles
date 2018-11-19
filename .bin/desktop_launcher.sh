#!/bin/bash
oIFS=$IFS
IFS=:
data_dirs=($XDG_DATA_DIRS)
IFS=$oIFS
data_dirs+=("${HOME}/.local/share")

fzf_history="${HOME}/.desktop_launcher_history"

for folder in ${data_dirs[*]}; do find "${folder%/}/applications" -name '*.desktop' -print0; done \
    | xargs -0 basename -z -s .desktop -a \
    | sort -r -z \
    | fzf +m --read0 --history="${fzf_history}" \
    | xargs -r swaymsg -t command exec gtk-launch
