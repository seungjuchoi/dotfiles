apt update
apt install git curl python3-pip
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
brew install fish
echo $(which fish) > tee -s /etc/shells
chsh -s $(which fish)
exec fish -C "git clone http://github.com/seungjuchoi/dotfiles;cd dotfiles;fish_add_path /home/linuxbrew/.linuxbrew/bin;fish_add_path ~/.local/bin"

