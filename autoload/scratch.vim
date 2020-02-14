" Vim scratch buffer plugin
" Maintainer:   matveyt
" Last Change:  2020 Feb 12
" License:      VIM License
" URL:          https://github.com/matveyt/vim-scratch

let s:save_cpo = &cpo
set cpo&vim

let s:magic = "scratch_buffer"
let s:varcontent = "@s"

" switches current window into the scratch buffer
function! scratch#open(...)
    " find scratch buffer
    let l:match = filter(getbufinfo(), {_, v -> has_key(v.variables, s:magic)})
    let l:bufnr = empty(l:match) ? bufadd('') : l:match[-1].bufnr
    " prepare it for use
    if !bufloaded(l:bufnr)
        call setbufvar(l:bufnr, s:magic, 1)
        call setbufvar(l:bufnr, "&bufhidden", "hide")
        call setbufvar(l:bufnr, "&buftype", "nofile")
        call setbufvar(l:bufnr, "&swapfile", 0)
        if getbufvar(l:bufnr, "did_ftplugin")
            " ftplugin stuff seems to be there
            " but we must restore all :syntax elements
            call setbufvar(l:bufnr, "&syntax", "on")
        else
            " set filetype to match the current buffer
            call setbufvar(l:bufnr, "&filetype", &filetype)
        endif
        call bufload(l:bufnr)
        " reload buffer content from variable
        let l:varname = get(a:, 1, s:varcontent)
        silent! let l:content = eval(l:varname)
        if !empty(l:content)
            if type(l:content) == v:t_string
                let l:content = split(l:content, "\n")
            endif
            silent! call appendbufline(l:bufnr, 1, l:content)
            silent! call deletebufline(l:bufnr, 1)
        endif
        " auto-save buffer content
        try
            if l:varname[0] ==# '@'
                " to register
                call setreg(l:varname[1:], [])
                execute printf('autocmd BufUnload <buffer=%d> ++once ' .
                    \ 'call setreg("%s", getbufline(%d, 1, "$"))',
                    \ l:bufnr, l:varname[1:], l:bufnr)
            else
                " to variable
                let {l:varname} = []
                execute printf('autocmd BufUnload <buffer=%d> ++once ' .
                    \ 'let %s = getbufline(%d, 1, "$")',
                    \ l:bufnr, l:varname, l:bufnr)
            endif
        catch | endtry
    endif
    " finally switch the buffer
    execute 'buffer' l:bufnr
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
