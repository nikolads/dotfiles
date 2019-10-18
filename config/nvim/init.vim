filetype plugin on

" # Regular configuration
"
set noswapfile

" Don't ask to save when reading from stdin
autocmd StdinReadPost * set buftype=nofile

" Make `yank` and `put` use the system clipboard
set clipboard=unnamedplus

" Don't persist search highlights between vim sessions
" Note that simply calling `nohlsearch` doesn't work because the highlight
" state is saved and restored on function call (see :help nohlsearch)
call feedkeys(":nohlsearch\<CR>")

" Filename/command autocompletion completes up to first unambiguous character
set wildmode=longest,list

syntax on
" colorscheme slate
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

tnoremap <Esc> <c-\><c-n>

" Make entering insert mode with `i` behave as if `a` was pressed, i.e. move
" the cursor after the selected character
" This makes `i <esc> i <esc> ...` not move the cursor forward
nnoremap i a
vnoremap i a

" Don't copy deleted text
nnoremap d "_d
vnoremap d "_d

" Reselect visual selection after some commands
" vnoremap y y gv
vnoremap > > gv
vnoremap < < gv

" Window navigation
nmap <c-w>h :split<CR>
nmap <a-w>h :split<CR>
noremap <a-w> <c-w>

" Open a file with all folds open
autocmd BufWinEnter * silent! :%foldopen!

" zc is :foldclose by default
nmap zv :foldopen<CR>
nmap z<S-c> :%foldclose<CR>
nmap z<S-v> :%foldopen!<CR>
