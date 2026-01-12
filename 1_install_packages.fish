#!/usr/bin/env fish

# INFO: Install Fish and Brew before execution

if not type -q brew
        echo Install Brew and insert bin folder to PATH
        exit
end
fish_add_path ~/.local/bin
fish_add_path (brew --prefix)/bin

if test (uname) = "Linux"
        command sudo apt update; sudo apt upgrade
        command sudo apt install -y git gcc curl xsel xbindkeys xdotool
        command sudo apt install -y fonts-nanum fonts-noto-cjk
        command sudo apt install -y fcitx5 fcitx5-hangul
        command curl -fsSL https://bun.sh/install | bash
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
        miller \
        ncdu \
        fastfetch \
        nmap \

brew install $packages
set -l packages \
        noahgorstein/tap/jqp \
        npm \
        nvim \
        poppler \
        ripgrep \
        rust \
        uv \
        starship \
        thefuck \
        tealdeer \
        tmux \
        unar \
        yazi \
        yq \
        zoxide \

brew install $packages
brew update
brew upgrade

uv tool install yt-dlp

# npm prefix
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
fish_add_path ~/.npm-global/bin
