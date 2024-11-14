" Core settings
syntax on
set encoding=utf-8
set ignorecase
set incsearch
set number relativenumber
set laststatus=2 " show status line always
set statusline=%f________%l:%c____%m
set cursorline
set smartindent
set hlsearch

" Platform-specific settings
if has('win32') || has('win64')
    " Windows specific settings
    set shellslash
    set undodir=C:\vim\
    let g:python3_host_prog = 'C:\Python310\python.exe'
    let data_dir = $LOCALAPPDATA . '/vim-data' " Windows data directory for Vim
else
    " Unix specific settings
    set undodir=~/.vim/
    let g:python3_host_prog = expand('~/.pyenv/shims/python3')
    let data_dir = '~/.vim'
endif

" Source password and dbext configuration files if they exist
if has('win32') || has('win64')
    if filereadable('C:\vim_dbext_connections.vim')
        source C:\vim_dbext_connections.vim
    endif
else
    if filereadable(expand('~/.vim_dbext_connections.vim'))
        source ~/.vim_dbext_connections.vim
    endif
endif

" Plugin management with Vim-Plug
call plug#begin()
Plug 'jelera/vim-javascript-syntax'
Plug 'https://github.com/markonm/traces.vim.git'
Plug 'https://github.com/rakr/vim-one.git'
Plug 'https://github.com/NLKNguyen/papercolor-theme.git'
" Plug 'https://github.com/vimwiki/vimwiki.git'
Plug 'rust-lang/rust.vim'
Plug 'github/copilot.vim'
Plug 'phpactor/phpactor', {'for': 'php', 'tag': '*', 'do': 'composer install --no-dev -o'}
Plug 'vim-php/phpctags', {'do': 'composer install'}
" Plug 'ludovicchabant/vim-gutentags'
Plug 'scrooloose/syntastic'
Plug 'vim-scripts/dbext.vim'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'goerz/jupytext.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'puremourning/vimspector'
Plug 'vim-vdebug/vdebug'
Plug 'vim-vdebug/vdebug' " Duplicate - consider removing one
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
call plug#end()

" Database management (dbext settings without connection profiles)
let g:dbext_default_sqlite_program = 'sqlite3'
let g:dbext_default_SQLITE_SQL_Top_pat = 'SELECT * FROM %t LIMIT %n'
let g:dbext_default_SQLITE_SQL_Top_sub = 'SELECT * FROM %t WHERE rowid IN (SELECT rowid FROM %t ORDER BY rowid LIMIT %n)'

" Other configurations and settings
set tabstop=4
set shiftwidth=4
set expandtab

" Diff mode specific settings
if &diff
    set nospell
    set wrap
    set textwidth=50
    syntax off
else
    set spell
endif

autocmd FilterWritePre * if &diff | setlocal wrap | endif
au VimEnter * if &diff | execute 'windo set wrap' | endif

set wildmenu wildoptions+=pum
set wildmode=full:lastused
set wildignore+=**/vendor/**,**/*.jpg,**/*.png,**/*.dll,**/*.exe,**/*.mp3,**/*.docx,**/*.xlsx
set wildignore+=*/vendor/*,*/node_modules/*,*/env/*,*/pycache/*,datadump.json
set wildignore+=*.jpg,*.png,*.sqlite3,*.dll,*.exe

" Key mappings
:nnoremap <A-a> <C-a>
:nnoremap <A-x> <C-x>
" :map <Leader>o o<Esc>

" Vimwiki settings
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext = 1

" Status line enhancement (Syntastic integration)
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" ALE and miscellaneous settings
let g:ale_enabled = 1
let g:ale_linters = {
    \ 'javascript': ['eslint'],
    \ 'javascript.jsx': ['eslint'],
    \ 'php': ['intelephense', 'php'],
    \ 'css': ['stylelint','csslint'],
    \ }
let g:ale_fixers = {
    \ 'javascript': ['prettier'],
    \ 'javascript.jsx': ['prettier'],
    \ 'php': ['php_cs_fixer'],
    \ }
let g:ale_fix_on_save = 0

"---------------------------------------------------------------------------------------------------------------------------
" ~/.vim_dbext_connections_sample.vim or C:\vim_dbext_connections_sample.vim
" This file is a sample template for dbext connection profiles.
" Replace the placeholders with your actual values, then rename the file to vim_dbext_connections.vim.

" Sample password variables
let g:db_password_sample1 = 'replace_with_your_password_1'
let g:db_password_sample2 = 'replace_with_your_password_2'

" Sample connection profiles (replace placeholders with real data)
let g:dbext_default_profile_mysql_local = 'type=MYSQL:user=your_user:passwd=' . g:db_password_sample1 . ':dbname=your_database_name'
let g:dbext_default_profile_mysql_remote = 'type=MYSQL:host=your_remote_host:port=3306:user=your_user:passwd=' . g:db_password_sample2 . ':dbname=your_database_name'
let g:dbext_default_profile_sqlite_local = 'type=SQLITE:dbname=path/to/your_database_file.sqlite3'

" Example of setting the default connection profile to use
let g:dbext_default_profile = 'mysql_local'

" Notes:
" - Replace `your_user`, `your_database_name`, and `path/to/your_database_file.sqlite3` with actual values.
" - You can add more profiles as needed, following the structure above.
" - Once filled in, rename the file to `vim_dbext_connections.vim` and secure it.
"---------------------------------------------------------------------------------------------------------------------------
