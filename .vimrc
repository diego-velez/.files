" Show cursor's line number
set number

" Show row that cursor is on
set cursorline

" Disable audible and visual bells
set noerrorbells
set novisualbell
set t_vb=

" Use line numbers relative to the cursor's line
set relativenumber

" Always see 10 lines at bottom or top
set scrolloff=10

" Use space characters instead of tabs and set tabs to 4 (https://vim.fandom.com/wiki/Indenting_source_code#Indentation_without_hard_tabs)
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

" Color column #100, good for knowing when you nested too deeply
set colorcolumn=100

" Set the color of the column to gray
highlight ColorColumn ctermbg=238

" Use the clipboard as the default register
" (https://vim.fandom.com/wiki/Accessing_the_system_clipboard)
set clipboard^=unnamed

" Enable file type detection
filetype on

" Enable plugins
filetype plugin on

" Turn syntax highlighting on
syntax on

" Ignore case when searching
set ignorecase

" If search pattern contains uppercase letter, then search is case-sensitive
set smartcase

" Highlight matching characters as you type when searching
set incsearch

" Highlight the current word Vim is on differently when searching
highlight IncSearch ctermbg=238

" Highlight when searching
set hlsearch

" Loop back to top when searching
set wrapscan

" Enable Vim autocompletion
set wildmenu

" List all commands when autocompleting commands
set wildmode=list:longest,full

" Set leader
let mapleader = " "

" Turn off highlighting
nmap <ESC> :nohlsearch<CR>

" Center view when navigating
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap G Gzz
nnoremap n nzz
nnoremap N Nzz

" Move lines
nnoremap j  :<c-u>execute 'move -1-'. v:count1<cr>
nnoremap k  :<c-u>execute 'move +'. v:count1<cr>

" Quickly add empty lines
nnoremap [<space>  :<c-u>put! =repeat(nr2char(10), v:count1)<cr>'[
nnoremap ]<space>  :<c-u>put =repeat(nr2char(10), v:count1)<cr>

" Have cursor stay in same position when joining lines
nnoremap J mzJ`z

" Rename word under cursor
nnoremap <leader>cs :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Tabs
nnoremap <tab><tab> :tabnew<cr>
nnoremap <tab>w :tabclose<cr>
nnoremap <tab>o :tabonly<cr>
nnoremap <tab>n :tabnext<cr>
nnoremap <tab>p :tabprevious<cr>
nnoremap <tab>f :tabfirst<cr>
nnoremap <tab>l :tablast<cr>

" UI Redraw
nnoremap <leader>ur :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" Don't lose selecteion when shifting sidewards
xnoremap <  <gv
xnoremap >  >gv

" Saner behaviour of n and N
nnoremap <expr> n  'Nn'[v:searchforward]
xnoremap <expr> n  'Nn'[v:searchforward]
onoremap <expr> n  'Nn'[v:searchforward]

nnoremap <expr> N  'nN'[v:searchforward]
xnoremap <expr> N  'nN'[v:searchforward]
onoremap <expr> N  'nN'[v:searchforward]

" Smarter cursorline
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline

" Restore cursor position when opening file
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"zz" |
    \ endif
