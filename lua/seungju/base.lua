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
