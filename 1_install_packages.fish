#!/usr/bin/env fish

# INFO: Install Fish and Brew before execution

if not type -q brew
        echo Install Brew and insert bin folder to PATH
        exit
end
fish_add_path ~/.local/bin

switch (uname)
        case Linux
end

if test (uname) = "Linux"
        command sudo apt update; sudo apt upgrade
        command sudo apt install git gcc curl python3-pip xsel i3lock -y
end


ulimit -n 2048 # Prevent Error: Too many open files

brew install gcc
set -l packages \
        bat \
        btop \
        difftastic \
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

brew install $packages
set -l packages \
        hexyl \
        httpie \
        hyperfine \
        jc \
        jless \
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

brew install $packages
set -l packages \
        noahgorstein/tap/jqp \
        npm \
        nvim \
        pipx \
        poppler \
        ranger \
        ripgrep \
        rust \
        starship \
        thefuck \
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
