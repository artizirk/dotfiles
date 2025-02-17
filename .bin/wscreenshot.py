#!/usr/bin/env python3
"""
Sway screenshot tool. Saved screenshots are also added to GTK recents list for easy access.

Uses following tools
* grim
* slurp
* https://codeberg.org/vyivel/dulcepan
* jq


Region selection uses dulcepan. It works by first freezing the screen so that popups sway visible.
Then it allows selection of the region you want to screenshot.
"""

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib

import time
import sys
import os
import json
import atexit
from subprocess import run, Popen, PIPE
from urllib.parse import urljoin

image_viewers = []
def kill_image_viewers():
    for viewer in image_viewers:
        viewer.terminate()
atexit.register(kill_image_viewers)

file_name = GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_PICTURES)
file_name = os.path.join(file_name, time.strftime('screenshot_%Y-%m-%d-%H%M%S_grim.png'))

if len(sys.argv) < 2:
    run(["grim", file_name], check=True)
else:
    if sys.argv[1] in ('-h','--help'):
        print("Usage: {} [-h|--help|--region|--window]".format(sys.argv[0]))
        sys.exit(0)

    elif sys.argv[1] == '--region':
        run(["dulcepan", "-o", file_name], check=True)

    elif sys.argv[1] == '--window':
        tree = run(['swaymsg', '-t', 'get_tree'], check=True, capture_output=True)
        regions = run(['jq', '-r', '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'],
                check=True, capture_output=True, input=tree.stdout)
        region = run('slurp', check=True, capture_output=True, input=regions.stdout)
        run(["grim", '-g', '-', file_name], check=True, input=region.stdout)

    else:
        sys.exit(1)

# Add created screenshot to Gtk recents list
recent_mgr = Gtk.RecentManager.get_default()
uri = urljoin("file:", file_name)
recent_mgr.add_item(uri)
GLib.idle_add(Gtk.main_quit)
Gtk.main()
