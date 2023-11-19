filetype on
set encoding=utf-8
scriptencoding utf-8
set showcmd
set wildmenu
set expandtab
set hlsearch
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smartindent
set foldmethod=manual
set showmatch
set number
set backspace=indent,eol,start
set clipboard+=unnamed
set cursorline
set nofoldenable
set belloff=all
set hidden
set splitbelow
set splitright
set statusline=%f

set noswapfile
set nobackup
set nowrap

set incsearch
set ignorecase
set smartcase

nmap j gj
nmap k gk
nmap <down> gj
nmap <up> gk
nmap ; :
nmap f *
noremap <S-s>   :%s/
noremap <S-h>   ^
noremap <S-j>   L
noremap <S-k>   H
nnoremap <S-l>   $
vnoremap <S-l>   $h
tnoremap <Esc> <C-\><C-n>
inoremap <C-c> <Esc>
let mapleader = "\<Space>"

vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>N

