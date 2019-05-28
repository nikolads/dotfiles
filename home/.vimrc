" # Vundle configuration
" 
" Install plugins with
"     
"     :source %
"     :PluginInstall
" 
" see :h vundle for more details or wiki for FAQ
"
filetype off
set rtp+=~/.vim/vundle/Vundle.vim
call vundle#begin('~/.vim/vundle')

Plugin 'VundleVim/Vundle.vim'

Plugin 'terryma/vim-multiple-cursors'

call vundle#end()
filetype plugin on

" # Regular configuration
"
set noswapfile

" Don't ask to save when reading from stdin
autocmd StdinReadPost * set buftype=nofile

" Make `yank` and `put` use the system clipboard
set clipboard=unnamedplus

" Don't persist search highlights between vim sessions
" Note that simply calling `nohlsearch` doesn't work (see :help nohlsearch)
call feedkeys(":nohlsearch\<CR>")

" Filename/command autocompletion completes up to first unambiguous character
set wildmode=longest,list

syntax on
colorscheme morning
set showcmd
set number

set expandtab tabstop=4 shiftwidth=4 softtabstop=4
set whichwrap+=<,>,h,l,[,]
set smartindent
set nowrap
set splitright

" Allow selecting arbitrary rectangle in visual block mode and selecting the end of line symbol
set virtualedit=block,onemore

nmap q <Nop>

" Don't copy deleted text
nnoremap d "_d
vnoremap d "_d

" Reselect visual selection after some commands
" vnoremap y y gv
vnoremap > > gv
vnoremap < < gv

" Open a file with all folds open
autocmd BufWinEnter * silent! :%foldopen!

" zc is :foldclose by default
nmap zv :foldopen<CR>
nmap z<S-c> :%foldclose<CR>
nmap z<S-v> :%foldopen!<CR>
