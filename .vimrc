" Show cursor's line number
set number

" Show row that cursor is on
set cursorline

"highlight CursorLine cterm=NONE gui=NONE " Disable underline
"highlight CursorLineNr cterm=NONE gui=NONE " Disable underline for number/sign column

" Use bar cursor when in insert mode
" See https://stackoverflow.com/a/42118416
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

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
set clipboard=unnamed

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

" Options recommended by vim-flagship
set laststatus=2
set showtabline=1
set guioptions-=e

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

nnoremap <leader>e :Ex<cr>

" Move lines
nnoremap j  :<c-u>execute 'move -1-'. v:count1<cr>
nnoremap k  :<c-u>execute 'move +'. v:count1<cr>

" Have cursor stay in same position when joining lines
nnoremap J mzJ`z

" Rename word under cursor
nnoremap <leader>cs :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Tabs
nnoremap <leader><tab><tab> :tabnew<cr>
nnoremap <leader><tab>w :tabclose<cr>
nnoremap <leader><tab>o :tabonly<cr>
nnoremap <leader><tab>n :tabnext<cr>
nnoremap <leader><tab>p :tabprevious<cr>
nnoremap <leader><tab>f :tabfirst<cr>
nnoremap <leader><tab>l :tablast<cr>

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

" ---------------
" Install Plugins
" ---------------

" See https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation-of-missing-plugins
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
call plug#begin()

Plug 'dracula/vim'

Plug 'tpope/vim-surround'

Plug 'tpope/vim-commentary'

Plug 'tpope/vim-unimpaired'

Plug 'tpope/vim-flagship'

Plug 'tpope/vim-sleuth'

Plug 'tpope/vim-repeat'

Plug 'tpope/vim-vinegar'

Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

" Load dracula colorscheme
silent! colorscheme dracula

" Ctrlp keymaps
let g:ctrlp_map = '<leader><space>'
let g:ctrlp_show_hidden = 1
