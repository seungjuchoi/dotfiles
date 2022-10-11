#!/usr/local/bin/fish
set xdg_path ~/.config/nvim/
for f in $xdg_path/after/plugin/*.lua
    echo copy $f to here
    cp $f $PWD/after/plugin
end
for f in $xdg_path/after/plugin/*.vim
    echo copy $f to here
    cp $f $PWD/after/plugin
end
for f in $xdg_path/plugin/*.lua
    echo copy $f to here
    cp $f $PWD/plugin
end
for f in $xdg_path/plugin/*.vim
    echo copy $f to here
    cp $f $PWD/plugin
end
for f in $xdg_path/lua/seungju/*.lua
    echo copy $f to here
    cp $f $PWD/lua/seungju
end
for f in $xdg_path/lua/seungju/*.vim
    echo copy $f to here
    cp $f $PWD/lua/seungju
end
echo copy alacritty.yml to here
cp ~/.config/alacritty/alacritty.yml $PWD/alacritty.yml
