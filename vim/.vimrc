
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

call plug#begin()

" Highlight copied text
Plug 'machakann/vim-highlightedyank'

" Commentary plugin
Plug 'tpope/vim-commentary'

" Status bar plugin
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" FZF
Plug 'junegunn/fzf'

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

call plug#end()

set smartcase
set ignorecase
set clipboard+=unnamedplus
set matchpairs+=<:>
let mapleader=" "

" Looks like Windows Terminal is pushing terminal colors to vim
" but for Wezterm you need to set termguicolors and specific colorscheme
set termguicolors

colorscheme onedark 

let g:airline_theme = 'onedark'
let g:qs_highlight_on_keys = [ 'f', 'F', 't', 'T' ]

" Mappings

" Remove search higlight
nnoremap <Esc> :nohlsearch<cr>

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
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
