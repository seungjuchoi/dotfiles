vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'neovim/nvim-lspconfig' -- LSP
    use 'tpope/vim-surround'
    use 'preservim/nerdtree'
    use {
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    }
    use 'PhilRunninger/nerdtree-visual-selection'
    use 'godlygeek/tabular'
    use 'preservim/vim-markdown'
    use 'tpope/vim-commentary'
    use 'tpope/vim-repeat'
    use 'Xuyuanp/nerdtree-git-plugin'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}
    use 'ap/vim-css-color'
    use 'rafi/awesome-vim-colorschemes'
    use {'neoclide/coc.nvim', branch = 'release'}
    use 'ryanoasis/vim-devicons'
    use 'kyazdani42/nvim-web-devicons'
    use 'preservim/tagbar'
    use {'mg979/vim-visual-multi', branch = 'master'}
    use 'nvim-lua/plenary.nvim'
    use 'tpope/vim-fugitive'
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use {'nvim-telescope/telescope.nvim', require = {{'nvim-lua/plenary.nvim'}}}
    use 'fannheyward/telescope-coc.nvim'
    use 'BurntSushi/ripgrep'
    use 'voldikss/vim-floaterm'
    use 'TimUntersberger/neogit'
    use 'sindrets/diffview.nvim'
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'will133/vim-dirdiff'
    use 'Yggdroot/indentLine'
    use 'rust-lang/rust.vim'
end)
