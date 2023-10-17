# WARN: Install Fish before execution

set -l packages zoxide \
        fd \
        ripgrep \
        nvim \
        fzf \
        tmux \
        pipx \
        yazi \
        exa \
        ranger \

brew install $packages
brew update
brew upgrade

pipx install virtualfish

#tmux
if test -d ~/.tmux/plugins/tpm
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
end
# INFO: Enter tmux and then Hit Ctrl+t, I to install tmux-packges
