
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2019 Dec 17
"
" To use it, copy it to
"	       for Unix:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"	 for MS-Windows:  $VIM\_vimrc
"	      for Haiku:  ~/config/settings/vim/vimrc
"	    for OpenVMS:  sys$login:.vimrc

" Display different cursors for different mode
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"
" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

set langmenu=en_US
let $LANG = 'en_US'
set nocompatible

call plug#begin()

" Highlight copied text
Plug 'machakann/vim-highlightedyank'

" Commentary plugin
Plug 'tpope/vim-commentary'

" FZF
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Sneak
Plug 'justinmk/vim-sneak'

" NERDTree
Plug 'preservim/nerdtree'

" Surround
Plug 'tpope/vim-surround'

" ReplaceWithRegister
Plug 'vim-scripts/ReplaceWithRegister'

" Argument as text object
Plug 'vim-scripts/argtextobj.vim'

" Exchange motion
Plug 'tommcdo/vim-exchange'

" Paragraph motion (with whitespace chars on line)
Plug 'dbakker/vim-paragraph-motion'

" Extended matching
Plug 'chrisbra/matchit'

Plug 'joshdick/onedark.vim'

" QuickScope
Plug 'unblevable/quick-scope'

Plug 'tpope/vim-sensible'

Plug 'chaoren/vim-wordmotion'

Plug 'rose-pine/vim'

" Status bar plugin
Plug 'itchyny/lightline.vim'

" Lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

Plug 'preservim/nerdtree'
Plug 'easymotion/vim-easymotion'
Plug 'liuchengxu/vim-which-key'

call plug#end()

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

set hlsearch
set smartcase
set ignorecase
set clipboard+=unnamed
set matchpairs+=<:>
set ts=4 sw=4
set relativenumber
set number
let mapleader=" "
set number
set relativenumber

" Required for Windows Terminal to properly display colors
" causes problems in wezterm and Mica is not working
" set termguicolors
" colorscheme rosepine_moon

let g:lightline = { 'colorscheme': 'rosepine_moon' }
let g:qs_highlight_on_keys = [ 'f', 'F', 't', 'T' ]
let g:wordmotion_prefix = ','

hi Normal ctermbg=NONE guibg=NONE
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> K <plug>(lsp-hover)
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

"" Mappings
" Remove search higlight
nnoremap <Esc> :nohlsearch<cr>

" Move lines up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-j> <Esc>:m .-2<CR>==gi
" '> - selection end
" '< - selection start
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Nerdtree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" WhichKey
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

" Fzf
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-map-x)
omap <leader><tab> <plug>(fzf-map-o)
nmap <leader>fc :Files ~\.dotfiles<CR>

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif
