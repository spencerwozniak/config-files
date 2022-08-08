" Plugins
call plug#begin()

Plug 'http://github.com/tpope/vim-surround'             " Surrounding ysw
Plug 'https://github.com/tpope/vim-commentary'          " Commentary
Plug 'https://github.com/preservim/nerdtree'            " NerdTree
Plug 'https://github.com/sheerun/vim-polyglot'          " Better syntax highlighting
Plug 'https://github.com/ryanoasis/vim-devicons'        " Developer Icons
Plug 'https://github.com/preservim/tagbar', {'on': 'TagbarToggle'} " Tagbar for code navigation
Plug 'https://github.com/vim-airline/vim-airline'       " Status bar
Plug 'https://github.com/tc50cal/vim-terminal'          " Vim terminal
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Retro scheme
Plug 'https://github.com/navarasu/onedark.nvim'         " Onedark
Plug 'https://github.com/rakr/vim-one'                  " One colorscheme
Plug 'https://github.com/drewtempelmeyer/palenight.vim' " Palenight
Plug 'https://github.com/terryma/vim-multiple-cursors'  " CTRL + N for multiple cursors
Plug 'https://github.com/chriskempson/base16-vim/colors' " Base16 Color Schemes
Plug 'sainnhe/gruvbox-material'

call plug#end()

set number
set relativenumber
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set encoding=UTF-8

" Colorscheme (dark, darker, cool, deep, warm, warmer, light)
if has('termguicolors')
  set termguicolors
endif
set background=dark
let g:gruvbox_material_better_performance = 1
syntax enable
silent! colorscheme gruvbox-material

" NerdTree
nnoremap <F2> :NERDTreeToggle<CR>

let g:NERDTreeDirArrowExpandable='+'
let g:NERDTreeDirArrowCollapsible='~'
let g:python_highlight_all = 1

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" Airline
let g:airline_theme='gruvbox_material'
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text'
    \]

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" Terminal
nnoremap <F3> :TerminalSplit bash<CR>

" Tagbar
nmap <F4> :TagbarToggle<CR>

" Dashboard
let g:dashboard_default_executive ='fzf'

:set completeopt-=preview " For No Previews
