" Start capturing startup messages only if errors occur
try
    redir! > $HOME/vim_startup_log.txt
    silent!

    " Core settings
    syntax on
    set encoding=utf-8
    set ignorecase
    set incsearch
    set number
    set relativenumber
    set laststatus=2 " show status line always
    set statusline=%f________%l:%c____%m
    set cursorline
    set smartindent
    set hlsearch
    set tabstop=4
    set shiftwidth=4
    set expandtab
    set undofile

    " Enable filetype detection, plugin, and indent
    filetype plugin on
    filetype indent on

    " Platform-specific settings
    if has('win32') || has('win64')
        " Windows specific settings
        " set shellslash
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
    let dbext_connections_file = has('win32') || has('win64') ? 'C:\vim_dbext_connections.vim' : expand('~/.vim_dbext_connections.vim')
    if filereadable(dbext_connections_file)
        execute 'source ' . dbext_connections_file
    else
        "echo "No dbext connection file found at " . dbext_connections_file
    endif

" Plugin management with Vim-Plug (Ensure Vim-Plug is installed)
if has('win32') || has('win64')
	let plug_dir = expand('~\\vimfiles\\autoload')
	let plug_path = plug_dir . '\\plug.vim'

	" Create the directory if it doesn't exist
	if empty(glob(plug_dir))
		silent execute '!mkdir ' . shellescape(plug_dir)
	endif

	" Command to download vim-plug
	let plug_cmd = 'curl.exe -L https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o ' . shellescape(plug_path)

	" Download plug.vim if it doesn't exist
	if empty(glob(plug_path))
		silent execute '!' . plug_cmd
		" Install plugins automatically after downloading plug.vim
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif
else
    let plug_path = expand('~/.vim/autoload/plug.vim')
    if empty(glob(plug_path))
        silent execute '!curl -fLo ' . plug_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif

    call plug#begin()
    Plug 'jelera/vim-javascript-syntax'
    Plug 'https://github.com/markonm/traces.vim.git'
    Plug 'https://github.com/rakr/vim-one.git'
    Plug 'https://github.com/NLKNguyen/papercolor-theme.git'
    "Plug 'https://github.com/vimwiki/vimwiki.git'
    Plug 'rust-lang/rust.vim'
    Plug 'github/copilot.vim'
    Plug 'phpactor/phpactor', {'for': 'php', 'tag': '*', 'do': 'composer install --no-dev -o'}
    Plug 'vim-php/phpctags', {'do': 'composer install'}
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
    "Plug 'vim-vdebug/vdebug'
    Plug 'godlygeek/tabular'
    Plug 'madox2/vim-ai'
    " Plug 'preservim/vim-markdown'
    " Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
    call plug#end()

    " LaTeX settings
    let g:tex_flavor='latex'
    let g:Tex_MultipleCompileFormats = 'pdf'
    let g:Tex_DefaultTargetFormat = 'pdf'
    let g:Tex_ViewRule_pdf='texworks'
    call setreg('p', ":w\<Return>\\ll\\lv", 'c')

    " Diff mode specific settings
    if &diff
        set nospell
        set wrap
        set textwidth=50
        syntax off
    else
        set nospell
    endif

    autocmd FilterWritePre * if &diff | setlocal wrap | endif
    au VimEnter * if &diff | execute 'windo set wrap' | endif

    " Wildmenu and search settings
    set wildmenu
    set wildoptions+=pum
    set wildmode=full:lastused
    set wildignore+=**/vendor/**,**/*.jpg,**/*.png,**/*.dll,**/*.exe,**/*.mp3,**/*.docx,**/*.xlsx
    set wildignore+=*/vendor/*,*/node_modules/*,*/env/*,*/pycache/*,datadump.json
    set wildignore+=*.jpg,*.png,*.sqlite3,*.dll,*.exe

    " Key mappings
    nnoremap <A-a> <C-a>
    nnoremap <A-x> <C-x>

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
        \ 'css': ['stylelint', 'csslint'],
        \ 'cpp': ['clangd', 'cppcheck'],
        \ }
    let g:ale_fixers = {
        \ 'javascript': ['prettier'],
        \ 'javascript.jsx': ['prettier'],
        \ 'php': ['php_cs_fixer'],
        \ }
    let g:ale_fix_on_save = 0
    let g:ale_cpp_cc_options = '-std=c++17 -Wall -Wextra -pedantic'
    let g:ale_cpp_clangd_options = '-std=c++17'
    let g:prettier#config#tab_width = 2

    " PHP debugging (Vdebug configuration)
    let g:vdebug_options = {}
    let g:vdebug_options['port'] = 9000  " Xdebug default port
    let g:vdebug_options["timeout"] = 10

    colorscheme desert
    set exrc          " Enable loading of local .vimrc files
    set secure        " Restrict unsafe commands in local .vimrc files

    " Finalize redirection if no errors occurred
    redir END

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


    " let g:netrw_list_cmd = 'dir /B'

    " let g:netrw_list_cmd = 'cmd /C dir /B'
    " let g:netrw_list_cmd = 'dir /B'

    let g:netrw_sftp = 1
    let g:netrw_liststyle = 3
    let g:netrw_use_nosort = 1
    let g:netrw_debug = 1
catch
    " In case of an error, finalize redirection and inform the user
    redir END
    echo "An error occurred during Vim startup. Check the log at $HOME/vim_startup_log.txt"
endtry
set grepprg=rg\ --vimgrep\ --no-config
