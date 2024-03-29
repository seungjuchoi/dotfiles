#!/usr/bin/env fish

# INFO: Install Fish and Brew before execution

switch (uname)
        case Linux
                command sudo apt update; sudo apt upgrade
                command sudo apt install git gcc curl python3-pip -y
end

ulimit -n 2048 # Prevent Error: Too many open files

set -l packages \
        zoxide \
        fd \
        ripgrep \
        nvim \
        fzf \
        tmux \
        pipx \
        yazi \
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
        gnu-sed \
        jq \
        yq \
        jc \
        noahgorstein/tap/jqp \
        poppler \
        tldr \
        hyperfine \
        httpie \
        nmap \
        ncdu \
        miller \
        glow \
        hexyl \
        exiftool \
        starship \

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
