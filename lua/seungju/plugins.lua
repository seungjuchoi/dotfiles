vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use {
        'neovim/nvim-lspconfig',
        requires = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'j-hui/fidget.nvim',
            'folke/neodev.nvim',
        }
    }
    use 'tpope/vim-surround'
    use 'tpope/vim-fugitive'
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
        tag = 'nightly'
    }
    use {
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    }
    use 'godlygeek/tabular'
    use 'tpope/vim-repeat'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use {
        'hrsh7th/nvim-cmp',
        requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
    }
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    use 'tpope/vim-sleuth'
    use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons', config=function ()
        require("bufferline").setup{}
    end}
    use 'ap/vim-css-color'
    use 'rafi/awesome-vim-colorschemes'
    use 'ryanoasis/vim-devicons'
    use 'kyazdani42/nvim-web-devicons'
    use 'preservim/tagbar'
    use {'mg979/vim-visual-multi', branch = 'master'}
    use 'nvim-lua/plenary.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            pcall(require('nvim-treesitter.install').update { with_sync = true })
        end,
    }
    use {
        'nvim-treesitter/nvim-treesitter-textobjects',
        after = 'nvim-treesitter',
    }
    use 'lewis6991/gitsigns.nvim'
    use {'nvim-telescope/telescope.nvim', require = {{'nvim-lua/plenary.nvim'}}}
    use 'BurntSushi/ripgrep'
    use {"akinsho/toggleterm.nvim", tag = '*'}
    use 'TimUntersberger/neogit'
    use 'sindrets/diffview.nvim'
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'will133/vim-dirdiff'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'rust-lang/rust.vim'
    use 'jbyuki/venn.nvim'
    use {
        'rmagatti/alternate-toggler',
        config = function()
            require("alternate-toggler").setup {
                alternates = {
                    ["=="] = "!="
                }
            }
            vim.keymap.set(
            "n",
            "<leader>ta",
            "<cmd>lua require('alternate-toggler').toggleAlternate()<CR>"
            )
        end,
        event = { "BufReadPost" },
    }
    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    }
    use {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup {}
        end
    }
    use({
      "folke/noice.nvim",
      requires = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
        }
    })
end)
