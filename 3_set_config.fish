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
command ln -s -f $PWD/tmux_kiro_sessions.sh ~/.tmux/kiro-sessions.sh
command mkdir -p ~/.local/bin
command ln -s -f $PWD/tmuxcc_update.sh ~/.local/bin/tmuxcc-update
command ln -s -f $PWD/tmuxcc_launch.sh ~/.local/bin/tmuxcc-launch
command ln -s -f $PWD/tmux_file_picker_popup.sh ~/.local/bin/tmux-file-picker-popup
# prefix+e 팝업이 부르는 tmux-file-picker(raine) 본체. 저장소에 없으므로 없을 때만 받는다.
if not test -x ~/.local/bin/tmux-file-picker
    command curl -fsSLo ~/.local/bin/tmux-file-picker \
        https://raw.githubusercontent.com/raine/tmux-file-picker/main/tmux-file-picker
    and command chmod +x ~/.local/bin/tmux-file-picker
end
command ln -s -f $PWD/clipsend.sh ~/.local/bin/clipsend
command ln -s -f $PWD/ta.sh ~/.local/bin/ta
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
command mkdir -p ~/.config/herdr
command ln -s -f $PWD/herdr_config.toml ~/.config/herdr/config.toml
command ln -s -f $PWD/herdr_main_tab.sh ~/.config/herdr/main-tab.sh
command ln -s -f $PWD/herdr_file_picker.sh ~/.config/herdr/file-picker.sh
# 로컬 herdr 플러그인. link 는 경로를 기록하므로 다시 실행해도 같은 결과다.
if type -q herdr
    for p in $PWD/herdr_plugins/*/herdr-plugin.toml
        command herdr plugin link (dirname $p) >/dev/null
        or echo "herdr plugin link failed: "(dirname $p)
    end
    # GitHub 플러그인. herdr-pluck: prefix+\ 힌트 복사 (tmux-fingers 대응)
    # 포크(seungjuchoi) 브랜치를 쓴다: SSH 로 들어간 헤드리스 Linux 에서 OSC 52 로 복사하도록 고친 것.
    # 포크엔 릴리스 바이너리가 없어 소스 빌드(cargo)로 설치한다. 업스트림이 설치돼 있으면 바꿔 끼운다.
    set pluck_src seungjuchoi/herdr-pluck
    set pluck_ref osc52-clipboard-fallback
    set pluck_line (command herdr plugin list 2>/dev/null | string match '*rmarganti.herdr-pluck*')
    if test -n "$pluck_line"; and not string match -q "*github:$pluck_src@*" -- $pluck_line
        command herdr plugin uninstall rmarganti.herdr-pluck >/dev/null
    end
    if not command herdr plugin list 2>/dev/null | string match -q "*github:$pluck_src@*"
        env HERDR_PLUCK_BUILD_FROM_SOURCE=1 herdr plugin install $pluck_src --ref $pluck_ref --yes >/dev/null
        or echo "herdr plugin install failed: $pluck_src@$pluck_ref"
    end
    set pluck_cfg (command herdr plugin config-dir rmarganti.herdr-pluck 2>/dev/null)
    if test -n "$pluck_cfg"
        command mkdir -p $pluck_cfg
        command ln -s -f $PWD/herdr_pluck.toml $pluck_cfg/config.toml
    end
end

if test -f ~/.config/fish/config_local.fish
    command ln -s -f ~/.config/fish/config_local.fish $PWD/config_local.fish
end

git config --global core.quotepath false
git config --global core.autocrlf input
git config --global core.editor nvim
git config --global diff.tool nvimdiff
git config --global difftool.nvimdiff.cmd 'nvim -d "$LOCAL" "$REMOTE"'

tmux new-session -d -s init_config
# tpm 의 bin/ 은 명령줄용이라 tmux.conf 를 다시 읽지 않는다.
# bindings/ 는 키바인딩용이라 앞뒤로 한 번씩 다시 읽어서, reload 한 번(약 2.5초)이 네 번 더 붙는다.
~/.tmux/plugins/tpm/bin/install_plugins
# tmux.conf 의 @plugin 선언에서 빠진 플러그인 디렉터리를 지운다 (tpm 자신은 제외).
~/.tmux/plugins/tpm/bin/clean_plugins
# 새로 받은 플러그인을 실행 중인 서버에 올린다. reload 는 이 한 번뿐이다.
tmux source ~/.tmux.conf
tmux kill-session -t init_config
