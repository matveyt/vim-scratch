" Vim scratch buffer plugin
" Maintainer:   matveyt
" Last Change:  2019 Sep 19
" License:      VIM License
" URL:          https://github.com/matveyt/vim-scratch

" executes line range as VimScript
function! s:exec() range
    return execute(getline(a:firstline, a:lastline), '')
endfunction

" initialization routine
function! scratch#init(...)
    " options overwrite
    let l:opt = extend(copy(get(a:, 1, {})),
        \ {'buffer': "[Scratch]", 'key': "<F5>", 'syntax': "vim",
        \  'var': "g:SCRATCH_DATA"}, 'keep')
    let g:scratch#options = l:opt
    " create auto-commands
    augroup scratchPlugin | au!
        " execute scratch buffer
        if !empty(l:opt.key)
            let l:cmd = (l:opt.syntax ==# 'vim') ? "call <SID>exec()" :
                \ "w !" . get(l:opt, 'prog', l:opt.syntax)
            execute 'autocmd FileType scratch noremap <silent><buffer>' l:opt.key
                \ ':%' l:cmd "\<CR>"
            execute 'autocmd FileType scratch ounmap <buffer>' l:opt.key
        endif
        " save scratch buffer in a variable
        if !empty(l:opt.var)
            execute 'autocmd BufUnload' escape(l:opt.buffer, '[]') 'let' l:opt.var
                \ '=join(getbufline(str2nr(expand("<abuf>")), 1, "$"), "\n")'
        endif
    augroup end
endfunction

" switches current window to the scratch buffer
function! scratch#open()
    " ensure initialization
    if !exists('g:scratch#options')
        call scratch#init()
    endif
    " prepare scratch buffer
    let l:bufnr = bufadd(g:scratch#options.buffer)
    if !bufloaded(l:bufnr)
        call setbufvar(l:bufnr, "&bufhidden", "hide")
        call setbufvar(l:bufnr, "&buftype", "nofile")
        call setbufvar(l:bufnr, "&filetype", "scratch")
        call setbufvar(l:bufnr, "&swapfile", 0)
        call setbufvar(l:bufnr, "&syntax", g:scratch#options.syntax)
        call bufload(l:bufnr)
        " reload buffer from variable
        if exists(g:scratch#options.var) || g:scratch#options.var[0] ==# '@'
            call appendbufline(l:bufnr, 1, split(eval(g:scratch#options.var), "\n"))
            call deletebufline(l:bufnr, 1)
        endif
    endif
    " finally switch to scratch buffer
    call execute(l:bufnr . "buffer")
endfunction
