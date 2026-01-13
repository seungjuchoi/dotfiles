#!/usr/bin/env fish
if type -q brew
    command brew update; and brew upgrade
end

if type -q fisher
    fisher update
end

if type -q tmux
    command ~/.tmux/plugins/tpm/bin/update_plugins all
end

if type -q ya
    command ya pkg upgrade
end

if type -q nvim
    nvim --headless "+Lazy! sync" +qa
end
