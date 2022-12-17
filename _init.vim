set number
set relativenumber
set tabstop=4
set shiftwidth=4
set softtabstop=4
set mouse=a
set ignorecase
set expandtab
set clipboard=unnamed

call plug#begin()

Plug 'tpope/vim-surround' " Surrounding ysw)
Plug 'preservim/nerdtree' " NerdTree
Plug 'PhilRunninger/nerdtree-visual-selection'
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline' " Status bar
Plug 'vim-airline/vim-airline-themes'
Plug 'ap/vim-css-color' " CSS Color Preview
Plug 'rafi/awesome-vim-colorschemes' " Retro Scheme
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ryanoasis/vim-devicons' " Developer Icons
Plug 'kyazdani42/nvim-web-devicons'
Plug 'preservim/tagbar' " Tagbar for code navigation
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'nvim-lua/plenary.nvim'
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim'
Plug 'fannheyward/telescope-coc.nvim'
Plug 'BurntSushi/ripgrep'
Plug 'voldikss/vim-floaterm'
Plug 'TimUntersberger/neogit'
Plug 'sindrets/diffview.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'will133/vim-dirdiff'
Plug 'Yggdroot/indentLine'
Plug 'rust-lang/rust.vim'

call plug#end()

set completeopt-=preview " For No Previews

" Basic Keymapping
autocmd FileType python map <buffer> <F12> :!open .<CR>
autocmd FileType python imap <buffer> <F12> <esc>:!open .<CR>
autocmd FileType python map <buffer> <F5> :update<CR>:!python3 %<CR>
autocmd FileType python imap <buffer> <F5> <esc>:update<CR>:!python3 %<CR>
autocmd FileType python map <buffer> <F6> :update<CR>:!python3 % 
autocmd FileType python imap <buffer> <F6> <esc>:update<CR>:!python3 % 
autocmd FileType lua map <buffer> <F5> :update<CR>:!lua %<CR>
autocmd FileType lua imap <buffer> <F5> <esc>:update<CR>:!lua %<CR>
autocmd FileType lua map <buffer> <F6> :update<CR>:!lua % 
autocmd FileType lua imap <buffer> <F6> <esc>:update<CR>:!lua % 
autocmd FileType vim map <buffer> <F5> :update<CR>:source %<CR>
autocmd FileType vim map <buffer> <F5> <esc>:update<CR>:source %<CR>
augroup vimrc-auto-mkdir
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)
  if !isdirectory(a:dir)
  \ && (a:force
  \ || input("'" . a:dir . "' does not exist. Create? [y/N]") =~? '^y\%[es]$')
  call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
  endfunction
augroup END
nnoremap <leader>rc :e $MYVIMRC<CR>
map <C-f> <C-d>
map <C-b> <C-u>
nnoremap x "_x
nnoremap <C-a> gg<S-v>G
nnoremap <silent> <C-s> :update<CR>
inoremap <silent> <C-s> <esc>:update<CR>
vnoremap <silent> <C-s> <esc>:update<CR>
nnoremap <silent> [b :bp<CR>
nnoremap <silent> ]b :bn<CR>
nnoremap <silent> [t :tabp<CR>
nnoremap <silent> ]t :tabn<CR>
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
" nnoremap <silent> <C-k> :move-2<cr>
" nnoremap <silent> <C-j> :move+<cr>
" nnoremap <silent> <C-h> <<
" nnoremap <silent> <C-l> >>
" xnoremap <silent> <C-k> :move-2<cr>gv
" xnoremap <silent> <C-j> :move'>+<cr>gv
" xnoremap <silent> <C-l> >gv
" xnoremap <silent> <C-h> <gv
xnoremap < <gv
xnoremap > >gv
map s<left> <C-w>h
map s<up> <C-w>k
map s<down> <C-w>j
map s<right> <C-w>l
map sh <C-w>h
map sj <C-w>j
map sk <C-w>k
map sl <C-w>l
nnoremap <silent> <F9> :setlocal number relativenumber<CR>
nnoremap <silent> <F10> :setlocal nonumber norelativenumber<CR>

" vim-commentary
autocmd FileType c setlocal commentstring=//\ %s

" NERDTree
let g:NERDTreeIgnore = ['^node_modules$']
nnoremap <silent> <F3> :NERDTreeToggle<CR>

" Floaterm
let g:floaterm_keymap_toggle = '<F4>'

" Nvim-treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
    -- ensure_installed = "all",
    ensure_installed = {
        "fish",
        "json",
        "yaml",
        "swift",
        "css",
        "rust",
        "ruby",
        "vim",
        "html",
        "c",
        "cpp",
        "python",
        "r",
        "lua"
    }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { "phpdoc" },  -- list of language that will be disabled
    highlight = {
        enable = true,              -- false will disable the whole extension
        disable = { "" },  -- list of language that will be disabled
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    autotag = {
        enable = true,
    },
}
EOF

" Diffview
nnoremap <leader>df :DiffviewOpen<CR>
nnoremap <leader>dx :DiffviewClose<CR>

" Tagbar
nmap <F8> :TagbarToggle<CR>

" Telescope
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
lua << EOF
require('telescope').setup {
    extensions = {
		fzf = {
		  fuzzy = true,                    -- false will only do exact matching
		  override_generic_sorter = true,  -- override the generic sorter
		  override_file_sorter = true,     -- override the file sorter
		  case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
										   -- the default case_mode is "smart_case"
		}
    }
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('coc')
EOF

" Nvim-web-devicons
lua << EOF
require'nvim-web-devicons'.setup {
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`
 override = {
  zsh = {
    icon = "",
    color = "#428850",
    cterm_color = "65",
    name = "Zsh"
  }
 };
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}
EOF

" Air-line
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <F2> <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" Color
colorscheme oceanic_material
