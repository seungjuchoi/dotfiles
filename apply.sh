### Copy rc files
mkdir -p ~/.config/nvim
cp init.vim ~/.config/nvim/

### Install vim plugins
nvim +PlugClean
nvim +PlugInstall
