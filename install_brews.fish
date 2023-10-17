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
        go \
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
        gpg \
        git \
        ffmpeg \
        ffmpegthumbnailer \
        unar \
        jq \
        jc \
        poppler \
        tldr \
        hyperfine \
        httpie \
        nmap \
        ncdu \


brew install $packages
brew update
brew upgrade

pipx install --python python3.11 virtualfish # cuz python 3.12 not support torch
pipx install yt-dlp
vf install
vf addplugins compat_aliases projects environment auto_activation

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

