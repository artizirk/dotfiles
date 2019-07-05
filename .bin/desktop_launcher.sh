#!/bin/bash
fzf_history="${HOME}/.desktop_launcher_history"

i3-dmenu-desktop --dmenu="fzf +m --history=\"${fzf_history}\""
