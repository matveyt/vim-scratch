" Vim plugin for easy switching color schemes
" Maintainer:   matveyt
" Last Change:  2019 Nov 26
" License:      VIM License
" URL:          https://github.com/matveyt/vim-scratch

if exists('g:loaded_scratch') || &cp
    finish
endif
let g:loaded_scratch = 1
let s:save_cpo = &cpo
set cpo&vim

command! -range -addr=windows -bar -nargs=? -complete=var Scratch
    \ <line2>wincmd w | call call('scratch#open', split(<q-args>)[0:0])

let &cpo = s:save_cpo
unlet s:save_cpo
