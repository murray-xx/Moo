" for sources see (in no specific order)
" http://items.sjbach.com/319/configuring-vim-right
" http://news.ycombinator.com/item?id=856051
" http://www.vi-improved.org/vimrc.php
" and some sources lost because I started recording them late :(

set shiftwidth=4
set tabstop=4
set ts=4
set expandtab
set noshowmatch
set matchtime=1
set laststatus=2
set visualbell
set wildmenu
set wildmode=list:longest
set ignorecase 
set smartcase
set title
set scrolloff=3
set list


set shiftround " when at 3 spaces, and I hit > ... go to 4, not 5

" By default, Vim only remembers the last 20 commands and search patterns entered, boost this up 
set history=1000


" store all of your vim swp files in one place, make sure this directory exists
set backupdir=/home/perth/wopmbn/.vim/vim_swp
set directory=/home/perth/wopmbn/.vim/vim_swp

if has('syntax') && (&t_Co > 2 || has('win32') || has('gui_running'))
    syntax enable
    set listchars=tab:»·,trail:·
endif

":colorscheme mod_tcsoft 
:colorscheme github

" Tabs
map <C-t> :tabnew<CR>
map <C-Tab> :tabnext<CR>
map <C-S-Tab> :tabprevious<CR>


" Paste
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Shell like Home / End
noremap <C-A>    <Home>
noremap <C-E>    <End>

" F3 toggles highlight search on and off
map <F3> :set hls!<bar>set hls?<CR>

map ,pt  <Esc>:%! perltidy<CR>
map ,ptv <Esc>:'<,'>! perltidy<CR>
