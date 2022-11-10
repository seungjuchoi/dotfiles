#!/usr/local/bin/fish
# command sudo ln -s -f $PWD/init.vim ~/.config/nvim/init.vim
# echo init.vim loaded
command mkdir -p ~/.config/nvim
command mkdir -p ~/.config/nvim/lua/seungju
command mkdir -p ~/.config/nvim/after/plugin
command mkdir -p ~/.config/nvim/plugin
set xdg_path ~/.config/nvim/
for f in **/*.lua
    command sudo ln -s -f $PWD/$f $xdg_path$f
end
for f in **/*.vim
    command sudo ln -s -f $PWD/$f $xdg_path$f
end
command mkdir -p ~/.config/alacritty
command sudo ln -s -f $PWD/alacritty.yml ~/.config/alacritty/alacritty.yml
command sudo ln -s -f $PWD/starship.toml ~/.config/starship.toml
