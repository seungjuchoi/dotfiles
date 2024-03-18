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

brew install $packages
brew update
brew upgrade

python3 -m pip install virtualfish
pipx install yt-dlp
vf install
exec fish
vf addplugins compat_aliases projects environment auto_activation
exec fish

#tmux
# INFO: Enter tmux and then Hit Ctrl+t, I to install tmux-packges
if not test -d ~/.tmux/plugins/tpm
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
        command ~/.tmux/plugins/tpm/bin/update_plugins all
end

#fisher
set -l packages \
        jorgebucaran/autopair.fish \
        PatrickF1/fzf.fish \
        jorgebucaran/nvm.fish \
fisher install $packages
fisher update

#pm2
npm install pm2 -g

