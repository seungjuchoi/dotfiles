#!/usr/bin/env fish

if set -q DISPLAY
        set display_orig $DISPLAY
        set display_was_set true
else
        set display_was_set false
end

set -x DISPLAY :1

if command -qs i3lock
        command i3lock &
else
        echo Not found i3lock
        exit
end

command sleep 1

command xset dpms force off

if test $display_was_set = true
        set -x DISPLAY $display_orig
else
        set -e DISPLAY
end

set -e display_was_set display_orig
