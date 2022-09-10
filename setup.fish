#!/usr/local/bin/fish
command sudo ln -s -f $PWD/init.vim ~/.config/nvim/init.vim
echo init.vim loaded
command sudo ln -s -f $PWD/tmux.conf ~/.tmux.conf 
echo tmux.conf loaded
command sudo ln -s -f $PWD/tmux.statusline.conf ~/.tmux.statusline.conf 
echo tmux.statusline.conf loaded
command sudo ln -s -f $PWD/config.fish ~/.config/fish/config.fish
echo config.fish loaded
