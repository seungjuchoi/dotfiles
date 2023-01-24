vim.cmd("autocmd!")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.expandtab = true
vim.opt.mouse = 'a'

vim.opt.title = true
vim.opt.smartindent = true
vim.opt.backup = false
vim.opt.cmdheight = 1
vim.opt.scrolloff = 10
vim.opt.shell = 'fish'
vim.opt.backupskip = { '/tmp/*', '/private/tmp/*' }
vim.opt.inccommand = 'split'
vim.opt.breakindent = true
vim.opt.wrap = false -- No Wrap lines
vim.opt.path:append { '**' } -- Finding files - Search down into subfolders
vim.opt.wildignore:append { '*/node_modules/*' }
vim.opt.termguicolors=true
vim.o.undofile = true
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.completeopt = 'menuone,noselect'
vim.o.list = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
