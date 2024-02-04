#!/usr/bin/env fish
set xdg_path ~/.config/nvim
if test -d $xdg_path/lua/seungju
    command rm -rf $xdg_path/lua/seungju
end
command mkdir -p $xdg_path/lua/seungju
if test -d $xdg_path/plugin
    command rm -rf $xdg_path/plugin
end
command mkdir -p $xdg_path/plugin
command mkdir -p ~/.config/wezterm
for f in **/*.lua
    command sudo ln -s -f $PWD/$f $xdg_path/$f
end
for f in **/*.vim
    command sudo ln -s -f $PWD/$f $xdg_path/$f
end
command mkdir -p ~/.config/alacritty
command sudo ln -s -f $PWD/alacritty.yml ~/.config/alacritty/alacritty.yml
command sudo ln -s -f $PWD/starship.toml ~/.config/starship.toml
command sudo ln -s -f $PWD/config.fish ~/.config/fish/config.fish
command sudo ln -s -f $PWD/pipi.fish ~/.config/fish/functions/pipi.fish
command sudo ln -s -f $PWD/tmux.conf ~/.tmux.conf
command sudo ln -s -f $PWD/wezterm.lua ~/.config/wezterm/wezterm.lua
command mkdir -p ~/.config/ranger
command sudo ln -s -f $PWD/ranger_rc.conf ~/.config/ranger/rc.conf
command sudo ln -s -f $PWD/clang-format ~/.clang-format
command sudo ln -s -f $PWD/stylua.toml ~/.stylua.toml
command sudo ln -s -f $PWD/luacheckrc ~/.luacheckrc
command mkdir -p ~/.config/yazi/plugins
command sudo ln -s -f $PWD/yazi.toml ~/.config/yazi/yazi.toml
command git clone git@github.com:Reledia/glow.yazi.git ~/.config/yazi/plugins/glow.yazi
command git clone git@github.com:Reledia/miller.yazi.git ~/.config/yazi/plugins/miller_csv.yazi
command git clone git@github.com:Reledia/hexyl.yazi ~/.config/yazi/plugins/hexyl.yazi
