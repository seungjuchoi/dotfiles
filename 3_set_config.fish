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
command ln -s -f $PWD/prx.fish ~/.config/fish/functions/prx.fish
command ln -s -f $PWD/prxh.fish ~/.config/fish/functions/prxh.fish
command ln -s -f $PWD/tmux.conf ~/.tmux.conf
command mkdir -p ~/.tmux
command ln -s -f $PWD/tmux_renumber_sessions.sh ~/.tmux/renumber-sessions.sh
command ln -s -f $PWD/tmux_agent_window.sh ~/.tmux/agent-window.sh
command ln -s -f $PWD/tmux_assistant_restore_once.sh ~/.tmux/assistant-restore-once.sh
command mkdir -p ~/.local/bin
command ln -s -f $PWD/tmuxcc_update.sh ~/.local/bin/tmuxcc-update
command ln -s -f $PWD/tmuxcc_launch.sh ~/.local/bin/tmuxcc-launch
command ln -s -f $PWD/kiro_gateway_update.fish ~/.local/bin/kiro-gateway-update
command ln -s -f $PWD/clipsend.sh ~/.local/bin/clipsend
command mkdir -p ~/.config/fish/completions
command ln -s -f $PWD/clipsend_completion.fish ~/.config/fish/completions/clipsend.fish
command ln -s -f $PWD/wezterm.lua ~/.config/wezterm/wezterm.lua
command ln -s -f $PWD/clang-format ~/.clang-format
command ln -s -f $PWD/yazi.toml ~/.config/yazi/yazi.toml
command ln -s -f $PWD/yazi_keymap.toml ~/.config/yazi/keymap.toml
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
# tmux.conf 의 @plugin 선언에서 빠진 플러그인 디렉터리를 지운다 (tpm 자신은 제외).
tmux run-shell '~/.tmux/plugins/tpm/bindings/clean_plugins'
tmux kill-session -t init_config
