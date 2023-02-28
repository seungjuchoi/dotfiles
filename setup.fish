#!/usr/local/bin/fish
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
command sudo ln -s -f $PWD/tmux.conf ~/.tmux.conf
command sudo ln -s -f $PWD/tmux.statusline.conf ~/.tmux.statusline.conf
command sudo ln -s -f $PWD/wezterm.lua ~/.config/wezterm/wezterm.lua

if command -qs espanso
    switch (uname)
        case Linux
            command sudo ln -s -f $PWD/espanso/ ~/.config/espanso
        case Darwin
            command rm -rf $HOME/Library/Application\ Support/espanso
            command sudo ln -s -f $PWD/espanso/ $HOME/Library/Application\ Support/espanso
        case '*'
            echo Skip Espanso Config
    end
end
