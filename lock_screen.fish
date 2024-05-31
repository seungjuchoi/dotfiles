#!/usr/bin/env fish

if command -qs i3lock
        command i3lock &
else
        echo Not found i3lock
        exit
end

command sleep 1

command xset dpms force off
