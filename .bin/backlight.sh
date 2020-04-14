#!/bin/bash

current=`xbacklight -get`
# alternatively, if xbacklight does not work:
# current=`qdbus org.gnome.SettingsDaemon.Power /org/gnome/SettingsDaemon/Power org.gnome.SettingsDaemon.Power.Screen.GetPercentage`

scale="1 2 5 10 20 50 100"

case $1 in
    "down")
        # translate space to newline so tac will reverse order of lines (values)
        for val in $(tr ' ' '\n' <<< $scale | tac) ; do
            # scale = 3 to preserve some decimal values
            if (( $(bc <<< "scale=3 ; $val < $current/1.1") )) ; then
                newval=$val
                break
            fi
        done
        ;;
    "up")
        for val in $scale ; do
            # scale = 3 to preserve some decimal values
            if (( $(bc <<< "scale=3 ; $val > $current*1.1") )) ; then
                newval=$val
                break
            fi
        done
        ;;
    *)
        echo "Usage: $0 [up, down]"
        exit 1
esac

if [ "x$newval" == "x" ] ; then
    echo "Already at min/max."
else
    echo "Setting backlight to $newval."

    # thanks: https://bbs.archlinux.org/viewtopic.php?pid=981217#p981217
    notify-send " " -i notification-display-brightness-low -h int:value:$newval -h string:x-canonical-private-synchronous:brightness &

    xbacklight -set $newval -steps 1 -time 0
    # alternatively, if xbacklight does not work:
    # qdbus org.gnome.SettingsDaemon.Power /org/gnome/SettingsDaemon/Power org.gnome.SettingsDaemon.Power.Screen.SetPercentage $newval
fi

exit 0
