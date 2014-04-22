" vim: fdm=marker ts=2 sw=2 fdl=0
" detect OS {{{
  let s:is_windows = has('win32') || has('win64')
  let s:is_cygwin = has('win32unix')
" }}}

" dotvim settings {{{
  if !exists('g:dotvim_settings')
    let g:dotvim_settings = {}
  endif

  " initialize default settings
  let s:settings = {}
  let s:settings.default_indent = 4
  let s:settings.max_column = 120
  let s:settings.autocomplete_method = 'neocomplcache'
  let s:settings.colorscheme = 'solarized'

  if exists('g:dotvim_settings.plugin_groups')
    let s:settings.plugin_groups = g:dotvim_settings.plugin_groups
  else
    let s:settings.plugin_groups = []
    call add(s:settings.plugin_groups, 'core')
    call add(s:settings.plugin_groups, 'web')
    call add(s:settings.plugin_groups, 'javascript')
    call add(s:settings.plugin_groups, 'python')
    call add(s:settings.plugin_groups, 'php')
    call add(s:settings.plugin_groups, 'scm')
    call add(s:settings.plugin_groups, 'autocomplete')
    call add(s:settings.plugin_groups, 'editing')
    call add(s:settings.plugin_groups, 'visual')
    call add(s:settings.plugin_groups, 'indents')
    call add(s:settings.plugin_groups, 'navigation')
    call add(s:settings.plugin_groups, 'unite')
    call add(s:settings.plugin_groups, 'misc')
    if s:is_windows
      call add(s:settings.plugin_groups, 'windows')
    endif
  endif

  " override defaults with the ones specified in g:dotvim_settings
  for key in keys(s:settings)
    if has_key(g:dotvim_settings, key)
      let s:settings[key] = g:dotvim_settings[key]
    endif
  endfor
" }}} dotvim settings

" setup {{{
  set nocompatible
  if s:is_windows
    set rtp+=~/.vim
  endif
  set rtp+=~/.vim/bundle/neobundle.vim
  call neobundle#rc(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'
" }}} setup

" functions {{{
  function! EnsureExists(path)
    if !isdirectory(expand(a:path))
      call mkdir(expand(a:path))
    endif
  endfunction
  " Strip whitespace {
  function! StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction
  " }
" }}} functions

" base configuration {{{
  set timeoutlen=500                                  "mapping timeout
  set ttimeoutlen=50                                  "keycode timeout

  set mouse=a                                         "enable mouse
  set mousehide                                       "hide when characters are typed
  set history=1000                                    "number of command lines to remember
  set ttyfast                                         "assume fast terminal connection
  set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
  set encoding=utf-8                                  "set encoding for text
  set hidden                                          "allow buffer switching without saving
  set nrformats-=octal                                "always assume decimal numbers
  set showcmd
  set tags=tags;/,~/.tags
  set showfulltag
  set modeline
  set modelines=5

  if s:is_windows && !s:is_cygwin
    " ensure correct shell in gvim
    set shell=c:\windows\system32\cmd.exe
  endif

  " whitespace
  set backspace=indent,eol,start                      "allow backspacing everything in insert mode
  set autoindent                                      "automatically indent to match adjacent lines
  set smartindent                                     "smart indenting for additional languages
  set expandtab                                       "spaces instead of tabs
  set smarttab                                        "use shiftwidth to enter tabs
  let &tabstop=s:settings.default_indent              "number of spaces per tab for display
  let &softtabstop=s:settings.default_indent          "number of spaces per tab in insert mode
  let &shiftwidth=s:settings.default_indent           "number of spaces when indenting
  set list                                            "highlight whitespace
  set listchars=tab:·⁖,trail:•,extends:…,precedes:<
  set fillchars=vert:\|
  set shiftround
  set linebreak
  let &showbreak='↪ '


  set scrolloff=1                                     "always show content after scroll
  set scrolljump=5                                    "minimum number of lines to scroll
  set display+=lastline
  set wildmenu                                        "show list for autocomplete
  set wildmode=list:full
  set wildignorecase
  set wildignore+=*/.hg/*,*/.idea/*,*/.DS_Store

  set splitbelow
  set splitright

   " disable sounds
  set noerrorbells
  set novisualbell
  set t_vb=

  " searching
  set hlsearch                                        "highlight searches
  set incsearch                                       "incremental searching
  set ignorecase                                      "ignore case for searching
  set smartcase                                       "do case-sensitive if there's a capital letter

  " vim file/folder management {{{
    " persistent undo
    if exists('+undofile')
      set undofile
      set undodir=~/.vim/.cache/undo
    endif

    " backups
    set backup
    set backupdir=~/.vim/.cache/backup

    " swap files
    set directory=~/.vim/.cache/swap
    set noswapfile

    call EnsureExists('~/.vim/.cache')
    call EnsureExists(&undodir)
    call EnsureExists(&backupdir)
    call EnsureExists(&directory)
  "}}}

  let mapleader = ","
  let g:mapleader = ","
" }}} base configuration

" ui configuration {{{
  set showmatch                                       "automatically highlight matching braces/brackets/etc.
  set matchtime=2                                     "tens of a second to show matching parentheses
  set relativenumber
  set lazyredraw
  set laststatus=2
  set showmode                                        " Display the current mode
  set foldenable                                      "enable folds by default
  set foldmethod=syntax                               "fold via syntax of files
  set foldlevelstart=99                               "open all folds by default
  let g:xml_syntax_folding=1                          "enable xml folding

  set cursorline
  autocmd WinLeave * setlocal nocursorline
  autocmd WinEnter * setlocal cursorline
  let &colorcolumn=s:settings.max_column
  set cursorcolumn
  autocmd WinLeave * setlocal nocursorcolumn
  autocmd WinEnter * setlocal cursorcolumn

  highlight clear LineNr          " Current line number row will have same background color in relative mode.
                                  " Things like vim-gitgutter will match LineNr highlight

  if has('conceal')
    set conceallevel=1
    set listchars+=conceal:Δ
  endif

  if has('gui_running')
    " open maximized
    "set lines=999 columns=9999
    if s:is_windows
      autocmd GUIEnter * simalt ~x
    endif

    set guioptions+=t                                 "tear off menu items
    set guioptions-=m                                 " remove menu
    set guioptions-=T                                 "toolbar icons
    set guioptions-=r " remove righthand scrollbar
    set guioptions-=R
    set guioptions-=l " remove lefthand scrollbar
    set guioptions-=L

    set gfn=Inconsolata\ LGC\ Medium\ 12,DejaVu\ Sans\ Mono\ 12,Ubuntu\ Mono\ 14,Anonymous\ Pro\ 14
    if s:is_windows
      set gfn=Inconsolata_LGC_Medium:h12,Consolas:h14,DejaVu_Sans_Mono:h14,Ubuntu_Mono:h14,Anonymous_Pro:h14
    endif
  else
    set t_Co=256
  endif
" }}} ui configuration

" plugin/mapping configuration {{{
  if count(s:settings.plugin_groups, 'core') " {{{
    NeoBundle 'matchit.zip'
    NeoBundle 'bling/vim-airline' " {{{
      let g:airline_left_sep = '›'
      let g:airline_right_sep = '‹'
      let g:airline_linecolumn_prefix = '␤'
      let g:airline_branch_prefix = '⎇ '
      let g:airline_paste_symbol = 'ρ'
      let g:airline_theme='pencil'
      let g:airline#extensions#tabline#left_sep=' '
      let g:airline#extensions#tabline#left_alt_sep='¦'
      let g:airline#extensions#tabline#enabled = 1
    " }}}
    NeoBundle 'tpope/vim-surround'
    NeoBundle 'tpope/vim-repeat'
    NeoBundle 'tpope/vim-unimpaired' " {{{
      nmap <c-up> [e
      nmap <c-down> ]e
      vmap <c-up> [egv
      vmap <c-down> ]egv
    " }}}
    NeoBundle 'SyntaxComplete'
  endif " }}} core
  if count(s:settings.plugin_groups, 'web') " {{{
    NeoBundleLazy 'groenewege/vim-less', {'autoload':{'filetypes':['less']}}
    NeoBundleLazy 'ap/vim-css-color', {'autoload':{'filetypes':['css','less']}}
    NeoBundleLazy 'othree/html5.vim', {'autoload':{'filetypes':['html']}}
    NeoBundleLazy 'juvenn/mustache.vim', {'autoload':{'filetypes':['mustache']}}
    NeoBundleLazy 'gregsexton/MatchTag', {'autoload':{'filetypes':['html','xml']}}
    NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}}
    NeoBundleLazy 'beyondwords/vim-twig', {'autoload':{'filetypes':['twig','html']}} " {{{
      autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig.jinja2
    " }}}
  endif " }}} web
  if count(s:settings.plugin_groups, 'javascript') " {{{
    NeoBundleLazy 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}}
    NeoBundleLazy 'maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript']}} " {{{
      nnoremap <leader>fjs :call JsBeautify()<cr>
    " }}}
    NeoBundleLazy 'kchmck/vim-coffee-script', {'autoload':{'filetypes':['coffee']}}
    NeoBundleLazy 'mmalecki/vim-node.js', {'autoload':{'filetypes':['javascript']}}
    NeoBundleLazy 'leshill/vim-json', {'autoload':{'filetypes':['javascript','json']}}
    NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {'autoload':{'filetypes':['javascript','coffee']}} " {{{
      let g:used_javascript_libs = 'jquery,angularjs'
    " }}}
  endif " }}} javascript
  if count(s:settings.plugin_groups, 'javascript') " {{{
    NeoBundle 'arnaud-lb/vim-php-namespace' " {{{
      inoremap <Leader>u <C-O>:call PhpInsertUse()<CR>
      noremap <Leader>u :call PhpInsertUse()<CR>
      inoremap <Leader>e <C-O>:call PhpExpandClass()<CR>
      noremap <Leader>e :call PhpExpandClass()<CR>
    " }}}
  endif " }}} php
  if count(s:settings.plugin_groups, 'python') " {{{
    NeoBundleLazy 'klen/python-mode', {'autoload':{'filetypes':['python']}} " {{{
      let g:pymode_rope=0
      let g:pymode_lint = 0
    " }}}
    NeoBundleLazy 'davidhalter/jedi-vim', {'autoload':{'filetypes':['python']}} " {{{
      let g:jedi#popup_on_dot=0
    " }}}
  endif " }}} python
  if count(s:settings.plugin_groups, 'scm') " {{{
    NeoBundle 'mhinz/vim-signify' "{{{
        let g:signify_update_on_bufenter=0
        let g:signify_update_on_focusgained=0
    " }}}
    NeoBundle 'tpope/vim-fugitive' " {{{
      nnoremap <silent> <leader>gs :Gstatus<CR>
      nnoremap <silent> <leader>gd :Gdiff<CR>
      nnoremap <silent> <leader>gc :Gcommit<CR>
      nnoremap <silent> <leader>gb :Gblame<CR>
      nnoremap <silent> <leader>gl :Glog<CR>
      nnoremap <silent> <leader>gp :Git push<CR>
      nnoremap <silent> <leader>gw :Gwrite<CR>
      nnoremap <silent> <leader>gr :Gremove<CR>
      autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
      autocmd BufReadPost fugitive://* set bufhidden=delete
    " }}}
    NeoBundleLazy 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}} " {{{
      nnoremap <silent> <leader>gv :Gitv<CR>
      nnoremap <silent> <leader>gV :Gitv!<CR>
    " }}}
    NeoBundle 'sjl/splice.vim'
  endif " }}} scm
  if count(s:settings.plugin_groups, 'autocomplete') "{{{
    if s:settings.autocomplete_method == 'ycm' "{{{
      NeoBundle 'Valloric/YouCompleteMe', {'vim_version':'7.3.584'} "{{{
        let g:ycm_collect_identifiers_from_tags_files = 1
        let g:ycm_complete_in_comments_and_strings=1
        let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
        let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
        let g:ycm_filetype_blacklist={'unite': 1}
      "}}}
      NeoBundle 'SirVer/ultisnips' "{{{
        let g:UltiSnipsExpandTrigger="<tab>"
        let g:UltiSnipsJumpForwardTrigger="<tab>"
        let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
        let g:UltiSnipsSnippetsDir='~/.vim/bundle/vim-twig/snippets'
      "}}}
      NeoBundle 'honza/vim-snippets'
    else
      NeoBundle 'Shougo/neosnippet.vim' "{{{
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/snippets'
        let g:neosnippet#enable_snipmate_compatibility=1

        imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ? "\<C-n>" : "\<TAB>")
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
        smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
      "}}}
    endif "}}}
    if s:settings.autocomplete_method == 'neocomplete' "{{{
      NeoBundleLazy 'Shougo/neocomplete.vim', {'autoload':{'insert':1}, 'vim_version':'7.3.885'} "{{{
        let g:neocomplete#enable_at_startup=1
        let g:neocomplete#data_directory='~/.vim/.cache/neocomplete'
      "}}}
    endif "}}}
    if s:settings.autocomplete_method == 'neocomplcache' "{{{
      NeoBundleLazy 'Shougo/neocomplcache.vim', {'autoload':{'insert':1}} "{{{
        let g:acp_enableAtStartup = 0
        let g:neocomplcache_enable_at_startup=1
        let g:neocomplcache_temporary_dir='~/.vim/.cache/neocomplcache'
        let g:neocomplcache_enable_fuzzy_completion=1

        " SuperTab like snippets behavior.
        imap <silent><expr><TAB> neosnippet#expandable() ?
                    \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
                    \ "\<C-e>" : "\<TAB>")
        smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

        " Define dictionary.
        let g:neocomplcache_dictionary_filetype_lists = {
                    \ 'default' : '',
                    \ 'vimshell' : $HOME.'/.vimshell_hist',
                    \ 'scheme' : $HOME.'/.gosh_completions'
                    \ }

        " Define keyword.
        if !exists('g:neocomplcache_keyword_patterns')
            let g:neocomplcache_keyword_patterns = {}
        endif
        let g:neocomplcache_keyword_patterns._ = '\h\w*'

        " Plugin key-mappings.

        " These two lines conflict with the default digraph mapping of <C-K>
        " If you prefer that functionality, add
        " let g:spf13_no_neosnippet_expand = 1
        " in your .vimrc.bundles.local file

        if !exists('g:spf13_no_neosnippet_expand')
            imap <C-k> <Plug>(neosnippet_expand_or_jump)
            smap <C-k> <Plug>(neosnippet_expand_or_jump)
        endif

        inoremap <expr><C-g> neocomplcache#undo_completion()
        inoremap <expr><C-l> neocomplcache#complete_common_string()
        inoremap <expr><CR> neocomplcache#complete_common_string()

        " <TAB>: completion.
        inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

        " <CR>: close popup
        " <s-CR>: close popup and save indent.
        inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()"\<CR>" : "\<CR>"
        inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

        " <C-h>, <BS>: close popup and delete backword char.
        inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
        inoremap <expr><C-y> neocomplcache#close_popup()

        " Enable omni completion.
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

        " Enable heavy omni completion.
        if !exists('g:neocomplcache_omni_patterns')
            let g:neocomplcache_omni_patterns = {}
        endif
        let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'

        " Use honza's snippets.
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

        " Enable neosnippet snipmate compatibility mode
        let g:neosnippet#enable_snipmate_compatibility = 1

        " For snippet_complete marker.
        if has('conceal')
            set conceallevel=2 concealcursor=i
        endif

        " Disable the neosnippet preview candidate window
        " When enabled, there can be too much visual noise
        " especially when splits are used.
        set completeopt-=preview
      "}}}
    endif "}}}
  endif "}}} autocomplete
  if count(s:settings.plugin_groups, 'editing') " {{{
    NeoBundle 'tpope/vim-speeddating'
    NeoBundle 'tomtom/tcomment_vim'
    NeoBundle 'terryma/vim-multiple-cursors'
    NeoBundle 'chrisbra/NrrwRgn'
    NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}} "{{{
      nmap <Leader>a& :Tabularize /&<CR>
      vmap <Leader>a& :Tabularize /&<CR>
      nmap <Leader>a= :Tabularize /=<CR>
      vmap <Leader>a= :Tabularize /=<CR>
      nmap <Leader>a: :Tabularize /:<CR>
      vmap <Leader>a: :Tabularize /:<CR>
      nmap <Leader>a:: :Tabularize /:\zs<CR>
      vmap <Leader>a:: :Tabularize /:\zs<CR>
      nmap <Leader>a, :Tabularize /,<CR>
      vmap <Leader>a, :Tabularize /,<CR>
      nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
      vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "}}}
    NeoBundle 'Raimondi/delimitMate' " {{{
      let delimitMate_balance_matchpairs = 1
      let delimitMate_jump_expansion = 1
      let delimitMate_expand_cr = 1
      let delimitMate_expand_space = 1
      let delimitMate_nesting_quotes = ['"','`']
      au FileType python,coffee let b:delimitMate_nesting_quotes = ['"',"'"]
    " }}}
    NeoBundle 'justinmk/vim-sneak' " {{{
      let g:sneak#streak = 1
    " }}}
  endif " }}} editing
  if count(s:settings.plugin_groups, 'indents') "{{{
    NeoBundle 'nathanaelkane/vim-indent-guides' " {{{
      let g:indent_guides_start_level=1
      let g:indent_guides_guide_size=1
      let g:indent_guides_enable_on_vim_startup=0
      let g:indent_guides_color_change_percent=3
      if !has('gui_running')
        let g:indent_guides_auto_colors=0
        function! s:indent_set_console_colors()
          hi IndentGuidesOdd ctermbg=235
          hi IndentGuidesEven ctermbg=236
        endfunction
        autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
      endif
    " }}}
  endif " }}} indents
  if count(s:settings.plugin_groups, 'navigation') "{{{
    NeoBundleLazy 'mbbill/undotree', {'autoload':{'commands':'UndotreeToggle'}} "{{{
      let g:undotree_SplitLocation='botright'
      let g:undotree_SetFocusWhenToggle=1
      nnoremap <silent> <F5> :UndotreeToggle<CR>
    "}}}
    NeoBundleLazy 'EasyGrep', {'autoload':{'commands':'GrepOptions'}} "{{{
      let g:EasyGrepRecursive=1
      let g:EasyGrepAllOptionsInExplorer=1
      let g:EasyGrepCommand=1
      nnoremap <leader>vo :GrepOptions<cr>
    "}}}
    NeoBundle 'kien/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' } "{{{
      let g:ctrlp_clear_cache_on_exit=1
      let g:ctrlp_max_height=40
      let g:ctrlp_show_hidden=0
      let g:ctrlp_follow_symlinks=1
      let g:ctrlp_working_path_mode=0
      let g:ctrlp_max_files=20000
      let g:ctrlp_cache_dir='~/.vim/.cache/ctrlp'
      let g:ctrlp_reuse_window='startify'
      let g:ctrlp_extensions=['funky']
      let g:ctrlp_custom_ignore = {
            \ 'dir':  '\.git$\|\.hg$\|\.svn$',
            \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

      nmap \ [ctrlp]
      nnoremap [ctrlp] <nop>

      nnoremap [ctrlp]t :CtrlPBufTag<cr>
      nnoremap [ctrlp]T :CtrlPTag<cr>
      nnoremap [ctrlp]l :CtrlPLine<cr>
      nnoremap [ctrlp]o :CtrlPFunky<cr>
      nnoremap [ctrlp]b :CtrlPBuffer<cr>
    "}}}
    NeoBundleLazy 'scrooloose/nerdtree', {'autoload':{'commands':['NERDTreeToggle','NERDTreeFind']}} "{{{
      let NERDTreeShowHidden=1
      let NERDTreeQuitOnOpen=1
      let NERDTreeShowLineNumbers=1
      let NERDTreeChDirMode=0
      let NERDTreeShowBookmarks=1
      let NERDTreeIgnore=['\.git','\.hg','.pyc']
      let NERDTreeBookmarksFile='~/.vim/.cache/NERDTreeBookmarks'
      nnoremap <F2> :NERDTreeToggle<CR>
      nnoremap <F3> :NERDTreeFind<CR>
    "}}}
    NeoBundleLazy 'majutsushi/tagbar', {'autoload':{'commands':'TagbarToggle'}} "{{{
      nnoremap <silent> <F9> :TagbarToggle<CR>
    "}}}
  endif " }}} navigation
  if count(s:settings.plugin_groups, 'unite') "{{{
    NeoBundle 'Shougo/unite.vim' "{{{
      let bundle = neobundle#get('unite.vim')
      function! bundle.hooks.on_source(bundle)
        call unite#filters#matcher_default#use(['matcher_fuzzy'])
        call unite#filters#sorter_default#use(['sorter_rank'])
        call unite#set_profile('files', 'smartcase', 1)
        call unite#custom#source('line,outline','matchers','matcher_fuzzy')
      endfunction

      let g:unite_data_directory='~/.vim/.cache/unite'
      let g:unite_enable_start_insert=1
      let g:unite_source_history_yank_enable=1
      let g:unite_source_rec_max_cache_files=5000
      let g:unite_prompt='» '

      if executable('ag')
        let g:unite_source_grep_command='ag'
        let g:unite_source_grep_default_opts='--nocolor --nogroup -S -C4'
        let g:unite_source_grep_recursive_opt=''
      elseif executable('ack')
        let g:unite_source_grep_command='ack'
        let g:unite_source_grep_default_opts='--no-heading --no-color -a -C4'
        let g:unite_source_grep_recursive_opt=''
      endif

      function! s:unite_settings()
        nmap <buffer> Q <plug>(unite_exit)
        nmap <buffer> <esc> <plug>(unite_exit)
        imap <buffer> <esc> <plug>(unite_exit)
      endfunction
      autocmd FileType unite call s:unite_settings()

      nmap <space> [unite]
      nnoremap [unite] <nop>

      if s:is_windows
        nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec:! buffer file_mru bookmark<cr><c-u>
        nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec:!<cr><c-u>
      else
        nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr><c-u>
        nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
      endif
      nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
      nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
      nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
      nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
      nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
      nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>
    "}}}
    NeoBundleLazy 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}}
    NeoBundleLazy 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}} "{{{
      nnoremap <silent> [unite]t :<C-u>Unite -auto-resize -buffer-name=tags tags tags/file<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} "{{{
      nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
    "}}}
    NeoBundleLazy 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}} "{{{
      nnoremap <silent> [unite]h :<C-u>Unite -auto-resize -buffer-name=help help<cr>
    "}}}
    NeoBundleLazy 'Shougo/junkfile.vim', {'autoload':{'commands':'JunkfileOpen','unite_sources':['junkfile','junkfile/new']}} "{{{
      let g:junkfile#directory=expand("~/.vim/.cache/junk")
      nnoremap <silent> [unite]j :<C-u>Unite -auto-resize -buffer-name=junk junkfile junkfile/new<cr>
    "}}}
  endif "}}}
  if count(s:settings.plugin_groups, 'misc') "{{{
    NeoBundle 'reedes/vim-wordy'
    NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown']}}
    NeoBundleLazy 'guns/xterm-color-table.vim', {'autoload':{'commands':'XtermColorTable'}}
    NeoBundle 'mhinz/vim-startify' "{{{
      let g:startify_session_dir = '~/.vim/.cache/sessions'
      let g:startify_show_sessions = 1
      nnoremap <F1> :Startify<cr>
    "}}}
    NeoBundle 'scrooloose/syntastic' "{{{
      let g:syntastic_python_checkers=['pyflakes', 'pep8', 'python']
      let g:syntastic_error_symbol='✗'
      let g:syntastic_style_error_symbol='✠'
      let g:syntastic_warning_symbol='∆'
      let g:syntastic_style_warning_symbol='≈'
      let g:syntastic_check_on_open=1
      let g:syntastic_aggregate_errors=1
      let g:syntastic_auto_loc_list=0
    "}}}
    NeoBundleLazy 'mattn/gist-vim', { 'depends': 'mattn/webapi-vim', 'autoload': { 'commands': 'Gist' } } "{{{
      let g:gist_post_private=1
      let g:gist_show_privates=1
    "}}}
    NeoBundleLazy 'zhaocai/GoldenView.Vim', {'autoload':{'mappings':['<Plug>ToggleGoldenViewAutoResize']}} "{{{
      let g:goldenview__enable_default_mapping=0
      nmap <F4> <Plug>ToggleGoldenViewAutoResize
    "}}}
  endif " }}} misc
" }}} plugin/mapping configuration

" mapping {{{
  let mapleader = ","
  let g:mapleader = ","
  let maplocalleader = ","
  let g:maplocalleader = ","

  " <Leader>o: only
  nnoremap <Leader>o :only<cr>

  " Go to previous buffer
  nnoremap <Leader><BS> :b#<CR>

  " <Leader>d: Delete the current buffer
  nnoremap <Leader>d :bdelete<CR>

  " redraw syntax
  nmap <silent> <leader>fs :syntax sync fromstart<cr>

  " formatting shortcuts
  vmap <leader>s :sort<cr>

  " quick save
  nnoremap <leader>w :w<cr>

  " toggle paste
  map <F6> :set invpaste<CR>:set paste?<CR>

  " remap arrow keys
  noremap <Up> <nop>
  noremap <Down> <nop>
  noremap <Left> <nop>
  noremap <Right> <nop>

  " smash escape
  inoremap jk <esc>
  inoremap kj <esc>

  " change cursor position in insert mode
  inoremap <C-h> <left>
  inoremap <C-l> <right>

  inoremap <C-u> <C-g>u<C-u>

  " sane regex {{{
    nnoremap / /\v
    vnoremap / /\v
    nnoremap ? ?\v
    vnoremap ? ?\v
    cnoremap s/ s/\v
  "}}}

  " folds {{{
    nnoremap zr zr:echo &foldlevel<cr>
    nnoremap zm zm:echo &foldlevel<cr>
    nnoremap zR zR:echo &foldlevel<cr>
    nnoremap zM zM:echo &foldlevel<cr>
  " }}}

  " screen line scroll
  nnoremap <silent> j gj
  nnoremap <silent> k gk

  " auto center after search {{{
    nnoremap <silent> n nzz
    nnoremap <silent> N Nzz
    nnoremap <silent> * *zz
    nnoremap <silent> # #zz
    nnoremap <silent> g* g*zz
    nnoremap <silent> g# g#zz
    nnoremap <silent> <C-o> <C-o>zz
    nnoremap <silent> <C-i> <C-i>zz
  "}}}

  " reselect visual block after indent
  vnoremap < <gv
  vnoremap > >gv

  " reselect last paste
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

  " find current word in quickfix
  nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
  " find last search in quickfix
  nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

  " shortcuts for windows {{{
    nnoremap <leader>v <C-w>v<C-w>l
    nnoremap <leader>s <C-w>s
    nnoremap <leader>vsa :vert sba<cr>
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    " _ : Quick horizontal splits
    nnoremap _ :sp<cr>
    " | : Quick vertical splits
    nnoremap <bar> :vsp<cr>
  "}}}

  " tab shortcuts
  map <leader>tn :tabnew<CR>
  map <leader>tc :tabclose<CR>

  " make Y consistent with C and D. See :help Y.
  nnoremap Y y$

  " hide annoying quit message
  nnoremap <C-c> <C-c>:echo<cr>

  " quick buffer open
  nnoremap gb :ls<cr>:e #

  " general
  nmap <leader>l :set list! list?<cr>
  nnoremap <BS> :set hlsearch! hlsearch?<cr>

  " Control-s to save
  nnoremap <C-s> :w<CR>
  inoremap <C-s> <C-o>:w<CR>
" }}} mapping

" autocmd {{{
  " go back to previous position of cursor if any
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \  exe 'normal! g`"zvzz' |
    \ endif

  autocmd FileType css,less setlocal foldmethod=marker foldmarker={,}
  autocmd FileType css,less nnoremap <silent> <leader>S vi{:sort<CR>
  autocmd FileType python setlocal foldmethod=indent
  autocmd FileType markdown setlocal nolist
  autocmd FileType vim setlocal fdm=indent keywordprg=:help
  autocmd FileType c,cpp,java,go,php,javascript,python,twig,xml,yml autocmd BufWritePre <buffer> call StripTrailingWhitespace()

" autocmd }}}

" color schemes {{{
  NeoBundle 'altercation/vim-colors-solarized' " {{{
    let g:solarized_termcolors=256
    let g:solarized_termtrans=0
  " }}}
  NeoBundle 'chriskempson/vim-tomorrow-theme'
  NeoBundle 'baskerville/bubblegum'
  NeoBundle 'Pychimp/vim-luna'
  NeoBundle 'tomasr/molokai'
  NeoBundle 'reedes/vim-colors-pencil'

  colorscheme pencil
  set background=dark
  if has("gui_running")
    set background=light
  endif
" color schemes }}}

" finish loading {{{
  filetype plugin indent on
  syntax enable
  NeoBundleCheck
" finish loading }}}
