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

if type -q herdr
    herdr update
end

if test -x ~/.local/bin/tmuxcc-update
    ~/.local/bin/tmuxcc-update
else if type -q cargo
    set -l script_dir (status dirname)
    bash $script_dir/tmuxcc_update.sh
end

if test -x ~/.local/bin/kiro-gateway-update
    ~/.local/bin/kiro-gateway-update
else
    set -l script_dir (status dirname)
    if test -f $script_dir/kiro_gateway_update.fish
        fish $script_dir/kiro_gateway_update.fish
    end
end
