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
vim.o.clipboard = 'unnamedplus'
if os.getenv("TMUX") then
  vim.g.clipboard = {
    name = 'tmux',
    copy = {
      ['+'] = 'tmux load-buffer -w -',
      ['*'] = 'tmux load-buffer -w -',
    },
    paste = {
      ['+'] = 'tmux save-buffer -',
      ['*'] = 'tmux save-buffer -',
    },
    cache_enabled = 1,
  }
elseif os.getenv("SSH_TTY") then
  -- ssh 세션: yank 를 OSC52 로 로컬 터미널 클립보드에 보낸다.
  -- 붙여넣기는 터미널에 클립보드를 묻지 않고 nvim 레지스터에서 가져온다.
  local osc52 = require('vim.ui.clipboard.osc52')
  local function paste()
    return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
  end
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
