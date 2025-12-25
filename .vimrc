let s:path = expand('<sfile>:p') " Absolute path of script file

if has('nvim')
    echom printf("sourcing %s", s:path)
endif

if (0)
    " put this in /root/.vimrc at remote
    if (filereadable("/root/.config/.bash/.vimrc"))
        source /root/.config/.bash/.vimrc
    endif
    
    source ~/.config/vi/popups.vim
endif

if (1 == $IS_MY_VI_ENV)
    if (has('nvim'))
       " source /root/.config/nvim/init.lua
       source $HOME/.config/nvim/init.lua
    else
        source $VIMRUNTIME/mswin.vim
    endif
    set paste
    set nowrapscan
    
    nnoremap q :q<CR>
    nnoremap e :q<CR>
    nnoremap sn :set number!<CR>
    
    inoremap lj <Esc>
    cnoremap lj <Esc>
    
    nnoremap ; i
    
    nnoremap ; i
    nnoremap i k
    nnoremap k j
    nnoremap j h
    
    " scroll screen upd and down, <C-e> is already default
    nnoremap <C-r> <C-Y>
    
    vnoremap q <Esc>
endif


" Pathogen and plugins:
" Install to ~/.vim/autoload/pathogen.vim. Or copy and paste the following into your terminal/shell:
"     mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
"
" Runtime Path Manipulation
" Add this to your vimrc:
" execute pathogen#infect()"
"
" you can clone plugins to 

