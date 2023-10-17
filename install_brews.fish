# WARN: Install Fish and Brew before execution

set -l packages \
        zoxide \
        fd \
        ripgrep \
        nvim \
        fzf \
        tmux \
        pipx \
        yazi \
        exa \
        ranger \
        fisher \
        rust \
        lua \
        luarocks \
        llvm \
        neofetch \
        bat \
        mdcat \
        eza \
        lazygit \
        npm \


brew install $packages
brew update
brew upgrade

pipx install virtualfish
vf install

#tmux
# INFO: Enter tmux and then Hit Ctrl+t, I to install tmux-packges
if not test -d ~/.tmux/plugins/tpm
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
end

#fisher
set -l packages \
        jorgebucaran/autopair.fish \
        PatrickF1/fzf.fish \
        jorgebucaran/nvm.fish \
fisher install $packages

#pm2
npm install pm2 -g

