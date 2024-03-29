#!/usr/bin/env fish
command brew update; brew upgrade
fisher update
command ~/.tmux/plugins/tpm/bin/update_plugins all

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
