scriptencoding cp932

" 二重インクルードガール
if exists('loaded_substitute_explorer_wrapper') || &cp
    finish
endif
let loaded_substitute_explorer_wrapper=1


function! s:SSEW_Execute()
    execute "SubStituteExplorer " . expand('%:p:h')
endfunction

command! -nargs=0 SubstituteExplorerWrapper :call s:SSEW_Execute()
