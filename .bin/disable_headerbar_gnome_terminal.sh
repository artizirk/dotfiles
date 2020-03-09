#!/bin/sh
# disables headerbar on gnome-terminal 3.32 and newer
# you need to close all open terminal windows before this takes effect
dconf write /org/gnome/terminal/legacy/headerbar '@mb false'
