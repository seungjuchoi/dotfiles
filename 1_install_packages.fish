#!/usr/bin/env fish

# INFO: Install Fish and Brew before execution

switch (uname)
        case Linux
                command sudo apt update; sudo apt upgrade
                command sudo apt install git gcc curl python3-pip -y
end

ulimit -n 2048 # Prevent Error: Too many open files

set -l packages \
        bat \
        exiftool \
        eza \
        fd \
        ffmpeg \
        ffmpegthumbnailer \
        fisher \
        fzf \
        git \
        glow \
        gnu-sed \
        go \
        gpg \
        hexyl \
        httpie \
        hyperfine \
        jc \
        jq \
        lazygit \
        llvm \
        lua \
        luarocks \
        mdcat \
        miller \
        ncdu \
        neofetch \
        nmap \
        noahgorstein/tap/jqp \
        npm \
        nvim \
        pipx \
        poppler \
        ranger \
        ripgrep \
        rust \
        starship \
        tldr \
        tmux \
        unar \
        yazi \
        yq \
        zoxide \

brew install $packages
brew update
brew upgrade

pipx install yt-dlp

#pm2
npm install pm2 -g

#virtualfish
pip install virtualfish
vf install
exec fish -C vf
