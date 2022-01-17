### Update Pakcage
sudo apt update
sudo apt upgrade
sudo apt install neovim git curl nodejs npm exuberant-ctags cmake

### Copy rc files
mkdir -p ~/.config/nvim
cp init.vim ~/.config/nvim/

### Install vim plugins
nvim +PlugInstall
