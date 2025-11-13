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
command ln -s -f $PWD/starship.toml ~/.config/starship.toml
command ln -s -f $PWD/config.fish ~/.config/fish/config.fish
command ln -s -f $PWD/pipi.fish ~/.config/fish/functions/pipi.fish
command ln -s -f $PWD/prx.fish ~/.config/fish/functions/prx.fish
command ln -s -f $PWD/tmux.conf ~/.tmux.conf
command ln -s -f $PWD/wezterm.lua ~/.config/wezterm/wezterm.lua
command ln -s -f $PWD/clang-format ~/.clang-format
command ln -s -f $PWD/yazi.toml ~/.config/yazi/yazi.toml
command ln -s -f $PWD/aerospace.toml ~/.aerospace.toml
command mkdir -p ~/.config/kanata
command ln -s -f $PWD/config.kbd ~/.config/kanata/config.kbd
command mkdir -p ~/.config/mpv
command ln -s -f $PWD/mpv.conf ~/.config/mpv/mpv.conf
command ln -s -f $PWD/mpv_input.conf ~/.config/mpv/input.conf
command mkdir -p ~/.config/ghostty
command ln -s -f $PWD/ghostty_config ~/.config/ghostty/config

if test -f ~/.config/fish/config_local.fish
    command ln -s -f ~/.config/fish/config_local.fish $PWD/config_local.fish
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
