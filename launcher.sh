### Update vim pakcage
sudo apt update
sudo apt install vim
sudo apt install exuberant-ctags

### Install Vundle package
VUNDLE_PATH="$HOME/.vim/bundle/Vundle.vim"
if [ ! -d "$VUNDLE_PATH" ]; then
	git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_PATH
fi

### Copy rc files
cp .vimrc ~
cp .screenrc ~


### Install vim plugins
vim +PluginInstall


### Git setting
git config --global user.email "redreamer@gmail.com"
git config --global user.name "seungjuchoi"
git config --global push.default matching
