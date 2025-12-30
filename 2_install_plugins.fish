#!/usr/bin/env fish
# tmux
if not test -d ~/.tmux/plugins/tpm
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
end

# fisher
set -l packages \
        jorgebucaran/fisher \
        jorgebucaran/autopair.fish \
        PatrickF1/fzf.fish \
        jorgebucaran/nvm.fish \

fisher install $packages

# yazi
command ya pkg add yazi-rs/plugins:piper
command ya pkg add KKV9/compress

