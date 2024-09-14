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
    command ln -s -f $PWD/$f $xdg_path/$f
end
for f in **/*.vim
    command ln -s -f $PWD/$f $xdg_path/$f
end
command mkdir -p ~/.config/alacritty
command ln -s -f $PWD/alacritty.yml ~/.config/alacritty/alacritty.yml
command ln -s -f $PWD/starship.toml ~/.config/starship.toml
command ln -s -f $PWD/config.fish ~/.config/fish/config.fish
command ln -s -f $PWD/pipi.fish ~/.config/fish/functions/pipi.fish
command ln -s -f $PWD/prx.fish ~/.config/fish/functions/prx.fish
command ln -s -f $PWD/tmux.conf ~/.tmux.conf
command ln -s -f $PWD/wezterm.lua ~/.config/wezterm/wezterm.lua
command ln -s -f $PWD/clang-format ~/.clang-format
command ln -s -f $PWD/stylua.toml ~/.stylua.toml
command ln -s -f $PWD/luacheckrc ~/.luacheckrc
set yazi_plugins ~/.config/yazi/plugins
command mkdir -p $yazi_plugins
command ln -s -f $PWD/yazi.toml ~/.config/yazi/yazi.toml
if not test -d $yazi_plugins/glow.yazi
    command git clone https://github.com/Reledia/glow.yazi.git $yazi_plugins/glow.yazi
end
if not test -d $yazi_plugins/miller_csv.yazi
    command git clone https://github.com/Reledia/miller.yazi.git $yazi_plugins/miller_csv.yazi
end
if not test -d $yazi_plugins/hexyl.yazi
    command git clone https://github.com/Reledia/hexyl.yazi $yazi_plugins/hexyl.yazi
end
command mkdir -p ~/.config/atuin
command ln -s -f $PWD/atuin.toml ~/.config/atuin/config.toml

if test (uname) = "Linux"
    command ln -s -f $PWD/lock_screen.fish ~/.lock_screen.fish
end

git config --global core.quotepath false
git config --global core.autocrlf input
git config --global core.editor nvim
git config --global diff.tool nvimdiff
git config --global difftool.nvimdiff.cmd 'nvim -d "$LOCAL" "$REMOTE"'

tmux new-session -d -s init_config
tmux source ~/.tmux.conf
tmux run-shell '~/.tmux/plugins/tpm/bindings/install_plugins'
tmux kill-session
