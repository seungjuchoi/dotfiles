#!/usr/bin/env fish
if type -q brew
    command brew update; brew upgrade
end
fisher update
if type -q tmux
    command ~/.tmux/plugins/tpm/bin/update_plugins all
end

set current_folder (pwd)
set yazi_plugins ~/.config/yazi/plugins
if test -d $yazi_plugins/glow.yazi
    cd $yazi_plugins/glow.yazi
    git pull
end
if test -d $yazi_plugins/miller_csv.yazi
    cd $yazi_plugins/miller_csv.yazi
    git pull
end
if test -d $yazi_plugins/hexyl.yazi
    cd $yazi_plugins/hexyl.yazi
    git pull
end

cd $current_folder
