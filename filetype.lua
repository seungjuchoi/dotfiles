vim.cmd("autocmd FileType python map <buffer> <F5> :update<CR>:TermExec cmd='python %'<CR>")
vim.cmd("autocmd FileType python imap <buffer> <F5> <esc>:update<CR>:TermExec cmd='python % '<CR>")
vim.cmd("autocmd FileType python map <buffer> <F6> :update<CR>:TermExec cmd='python %'")
vim.cmd("autocmd FileType python imap <buffer> <F6> <esc>:update<CR>:TermExec cmd='python % '")
vim.cmd("autocmd FileType go map <buffer> <F5> :update<CR>:TermExec cmd='go run %'<CR>")
vim.cmd("autocmd FileType go imap <buffer> <F5> <esc>:update<CR>:TermExec cmd='gorun % '<CR>")
vim.cmd("autocmd FileType go map <buffer> <F6> :update<CR>:TermExec cmd='go run %'")
vim.cmd("autocmd FileType go imap <buffer> <F6> <esc>:update<CR>:TermExec cmd='go run % '")
vim.cmd("autocmd FileType lua map <buffer> <F5> :update<CR>:TermExec cmd='lua %'<CR>")
vim.cmd("autocmd FileType lua imap <buffer> <F5> <esc>:update<CR>:TermExec cmd='lua %'<CR>")
vim.cmd("autocmd FileType lua map <buffer> <F6> :update<CR>:TermExec cmd='lua % '")
vim.cmd("autocmd FileType lua imap <buffer> <F6> <esc>:update<CR>:TermExec cmd='lua % '")
vim.cmd("autocmd FileType rust map <buffer> <F5> :update<CR>:TermExec cmd='cargo run'<CR>")
vim.cmd("autocmd FileType rust imap <buffer> <F5> <esc>:update<CR>:TermExec cmd='cargo run'<CR>")
vim.cmd("autocmd FileType vim map <buffer> <F5> :update<CR>:source %<CR>")
vim.cmd("autocmd FileType vim imap <buffer> <F5> <esc>:update<CR>:source %<CR>")
vim.cmd("autocmd FileType fish map <buffer> <F5> :update<CR>:source %<CR>")
vim.cmd("autocmd FileType fish imap <buffer> <F5> <esc>:update<CR>:source %<CR>")
vim.cmd("autocmd WinEnter * if &buftype == 'terminal' | setlocal nonumber norelativenumber | endif")
