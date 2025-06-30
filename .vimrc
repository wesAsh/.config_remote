if (0)
    " put this in /root/.vimrc at remote
    if (filereadable("/root/.config/.bash/.vimrc"))
        source /root/.config/.bash/.vimrc
    endif
    
    source ~/.config/vi/popups.vim
endif

if (1 == $IS_MY_VI_ENV)
    source $VIMRUNTIME/mswin.vim
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


