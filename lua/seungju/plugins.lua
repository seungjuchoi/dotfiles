local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
      "folke/neodev.nvim",
    },
  },
  "tpope/vim-surround",
  "tpope/vim-fugitive",
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    version = "nightly",
  },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  "godlygeek/tabular",
  "tpope/vim-repeat",
  "nvim-tree/nvim-web-devicons",
  {
    "rafi/awesome-vim-colorschemes",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  "nvim-lualine/lualine.nvim",
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  "tpope/vim-sleuth",
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {},
  },
  "ap/vim-css-color",
  "ryanoasis/vim-devicons",
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<F8>", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },
  { "mg979/vim-visual-multi", branch = "master" },
  "nvim-lua/plenary.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      pcall(require("nvim-treesitter.install").update({ with_sync = true }))
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter",
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },
  "BurntSushi/ripgrep",
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      close_on_exit = true, -- close the terminal window when the process exits
      shell = vim.o.shell, -- change the default shell
      auto_scroll = true, -- automatically scroll to the bottom on terminal output
    },
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      local df = require("diffview")
      local actions = require("diffview.actions")
      df.setup({
        keymaps = {
          file_panel = {
            ["s"] = false,
            { "n", " ", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
          },
        },
      })
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  "nvim-telescope/telescope-file-browser.nvim",
  "will133/vim-dirdiff",
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "┊" },
    },
  },
  "rust-lang/rust.vim",
  "jbyuki/venn.nvim",
  {
    "rmagatti/alternate-toggler",
    config = function()
      require("alternate-toggler").setup({
        alternates = {
          ["=="] = "!=",
        },
      })
      vim.keymap.set("n", "<leader>ta", "<cmd>lua require('alternate-toggler').toggleAlternate()<CR>")
    end,
    event = { "BufReadPost" },
  },
  {
    "windwp/nvim-autopairs",
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {},
  },
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({})
    end,
  },
  "luk400/vim-jukit",
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<f4>", "<cmd>UndotreeToggle<CR>")
    end,
  },
  "lambdalisue/suda.vim",
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      highlight = {
        groups = {
          label = "FlashBackdrop",
        },
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "stevearc/dressing.nvim",
    opts = {},
  },
  "RRethy/vim-illuminate",
  "farmergreg/vim-lastplace",
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          markdown = { "prettier" },
          yaml = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          lua = { "stylua" },
          python = { "isort", "black" },
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format({
          lsp_fallback = true,
          timeout_ms = 500,
        })
      end)
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        python = { "pylint" },
        typescript = { "eslint_d" },
        javascript = { "eslint_d" },
        lua = { "luacheck" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd(opts.events, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  "nanotee/zoxide.vim",
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      {
        "mfussenegger/nvim-dap",
      },
      "jay-babu/mason-nvim-dap.nvim",
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      }
    },
  },
})
