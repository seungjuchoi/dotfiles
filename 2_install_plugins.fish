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

# virtualfish
vf addplugins compat_aliases projects environment auto_activation

# yazi
command ya pkg add yazi-rs/plugins:piper
