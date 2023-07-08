local k = vim.keymap
k.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

k.set('n', '<leader>cd', ':cd %:p:h<CR>:pwd<CR>', {noremap = true})
k.set('n', 'x', '"_x', {noremap = true})

k.set('n', '[b', ':bp<CR>', {silent = true, noremap = true})
k.set('n', ']b', ':bn<CR>', {silent = true, noremap = true})
k.set('n', '[t', ':tabp<CR>', {silent = true, noremap = true})
k.set('n', ']t', ':tabn<CR>', {silent = true, noremap = true})

k.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
k.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

k.set('n', 'sh', '<C-W>h')
k.set('n', 'sj', '<C-W>j')
k.set('n', 'sk', '<C-W>k')
k.set('n', 'sl', '<C-W>l')

k.set('n', '<F3>', ":NvimTreeToggle<CR>", {noremap = true})
k.set('n', "<F8>", ":TagbarToggle<CR>")

k.set('n', "<leader>df", ":DiffviewOpen<CR>")
k.set('n', "<leader>dx", ":DiffviewClose<CR>")
k.set('n', "<leader>ff", require('telescope.builtin').find_files)
k.set('n', "<leader>fg", require('telescope.builtin').live_grep)
k.set('n', "<leader>fb", require('telescope.builtin').buffers)
k.set('n', "<leader>fh", require('telescope.builtin').help_tags)
k.set('n', '<leader>fw', require('telescope.builtin').grep_string)
k.set('n', '<leader>fd', require('telescope.builtin').diagnostics)
k.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
k.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
k.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })
-- Toggleterm
k.set('n', '<C-`>', ":ToggleTerm direction=horizontal<CR>")
-- Diagnostic keymaps
k.set('n', '[d', vim.diagnostic.goto_prev)
k.set('n', ']d', vim.diagnostic.goto_next)
k.set('n', '<leader>e', vim.diagnostic.open_float)
k.set('n', '<leader>q', vim.diagnostic.setloclist)

k.set('c', '<C-B>', "<LEFT>")
k.set('c', '<C-F>', "<RIGHT>")
k.set('c', '<C-K>', "<C-\\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>")

k.set('i', '<C-B>', "<LEFT>")
k.set('i', '<C-F>', "<RIGHT>")
k.set('t', '<C-\\>', "<C-\\><C-n><C-w>", {noremap = true})
