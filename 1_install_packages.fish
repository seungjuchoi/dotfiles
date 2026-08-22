#!/usr/bin/env fish

# INFO: Install Fish and Brew before execution

if not type -q brew
        echo Install Brew and insert bin folder to PATH
        exit
end
fish_add_path ~/.local/bin
fish_add_path (brew --prefix)/bin

if test (uname) = "Linux"
        command sudo apt update; sudo apt upgrade -y
        command sudo apt install -y git gcc curl xsel xbindkeys xdotool
        command sudo apt install -y fonts-nanum fonts-noto-cjk
        command sudo apt install -y fcitx5 fcitx5-hangul
        command sudo apt install -y luarocks python3-venv
        command sudo luarocks install luacheck
        command curl -fsSL https://bun.sh/install | bash
end

ulimit -n 2048 # Prevent Error: Too many open files

brew install gcc
# third-party taps must be trusted before install (Homebrew >= 4.6)
brew tap noahgorstein/tap; and brew trust noahgorstein/tap
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
        glab \
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
        rlwrap \
        rust \
        uv \
        starship \
        thefuck \
        tealdeer \
        tmux \
        tree-sitter-cli \
        unar \
        yazi \
        yq \
        zoxide \

brew install $packages
brew update
brew upgrade

uv tool install yt-dlp

# tmuxcc — 포크를 ~/.local/src/tmuxcc 에 clone 후 cargo install
set -l script_dir (status dirname)
fish_add_path ~/.cargo/bin
if type -q cargo
    bash $script_dir/tmuxcc_update.sh
else
    echo "skip tmuxcc: cargo not found"
end

# kiro-gateway — Claude Code → Kiro proxy used by `ck`
if type -q git
    fish $script_dir/kiro_gateway_update.fish
else
    echo "skip kiro-gateway: git not found"
end

# npm prefix
if not test -d ~/.npm-global
    mkdir -p ~/.npm-global
end
npm config set prefix '~/.npm-global'
fish_add_path ~/.npm-global/bin
# fish_add_path returns 1 when the path is already present; do not let that be the script status
exit 0
