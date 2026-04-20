" File: substitute_explorer.vim
" Author: wei may
" Version: 0.3
" Last Change: 10-Apr-2013.
" Written By: wei may
" First Release: Jun 5, 2009
"

scriptencoding cp932

" 二重インクルードガード {{{
if exists('loaded_substitute_explorer') || &cp
    finish
endif
let loaded_substitute_explorer=1
" }}}
" Global variables {{{
if !exists('SSE_Exclude_File_Pattern')
	let SSE_Exclude_File_Pattern = '.*\.o$\|.*\.obj$\|.*\.bak$\|.*\.swp$\|.*\~' .
                                  \ '\|^core\|^tags\|^TAGS\|^ID'
endif

if !exists('SSE_Exclude_Dir_Pattern')
	let	SSE_Exclude_Dir_Pattern = ""
endif

if !exists('g:SSE_UserHeader')
	let	g:SSE_UserHeader = []
endif


" Script local variable to keep track of the explorer state information
let	s:default_explorer_width = 30
" ↓この変数は後で無くしたい。ファイルオープン時に現在の幅を取得(←不明)して
" その幅を保持する方向で。
let	s:current_explorer_width = s:default_explorer_width
let	s:current_dirname = ''
let	s:global_globout = []
let s:explorer_bufname = '__Substitute_Explorer__'
let s:sse_winsize_chgd = 0
let	s:mark_list = []

let s:orig_ignorecase	= &ignorecase
let s:orig_incsearch	= &incsearch
let	s:orig_hlsearch		= &hlsearch

let s:parent_directory = "../"
" }}}
" Function definition {{{
" Public Interface {{{
" directoryには、「\n」を区切りとして複数のディレクトリを指定する事が可能
function! s:SSE_ToggleWindow(default_directory)
	let directory = a:default_directory
	"let directory = expand('%:p:h')

    " buffer name
    let bname = s:explorer_bufname

    " If explorer window is open then close it.
    let winnum = bufwinnr(bname)
    if winnum != -1
        if winnr() == winnum
            " Already in the explorer window. Close it and return
            close
        else
            " Goto the explorer window, close it and then come back to the
            " original window
            let curbufnr = bufnr('%')
            exe winnum . 'wincmd w'
            close
            " Need to jump back to the original window only if we are not
            " already in that window
            let winnum = bufwinnr(curbufnr)
            if winnr() != winnum
                exe winnum . 'wincmd w'
            endif
        endif
        return
    endif

    let w:sse_file_window = "yes"

    " Open the explorer window
    call s:SSE_OpenWindow()

    " List the files in the current directory
    call s:SSE_ShowListDir(directory)
endfunction
" }}}
" Internal Interface {{{
" SSE_OpenWindow()
" Create a new explorer window. If the window is already present, jump to
" the window
function! s:SSE_OpenWindow()
    " explorer window name
    let bname = s:explorer_bufname

    " If the window is already present, jump to the window
    let winnum = bufwinnr(bname)
    if winnum != -1
        " Jump to the existing window
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
        return
    endif

	if &columns < (80 + s:default_explorer_width)
		" one extra column is needed to include the vertical split
		let &columns= &columns + (s:default_explorer_width + 1)
		let s:sse_winsize_chgd = 1
	else
		let s:sse_winsize_chgd = 0
	endif


    " If the explorer temporary buffer already exists, then reuse it.
    " Otherwise create a new buffer
    let bufnum = bufnr(bname)
    if bufnum == -1
        " Create a new buffer
        let wcmd = bname
    else
        " Edit the existing buffer
        let wcmd = '+buffer' . bufnum
    endif

    " Create the explorer window
    "exe 'silent! ' . win_dir . ' ' . win_width . 'split ' . wcmd
	exe 'silent! ' . 'topleft vertical' . s:default_explorer_width . ' ' . 'split ' . wcmd

    " Mark the buffer as a scratch buffer
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nowrap
    setlocal nobuflisted
    setlocal nonumber
	call s:SSE_SettingOption()

    " Create buffer local mappings for the explorer window
    nnoremap <buffer> <silent> <CR> :call <SID>SSE_Select()<CR>
    nnoremap <buffer> <silent> <BackSpace> :call <SID>SSE_ChangeDirEx("..")<CR>
    nnoremap <buffer> <silent> p :call <SID>SSE_ChangeDirEx(@*)<CR>
    nnoremap <buffer> <silent> cd :call <SID>SSE_ChangeDir()<CR>
    nnoremap <buffer> <silent> cls :call <SID>SSE_ShowListNormal()<CR>
    nnoremap <buffer> <silent> cla :call <SID>SSE_ShowListAll()<CR>
    nnoremap <buffer> <silent> cld :call <SID>SSE_ShowListDirectory()<CR>
    nnoremap <buffer> <silent> cll :call <SID>SSE_ShowListDetail()<CR>
    nnoremap <buffer> <silent> clla :call <SID>SSE_ShowListAllDetail()<CR>

    nnoremap <buffer> <silent> R :call <SID>SSE_ShowListRefresh()<CR>
    nnoremap <buffer> <silent> D :call <SID>SSE_ShowListDeleteCursor()<CR>
    nnoremap <buffer> <silent> a :call <SID>SSE_ShowListRegexp(1)<CR>
    nnoremap <buffer> <silent> A :call <SID>SSE_ShowListRegexp(0)<CR>
    nnoremap <buffer> <silent> suf :call <SID>SSE_InputSuffixCommand(1)<CR>
    nnoremap <buffer> <silent> SUF :call <SID>SSE_InputSuffixCommand(0)<CR>

    nnoremap <buffer> <silent> rl :call <SID>SSE_ViewMax()<CR>
    nnoremap <buffer> <silent> rh :call <SID>SSE_ViewMin()<CR>
    nnoremap <buffer> <silent> rn :call <SID>SSE_ViewDefault()<CR>
    nnoremap <buffer> <silent> ri :call <SID>SSE_ViewInput()<CR>

    nnoremap <buffer> <silent> rmm :call <SID>SSE_MarkAdd()<CR>
    nnoremap <buffer> <silent> rmr :call <SID>SSE_MarkReverse()<CR>
    nnoremap <buffer> <silent> rmc :call <SID>SSE_MarkClear()<CR>

    nnoremap <buffer> <silent> rsa :call <SID>SSE_StoreAdd()<CR>
    nnoremap <buffer> <silent> rsp :call <SID>SSE_StoreShowList()<CR>
    nnoremap <buffer> <silent> rsc :call <SID>SSE_StoreClear()<CR>

    nnoremap <buffer> <silent> i :call <SID>SSE_ToggleOption()<CR>

    nnoremap <buffer> <silent> cm :call <SID>SSE_ExecuteCommand()<CR>
    nnoremap <buffer> <silent> rb :call <SID>SSE_ExecuteRuby()<CR>

    nnoremap <buffer> <silent> e :call <SID>SSE_OpenExplorer()<CR>
    nnoremap <buffer> <silent> dos :call <SID>SSE_OpenDosPrompt()<CR>
    "nnoremap <buffer> <silent> rx :call <SID>SSE_OpenRxvt()<CR>
    nnoremap <buffer> <silent> x :call <SID>SSE_ExecuteApplication()<CR>
    nnoremap <buffer> <silent> X :call <SID>SSE_ExecuteExcelReadOnly()<CR>
    nnoremap <buffer> <silent> P :call <SID>SSE_PrintDetail()<CR>
    nnoremap <buffer> <silent> ? :call <SID>SSE_ShowHelp()<CR>
    nnoremap <buffer> <silent> q :close<CR>

    " Highlight the comments, directories, types and names
    if has('syntax')
"        syntax match SsExplorerComment '^" .*'
"        highlight clear SsExplorerComment
"        highlight link SsExplorerComment SpecialComment
"
"        syntax match SsExplorerDirectory '^[^"].*/'
"        highlight clear SsExplorerDirectory
"        highlight link SsExplorerDirectory Directory
"
"        syntax match SsExplorerTagType '^  \S*$'
"        highlight clear SsExplorerTagType
"        highlight link SsExplorerTagType Type

        highlight clear SsExplorerTagName
        highlight link SsExplorerTagName Search

		highlight clear SsExplorerMark Function
		highlight link SsExplorerMark Function

        syn match  SseComment       '^" .*'
		syn match  SseDirectory     "^[^.].*\/$"
		syn match  SseHide          "^\..*"
		syn match  SseHideDirectory "^\..*\/$"
		syn match  SseLink "^.*\.lnk$"

        hi def link SseComment       Comment
		hi def link SseDirectory     Tag
		hi def link SseHide          ToDo
		hi def link SseHideDirectory Label
		hi def link SseLink          Function
    endif

    " Folding related settings
    if has('folding')
        setlocal foldenable
        setlocal foldmethod=manual
        setlocal foldcolumn=3
        "setlocal foldtext=SSE_FoldText()
    endif

    " Define the autocommands
    augroup SsExplorerAutoCmds
        autocmd!
        " Adjust the Vim window width when the explorer window is closed
        autocmd BufUnload __Substitute_Explorer__ call <SID>SSE_CloseWindow()
    augroup end
endfunction

function! s:SSE_SettingOption()
	let s:orig_ignorecase	= &ignorecase
	let s:orig_incsearch	= &incsearch
	let	s:orig_hlsearch		= &hlsearch

	set ignorecase
	set incsearch
	set hlsearch
endfunction

function! s:SSE_UnSettingOption()
	let &ignorecase	= s:orig_ignorecase
	let &incsearch	= s:orig_incsearch
	let	&hlsearch	= s:orig_hlsearch
endfunction

function! s:SSE_InitWindow()
    "" Clean up all the old variables used for the last directory
    "call s:SSE_DeleteStateInfo()

    " Remove the displayed text in the window

    " Mark the buffer as modifiable
    setlocal modifiable

    " Set report option to a huge value to prevent informational messages
    " about the deleted lines
    let old_report = &report
    set report=99999

    " Delete the contents of the buffer to the black-hole register
    silent! %delete _

    " Restore the report option
    let &report = old_report

    " Add comments at the top of the window
    call append(0, '" Press ? for help')
	let i = 1
	for element in g:SSE_UserHeader
		call append(i, '" ' . element)
		let i += 1
	endfor
    call append(i, '" =' . getcwd())

    " Mark the buffer as not modifiable
    setlocal nomodifiable
endfunction

" SSE_CloseWindow()
" Close the explorer window and adjust the Vim window width
function! s:SSE_CloseWindow()
    " Remove the autocommands for the explorer window
    silent! autocmd! SsExplorerAutoCmds

	" Adjust the Vim window width
	if 0 != s:sse_winsize_chgd
		let &columns= &columns - (s:default_explorer_width + 1)
	endif
	call s:SSE_UnSettingOption()
endfunction


function! s:SSE_Select()
	let s:current_dirname = getcwd()

	let line = getline(".")
	let real_name = s:SSE_ConvertLink(line)

	if isdirectory(real_name)
		call s:SSE_ChangeDirEx(real_name)
		return
	endif

	match none
	exe 'match SsExplorerTagName /\%' . line('.') . 'l.*/'

	let filename = s:current_dirname . '/' . real_name
	call s:SSE_OpenFile(filename)
endfunction

function! s:SSE_OpenFile(filename)
	let name = a:filename

    " If the file is opened in one of the existing windows, use that window
    let fwin_num = bufwinnr(name)
    if fwin_num != -1
        " Goto that window
        exe fwin_num . "wincmd w"
    else
        " Get buffer number
        let fwin_num = 0
        let i = 1
        while winbufnr(i) != -1
            if getwinvar(i, 'sse_file_window') == "yes"
                let fwin_num = i
                break
            endif
            let i = i + 1
        endwhile

        if fwin_num != 0
            " Jump to the file window
            exe fwin_num . "wincmd w"

            " If the user asked to jump to the tag in a new window, then split
            " the existing window into two.
            exe "edit " . name

			"wincmd p
			let ex_win_num = bufwinnr(s:explorer_bufname)
			exe ex_win_num . "wincmd w"

			exe 'vertical resize ' . s:current_explorer_width
			" Go back to the file window
			wincmd p
        else
			exe 'rightbelow vnew ' name
			" Go to the tag explorer window to change the window size to
			" the user configured value
			wincmd p

			exe 'vertical resize ' . s:current_explorer_width
			" Go back to the file window
			wincmd p

            let w:sse_file_window = "yes"
        endif
    endif
endfunction

function! s:SSE_ChangeDirEx(directory)
    if a:directory == ''
        return
    endif

    " Expand the entered path
    let newdir = expand(a:directory, ":p")

	"let real_name = s:SSE_ConvertLink(a:directory)
	"let real_name = a:directory
	if !isdirectory(newdir)
		"echo "Not directory : " . a:directory
		let msg = "Not directory : " . a:directory
        echohl WarningMsg | echomsg msg | echohl None
		return
	endif

    "echo "\n"

    " Save the current directory in the input history, so that this
    " can be retrieved later
    call histadd("input", s:current_dirname)

    " List the contents of the new directory
	call s:SSE_ShowListDir(newdir)

    setlocal nomodifiable
endfunction

function! s:SSE_ChangeDir()
    let newdir = input("Enter new directory: ")
	call s:SSE_ChangeDirEx(newdir)
endfunction

function! s:SSE_ShowListNormal()
	let list = s:SSE_GetListNormal()
    call s:SSE_ShowFileList(list)
endfunction

function! s:SSE_ShowListAll()
	let list = s:SSE_GetListAll(getcwd())
    call s:SSE_ShowFileList(list)
endfunction

function! s:SSE_ShowListDirectory()
	let list = s:SSE_GetListAll(getcwd())
	let result = []
	for name in list
        if name == ''
            continue
        endif

        " For directory names add a / at the end
        if isdirectory(name)
			call add(result, name)
		end
	endfor

    call s:SSE_ShowFileList(result)
endfunction

function! s:SSE_ShowListDetail()
	echo "Not Supported!!"
endfunction

function! s:SSE_ShowListAllDetail()
	echo "Not Supported!"
endfunction

function! s:SSE_ShowListRefresh()
	call s:SSE_ShowListDir(getcwd())
endfunction

function! s:SSE_ShowListDeleteCursor()
    let filename = getline(".")
    let line_num = line(".")

	let regexp = "^" . substitute(filename, '/', '', '') . "$"
    call s:SSE_ShowListRegexpCore(regexp, 0)
	call cursor(line_num, 0)
endfunction

function! s:SSE_ShowListRegexp(type)
    let regexp = input("Enter Regexp: ")

    call s:SSE_ShowListRegexpCore(regexp, a:type)
endfunction

function! s:SSE_ShowListRegexpCore(regexp, type)
	if empty(s:global_globout)
		let s:global_globout = s:SSE_GetListAll(getcwd())
	endif
	let s:global_globout = s:SSE_ExtractListRegexp(s:global_globout, a:regexp, a:type)

    call s:SSE_ShowFileList(s:global_globout)
endfunction

function! s:SSE_InputSuffixCommand(type)
	let user_input = toupper(input("Enter suffix type: "))

	let commands = s:SSE_SplitString(substitute(user_input, "\\s", "", "g") , ",")

	let suffixes = []
	for target in commands
		let cmd = tolower(target)
		if "script" == cmd 
			let suffixes = suffixes + ['script', 'sh', 'rb', 'pl']
		elseif "document" == cmd
			let suffixes = suffixes + ['document', 'xls', 'ppt', 'doc', 'pdf', 'txt']
		elseif "csource" == cmd
			let suffixes = suffixes + ['csource', 'h', 'cpp', 'c']
		elseif "design" == cmd
			let suffixes = suffixes + ['design', 'jude', 'mm']
		elseif "archive" == cmd
			let suffixes = suffixes + ['archive', 'tar.gz', 'tgz', 'zip', 'lzh']
		else
			echo "Special suffix : script, document, csource, design, archive"
			let suffixes = [cmd]
		endif
	endfor

	call s:SSE_ExtractSuffix(suffixes, a:type)
endfunction

function! s:SSE_ViewMax()
	let s:current_explorer_width = s:default_explorer_width
	call s:SSE_ViewValue("")
endfunction

function! s:SSE_ViewMin()
	let s:current_explorer_width = s:default_explorer_width
	call s:SSE_ViewValue("1")
endfunction

function! s:SSE_ViewDefault()
	let s:current_explorer_width = s:default_explorer_width
	call s:SSE_ViewValue(s:default_explorer_width)
endfunction

function! s:SSE_ViewInput()
	let value = input( "Width: " )
	let s:current_explorer_width = value
	call s:SSE_ViewValue(value)
endfunction

function! s:SSE_ViewValue(value)
	let run = "normal " . a:value . "|"
	exe run
endfunction

function! s:SSE_MarkAdd()
	echo "Not Supported!!"
	call add( s:mark_list, getline('.') )
	"call s:SSE_MarkView()
endfunction

function! s:SSE_MarkReverse()
	echo "Not Supported!!"
	"call s:SSE_MarkView()
endfunction

function! s:SSE_MarkClear()
	echo "Not Supported!!"
	let s:mark_list = []
	"call s:SSE_MarkView()
endfunction

function! s:SSE_MarkView()
	let regexp = ""
	for target in s:mark_list
		if 0 != strlen(regexp)
			let regexp = regexp . '\|'
		endif
		let regexp = regexp . '^' . target . '$'
	endfor

	" ちょっと暫定
	"call s:SSE_UnSettingOption()
	"exe 'match SsExplorerMark /' . regexp . '/'
	"call s:SSE_SettingOption()
	""exe 'match SsExplorerMark /\%' . line('.') . 'l.*/'
endfunction

function! s:SSE_StoreAdd()
	echo "Not Supported!!"
endfunction

function! s:SSE_StoreShowList()
	echo "Not Supported!!"
endfunction

function! s:SSE_StoreClear()
	echo "Not Supported!!"
endfunction

function! s:SSE_ToggleOption()
	" とりあえずhlsearchのみで判断してしまう
	if &hlsearch
		call s:SSE_UnSettingOption()
	else
		call s:SSE_SettingOption()
	endif
endfunction

function! s:SSE_ExecuteCommand()
	echo "Not Supported!!"
endfunction

function! s:SSE_ExecuteRuby()
	echo "Not Supported!!"
endfunction

function! s:SSE_OpenExplorer()
	if	!has('win32') && !has('mac')
		echo "Sorry, this function is supported windows or mac only."
		return
	endif

	"let output = system( "explorer.exe " . getcwd() )
	let pwd = substitute(getcwd(), '\\$', "", "")
	let line = getline(".")
	if s:parent_directory == line
		if	has('win32')
			let select = substitute(pwd, '^.*\\\([^\\]\+\)$', '\1', '')
			let pwd = substitute(pwd, '^\(.*\)\\[^\\]\+$', '\1', '')
		elseif	has('mac')
			let select = substitute(pwd, '^.*/\([^/]\+\)$', '\1', '')
			let pwd = substitute(pwd, '^\(.*\)/[^/]\+$', '\1', '')
		endif
	else
		let select = substitute(substitute(line, '^".*$', "", ""), "/$", "", "")
	endif

	if "" == select
		if	has('win32')
			let output = system( "explorer.exe " . pwd )
			let comment = " on Explorer"
		elseif	has('mac')
			let output = system( "open " . pwd )
			let comment = " on Finder"
		endif
		echo "Opened " . pwd . comment
	else
		if	has('win32')
			let output = system( "explorer.exe /select," . s:SSE_EscapeFilePath(pwd . '\' . select) )
			let comment = " on Explorer"
		elseif	has('mac')
			let output = system( "open -R " . s:SSE_EscapeFilePath(pwd . '/' . select) )
			let comment = " on Finder"
		endif
		echo "Opened " . pwd . "@" . select . comment
	endif
endfunction

function! s:SSE_OpenDosPrompt()
	if	!has('win32')
		echo "Sorry, this function is supported windows only."
		return
	endif

	"let output = system( "cmd.exe /k cd " . s:SSE_EscapeFilePath(getcwd()) )
	let filename = s:SSE_EscapeFilePath( getcwd() )
	let run = "silent ! start " . filename
	exe run
endfunction

"function! s:SSE_OpenRxvt()
"	let output = system( "rxvt.exe -fn msgothic-14 -fm msgothic-14 -km sjis -e ./tcsh.exe" )
"	let output = system( "rxvt.exe -fn msgothic-14 -fm msgothic-14 -km sjis" )
"endfunction

function! s:SSE_ExecuteApplication()
	if	!has('win32') && !has('mac')
		echo "Sorry, this function is supported windows or mac only."
		return
	endif

	"let filename = s:SSE_ConvertLink( getline(".") )
	"let output = system( s:SSE_EscapeFilePath(filename) )
	let filename = s:SSE_EscapeFilePath( s:SSE_ConvertLink( getline(".") ) )
	"let run = "silent ! start " . filename
	" windowsのstartの仕様で、最初の二重引用符はウィンドウタイトルになる。
	" 従って、最初に捨て文字列(hoge)を追加しておく。
	"   参考 : http://d.hatena.ne.jp/mizuki_astral/20100715/1279203356
	if	has('win32')
		let run = "silent ! start \"hoge\" " . filename
	elseif	has('mac')
		let run = "silent ! open " . filename
	endif
	exe run
endfunction

function! s:SSE_ExecuteExcelReadOnly()
	let filename = s:SSE_ConvertLink( getline(".") )

	if filename =~ "\.xls$"
		let output = system( "\"C:\\Program Files\\Microsoft Office\\Office10\\EXCEL.EXE\" /r " . filename )
	else
		echo "Not excel file. '(" . filename . ")"
	endif
endfunction

function! s:SSE_PrintDetail()
	let filename = getline(".")
	let size = getfsize(filename)
	let time = getftime(filename)
	"echo "time = " . strftime("%Y/%H/%M") . ", size = " . size . " [bytes]"
	echo strftime("%c") . ", " . size . " [bytes]"
endfunction

function! s:SSE_ShowHelp()
    echo 'Substitute Explorer keyboard shortcuts'
    echo '-------------------------------'
    echo '<Enter> : File : Open file, Directory : Open directory'
    echo '<Back>  : Move to parent directory'
    echo 'p       : Goto a directory by clipboard path'
    echo 'c<command> : cd, ls, la, ld, ll, lla'

    echo 'R       : Refresh file list'
    echo 'D       : Delete file list by cursor'
    echo 'a       : Extract file list by Regexp'
    echo 'A       : Extract file list by Regexp(Opposite)'
	echo 'suf<command> : Extract file suffix'
	echo 'SUF<command> : Extract file suffix(Opposite)'

    echo 'rh      : Change window width min(^W1|)'
    echo 'rl      : Change window width max(^W|)'
    echo 'rn      : Change window width default(^W' . s:default_explorer_width . '|)'
    echo 'ri      : Change window width user input'

    echo 'rmm     : Marked file or directory'
    echo 'rmr     : Reverse mark'
    echo 'rmc     : Clear mark'

    echo 'rsa     : Add store cursor directory'
    echo 'rsp     : Show list all store'
    echo 'rsc     : Clear store'

    echo 'i       : toggle option'

    echo 'cm      : execute input command'
    echo 'rb      : execute ruby 1 liner'

    echo 'e       : Open explorer by current directory'
    echo 'dos     : Open dos prompt by current directory'
    "echo 'rx      : Open Rxvt'
    echo 'x       : Execute application'
    echo 'X       : Open Excel file by read only'
    echo 'P       : Print file detail'
    echo '?       : Print help'
    echo 'q       : Close the explorer window'
endfunction




" List the filenames in the specified directory
function! s:SSE_ShowListDir(dirname)
	let s:global_globout = []

    exe "lchdir " . a:dirname
    " Store the full path to the current directory
    let s:current_dirname = getcwd()

    call s:SSE_ShowFileList(s:SSE_GetListNormal())
endfunction

function! s:SSE_ShowFileList(list)
	call s:SSE_InitWindow()

	let dir_list = []
	let file_list = []

    " Process all the files in the directory list
	for name in a:list
        if name == ''
            continue
        endif

        " For directory names add a / at the end
        if isdirectory(name)
            if g:SSE_Exclude_Dir_Pattern != ''
                if name =~? g:SSE_Exclude_Dir_Pattern
                    continue
                endif
            endif
"            if g:SSE_Include_Dir_Pattern != ''
"                if name !~? g:SSE_Include_Dir_Pattern
"                    continue
"                endif
"            endif

			if name == "."
				continue
			endif

			if name == ".."
				continue
			endif

			call add(dir_list, name . "/" )
        else
            if g:SSE_Exclude_File_Pattern != ''
                if name =~? g:SSE_Exclude_File_Pattern
                    continue
                endif
            endif
"            if g:SSE_Include_File_Pattern != ''
"                if name !~? g:SSE_Include_File_Pattern
"                    continue
"                endif
"            endif

			call add(file_list, name)
        endif
	endfor

	let out_dir_list = s:SSE_ConvertString(s:SSE_SortName(dir_list))
	let out_file_list = s:SSE_ConvertString(s:SSE_SortName(file_list))

	let out_list = s:parent_directory . "\n" . out_dir_list . out_file_list

    " Clear search highlighted name.
    match none

    " Copy the directory list to the buffer
    setlocal modifiable

    " Set report option to a huge value to prevent informations messages
    " while deleting the lines
    let old_report = &report
    set report=99999

    "exe 'silent! ' . s:comments . 'put =list_txt'
    "exe 'silent! ' . s:comments . 'put =file_list'
	" Move to last line
	" Delete no info line
	:g/^\s*$/d
	let start_line = line(".")
	normal G
    exe 'silent! ' . 'put =out_list'

    " Restore the report option
    let &report = old_report
    setlocal nomodifiable

    " Place the cursor at the first directory name after the header
    exe start_line + 1

    normal z.
endfunction

function! s:SSE_GetDirName(name)
	return	a:name . "/"
endfunction

function! s:SSE_GetFileName(name)
	return	a:name
endfunction

function! s:SSE_GetListNormal()
	return	s:SSE_GetGlob("*")
endfunction

function! s:SSE_GetListAll(directory)
	let glob = s:SSE_GetGlob(".*")
	return	glob + s:SSE_GetListNormal()
endfunction


function! s:SSE_EscapeFilePath(filename)
	"return	escape(escape(a:filename, "\\"), " ")
	return	"\"" . a:filename . "\""
endfunction

function! s:SSE_ConvertLink(link)
	if a:link =~ "\.lnk$"
		"let real_name = resolve(a:link)
		"return	strpart(real_name, matchend(real_name, escape(getcwd(), "\\"))+1, strlen(real_name))	" 絶対パスを相対パスにする。必要ないのでコメントアウト
		return	resolve(a:link)
	endif
	return	a:link
endfunction

function! s:SSE_ExtractListRegexp(flist, regexp, flag)
	let result = []
	for name in a:flist
        if name == ''
            continue
        endif

		if 1 == a:flag
			" flagが1の時はmatchしたもののみを残す
			if -1 == match(name, a:regexp)
				continue
			endif
		else
			" flagが0の時はmatchしたものを削除
			if -1 != match(name, a:regexp)
				continue
			endif
		endif

		call add(result, name)
	endfor
	return	result
endfunction

function! s:SSE_SplitString(target, split_string)
	let result = []
	let string = substitute(a:target, a:split_string . "*$", a:split_string, '')
    while string != ''
        " Process one file at a time
        let name = strpart(string, 0, stridx(string, a:split_string))

        " Remove the extracted file name
        let string = strpart(string, stridx(string, a:split_string) + strlen(a:split_string) )

        if name == ''
            continue
        endif

		call add(result, name)
	endwhile
	return	result
endfunction

function! s:SSE_ExtractSuffix(suffixes, type)
	let regexp = ""
	for target in a:suffixes
		if "" == regexp 
			let regexp = s:SSE_MakeSuffixRegexp(target)
		else
			let regexp = regexp . '\|' . s:SSE_MakeSuffixRegexp(target)
		endif
	endfor

    call s:SSE_ShowListRegexpCore(regexp, a:type)
endfunction

function! s:SSE_MakeSuffixRegexp(suffix)
	return	'\.' . a:suffix . '$'
endfunction

function! s:SSE_GetGlob(glob)
	let globout = glob(a:glob) . "\n"
	let result = []
    while globout != ''
        " Process one file at a time
        let name = strpart(globout, 0, stridx(globout, "\n"))

        " Remove the extracted file name
        let globout = strpart(globout, stridx(globout, "\n") + 1)

        if name == ''
            continue
        endif

		call add(result, name)
	endwhile
	return	result
endfunction

function! s:SSE_ConvertString(list)
	let result = ""
	for name in a:list
		let result = result . name . "\n"
	endfor
	return	result
endfunction
	
function! s:SSE_SortName(list)
	return	sort(a:list)
	" 後でソートはしっかりと実装(名前のみだったら現状でも問題無し)
"	for name in a:list
"	endfor

"    let i = 0
"    while i < dir_count
"        let key = dir_{i}
"
"        let j = i - 1
"
"        while j > 0 && dir_{j} >? key
"            let dir_{j + 1} = dir_{j}
"            let j = j - 1
"        endwhile
"
"        let dir_{j + 1} =  key
"
"        let i = i + 1
"    endwhile
endfunction
" }}}
" }}}
" Command definition {{{
" Define the command to open/close the explorer window
"command! -nargs=0 SubstituteExplorer :call s:SSE_ToggleWindow()
"command! -nargs=1 SubstituteExplorer :call s:SSE_ToggleWindow(<q-args>)
"command! -nargs=0 SubstituteExplorer :call s:SSE_ToggleWindow()
command! -nargs=1 SubStituteExplorer :call s:SSE_ToggleWindow(<q-args>)
" }}}
" vim: set fdm=marker :
