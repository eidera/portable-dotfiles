" vim: set fdm=marker :
scriptencoding utf-8

set columns=105
set lines=45
set guioptions-=T
set linespace=0
set nohls

" カラーテーマを設定
gui
set background=dark
colorscheme mysolarized


" window サイズ変更ショートカット関数 {{{
command! -nargs=0 MyWinSizeChange :call MyWinSizeChange()
function! MyWinSizeChange()
	execute "winsize 150 53"
endfunction

command! -nargs=0 MyWinSizeChange2 :call MyWinSizeChange2()
function! MyWinSizeChange2()
  execute "winsize 187 80"
endfunction

" }}}
" フォント設定 {{{
command! -nargs=0 FontChangeOsaka :call FontChangeOsaka()
function! FontChangeOsaka()
  set guifont=Osaka-Mono:h16
  set guifontwide=Osaka-Mono:h16
endfunction

command! -nargs=0 FontChange0xProto :call FontChange0xProto()
function! FontChange0xProto()
  set guifont=0xProto:h14
  set guifontwide=Osaka-Mono:h16
endfunction

" default font setting: guifont関連を設定すると `:intro` の起動時メッセージが表示されなくなる模様
"call FontChange0xProto()
call FontChangeOsaka()
" }}}
