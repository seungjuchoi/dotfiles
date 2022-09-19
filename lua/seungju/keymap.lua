local k = vim.keymap
k.set('n', '<leader>rc', ':e $MYVIMRC<CR>', {noremap = true})
k.set('n', 'x', '"_x', {noremap = true})
k.set('n', '<C-A>', 'gg<S-v>G', {noremap = true})
k.set('n', '<C-S>', ':update<CR>', {silent = true, noremap = true})
k.set({'i','v'}, '<C-S>', '<ESC>:update<CR>', {silent = true, noremap = true})
k.set('n', '[b', ':bp<CR>', {silent = true, noremap = true})
k.set('n', ']b', ':bn<CR>', {silent = true, noremap = true})
k.set('n', '[t', ':tabp<CR>', {silent = true, noremap = true})
k.set('n', ']t', ':tabn<CR>', {silent = true, noremap = true})
k.set('n', '<leader>cd', ':cd %:p:h<CR>:pwd<CR>', {noremap = true})
k.set('n', 'sh', '<C-W>h')
k.set('n', 'sj', '<C-W>j')
k.set('n', 'sk', '<C-W>k')
k.set('n', 'sl', '<C-W>l')

k.set('n', '<F3>', ":NERDTreeToggle<CR>", {silent = true, noremap = true})
vim.cmd("let g:floaterm_keymap_toggle    = '<F4>'")
k.set('n', "<F8>", ":TagbarToggle<CR>")

k.set('n', "<leader>df", ":DiffviewOpen<CR>")
k.set('n', "<leader>dx", ":DiffviewClose<CR>")
k.set('n', "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>")
k.set('n', "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
k.set('n', "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
k.set('n', "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")


