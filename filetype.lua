vim.cmd("autocmd FileType python map <buffer> <F5> :update<CR>:!python3 %<CR>")
vim.cmd("autocmd FileType python imap <buffer> <F5> <esc>:update<CR>:!python3 %<CR>")
vim.cmd("autocmd FileType python map <buffer> <F6> :update<CR>:!python3 % ")
vim.cmd("autocmd FileType python imap <buffer> <F6> <esc>:update<CR>:!python3 % ")
vim.cmd("autocmd FileType lua map <buffer> <F5> :update<CR>:!lua %<CR>")
vim.cmd("autocmd FileType lua imap <buffer> <F5> <esc>:update<CR>:!lua %<CR>")
vim.cmd("autocmd FileType lua map <buffer> <F6> :update<CR>:!lua % ")
vim.cmd("autocmd FileType lua imap <buffer> <F6> <esc>:update<CR>:!lua % ")
vim.cmd("autocmd FileType vim map <buffer> <F5> :update<CR>:source %<CR>")
vim.cmd("autocmd FileType vim map <buffer> <F5> <esc>:update<CR>:source %<CR>")
vim.cmd("autocmd FileType fish map <buffer> <F5> :update<CR>:source %<CR>")
vim.cmd("autocmd FileType fish map <buffer> <F5> <esc>:update<CR>:source %<CR>")
