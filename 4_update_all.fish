#!/usr/bin/env fish
if type -q brew
    command brew update; brew upgrade
end
fisher update
if type -q tmux
    command ~/.tmux/plugins/tpm/bin/update_plugins all
end
if type -q ya
    command ya pack --upgrade
end
