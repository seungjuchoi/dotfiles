#!/usr/local/bin/fish
command mkdir -p ~/.config/nvim
command mkdir -p ~/.config/nvim/lua/seungju
command mkdir -p ~/.config/nvim/after/plugin
command mkdir -p ~/.config/nvim/plugin
command mkdir -p ~/.config/wezterm
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
command sudo ln -s -f $PWD/config.fish ~/.config/fish/config.fish
command sudo ln -s -f $PWD/tmux.conf ~/.tmux.conf
command sudo ln -s -f $PWD/tmux.statusline.conf ~/.tmux.statusline.conf
command sudo ln -s -f $PWD/wezterm.lua ~/.config/wezterm/wezterm.lua

if command -qs espanso
    switch (uname)
        case Linux
            command sudo ln -s -f $PWD/espanso ~/.config/espanso
        case Darwin
            command sudo ln -s -f $PWD/espanso $HOME/Library/Application\ Support/espanso
        case '*'
            echo Skip Espanso Config
    end
end
