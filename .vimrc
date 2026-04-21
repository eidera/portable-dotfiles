" vim: set fdm=marker :
scriptencoding utf-8

" 基本設定 {{{
set tabstop=2
set shiftwidth=2
set expandtab
set report=0
set showmatch
set autoindent
set cindent
set ignorecase
set smartcase
set	backup
set relativenumber " カーソルからの相対位置を表示
set wrap  " 折り返し表示

set noincsearch
set nohlsearch
set backspace=0	" バックスペースの動作をviと同様にする
set wildmenu	" 補完候補を表示する
set modeline	" モードライン(各ファイル毎の設定)を有効にする
set modelines=5	" モードラインを探す行数
set laststatus=2	" 常にステータスラインを表示する
set ruler		" カーソルの位置を常に表示
set scrolloff=0 " 指定した行数だけ余裕を持ってスクロールさせる(0の場合は、余裕を持たせない)

set conceallevel=0 " テキストを通常通り表示する。(例えば、json開いたときにダブルクォートを表示させるとか、markdownでアンダースコアを常に表示させるとか)
set helplang=ja,en " ヘルプの言語設定

if !has("linux")
  set matchpairs=(:),{:},[:],【:】 " %でジャンプする対のペアの設定(defaultは `(:),{:},[:]` )
end

set showcmd " ビジュアルモードで選択中の文字数や行数を右下に表示する

syntax enable

" Reload vimrc
if !exists("*ReloadVimrc")
  function ReloadVimrc()
    :source $MYVIMRC
    call LightlineReload()
  endfunction
  command! ReloadVimrc call ReloadVimrc()
endif

" mac {{{
if !exists('g:vscode')
  if has("mac")
    set ambiwidth=double
  endif
endif
" }}}
" }}}
" 拡張基本設定 {{{
"" Home Directory配下のvim設定関連のパス {{{
let my_vim_path = '~/.vim'
"" }}}
" C-u {{{
inoremap <C-U> <C-U>
" }}}
" ステータスライン {{{
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
" }}}
" 文字コード関連設定  {{{
set encoding=utf-8
set fileencodings=utf-8,cp932,euc-jp,sjis,latin1
" When do not include Japanese, use encoding for fileencoding. " {{{
function! s:ReCheck_FENC()
  let is_multi_byte = search("[^\x01-\x7e]", 'n', 100, 100)
  if &fileencoding =~# 'iso-2022-jp' && !is_multi_byte
    let &fileencoding = &encoding
  endif
endfunction
" }}}
" }}}
" tabstop、shiftwidthの簡易切替 {{{
function! ChangeTsSw()
	let value = input("ts sw value: ")
  let &ts = value
  let &sw = value
  let &softtabstop = value
endfunction

nnoremap ,ts :<C-u>call ChangeTsSw()<CR>
" }}}
" 折り畳みの表示フォーマットの設定 {{{
set foldtext=FoldCCtext()
set foldcolumn=0
set fillchars=vert:\|

nnoremap <C-Q>f :call MyToggleFoldcolumn()<CR>

function! MyToggleFoldcolumn()
	if	0 == &foldcolumn
		set foldcolumn=8
	else
		set foldcolumn=0
	end
endfunction
" }}}
" インクリメンタルサーチ&サーチハイライトをトグルさせる設定 {{{
function! MyToggleSearchEffect()
	if	0 == &incsearch
		setlocal incsearch
		echo "incsearch on"
	else
		setlocal noincsearch
		echo "incsearch off"
	end

	if	0 == &hlsearch
		setlocal hlsearch
		echo "hlsearch on"
	else
		setlocal nohlsearch
		echo "hlsearch off"
	end
endfunction

nnoremap <silent> ,,s :<C-u>call MyToggleSearchEffect()<CR>
" }}}
" カーソル位置強調をトグルさせる設定 {{{
function! MyToggleCursorHighlight()
	if	0 == &cursorline
		setlocal cursorline
	else
		setlocal nocursorline
	end

	if	0 == &cursorcolumn
		setlocal cursorcolumn
	else
		setlocal nocursorcolumn
	end
endfunction

nnoremap <silent> ,,c :<C-u>call MyToggleCursorHighlight()<CR>
" }}}
" Spell check機能をトグルさせる設定 {{{
function! MyToggleSpellCheck()
	if	0 == &spell
		setlocal spell
		echo "spell on"
	else
		setlocal nospell
		echo "spell off"
	end
endfunction

nnoremap <silent> ,,p :<C-u>call MyToggleSpellCheck()<CR>
" }}}
" rtputil.vimの設定(bundle以下のpluginを読込むプラグイン。なるべく上の方に記載しておく) {{{
call rtputil#bundle()
" }}}
" ペーストした直後のテキストをビジュアルモードで選択する {{{
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
" }}}
"" PATHの設定 {{{
if has("mac") || has("unix")
  " ~/binとカレントディレクトリをMY_PATHに設定
  let MY_PATH=$HOME."/bin:."
  " asdf の パスもMY_PATHに設定
  let MY_PATH=MY_PATH.":".$HOME."/.asdf/shims:"
  let $PATH=$PATH."/bin:/usr/bin:/usr/local/bin:/opt/homebrew/bin:/sbin:/usr/sbin".":".MY_PATH
endif
"" }}}
" gui用runtimepathの追加 {{{
if has("mac")
	if has('gui')
	  :set runtimepath+=~/.vim/gui
	endif
endif
" }}}
" set list時にTABを分かりやすく表示する {{{
set listchars=tab:>-,trail:*,nbsp:%,extends:>,precedes:<,eol:$
" }}}
" Visual mode での * {{{
" visual modeで選択している文字列を「*」で検索する(http://vim-users.jp/2009/11/hack104/)
"   これは、レジスタvを退避せずに破壊しているので注意。
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
" }}}
" 行分割コマンド {{{
command! -nargs=1 -range=% SplitLineCharacter :call SplitLineCharacter(<q-args>, <line1>, <line2>)
command! -nargs=0 -range=% SplitLinePunctuation :call SplitLineCharacter("、。，．", <line1>, <line2>)
command! -nargs=0 -range=% SplitLineJpPunctuation :call SplitLineCharacter("、。", <line1>, <line2>)
command! -nargs=0 -range=% SplitLineEnPunctuation :call SplitLineCharacter("，．", <line1>, <line2>)

function! SplitLineCharacter(chars, start, end)
	let run = printf("%d",a:start) . "," . printf("%d",a:end) . "s/[" . a:chars . "]/&/g"
	execute run
endfunction
" }}}
" 電卓 {{{
vnoremap <silent> <C-c> "vy`>a=<C-r>=string(eval(@v))<CR>

inoremap <silent> <C-C> <C-R>=MiniCalculator()<CR>

function! MiniCalculator()
	let calc_formula = input("Calculate: ")
	return calc_formula . "=" . string(eval(calc_formula))
endfunction
" }}}
" Omni補完のユーザーリスト補完を<C-g>に割り当て {{{
inoremap <C-g> <C-x><C-o>
" }}}
" 矢印キーを見た目移動に設定 {{{
nmap <up>    gk
nmap <down>  gj
nmap <home>  g0
nmap <end>   g$
" }}}
" バックアップファイルを削除 {{{
function! s:DeleteBackupFiles()
	call s:DeleteBackupFilesCore( ['.*~', '*~', '.DS_Store'] )
endfunction

command! -nargs=0 DeleteBackupFiles :call s:DeleteBackupFiles()

function! s:DeleteBackupFilesCore(glob_list)
	let target = []
	let i = 0
	while i < len(a:glob_list)
		let glob_pattern = a:glob_list[i]

		let globout = glob(glob_pattern) . "\n"
		while globout != ''
			" Process one file at a time
			let name = strpart(globout, 0, stridx(globout, "\n"))

			" Remove the extracted file name
			let globout = strpart(globout, stridx(globout, "\n") + 1)

			if name == ''
				continue
			endif

			call add(target, name)
		endwhile

		let i = i + 1
	endwhile

	call s:DeleteFilelist(target)
endfunction

function! s:DeleteFilelist(list)
	let target = a:list

	let num = len(target)
	if 0 == num
		echo "No target file"
		return
	endif

	echo "The deleted file is shown."
	let j = 0
	while j < num
		echo target[j]
		let j = j + 1
	endwhile
	let yn = input("OK? (y or n) -> ")
	echo "\n"
	"echo yn

	if "y" == yn
		let j = 0
		while j < len(target)
			call delete(target[j])
			"call delete(expand(target[j]))
			"echo(target[j])
			let j = j + 1
		endwhile
		echo "Deleted!!"
		return
	endif
	echo "Canceled."
endfunction
" }}}
" C-W関連で思いもよらない動作になるキー定義をnopにする {{{
" ↓「:wq」と同じだと思われる
nnoremap <C-W><C-Q> nop
" }}}
" terminal modeの設定{{{
tmap <C-W>[ <C-W>N " terminal-normalモードへの移行キーをscreenぽいキーバインドを追加

nnoremap ,vv :<C-U>vert terminal<CR>
nnoremap ,vs :<C-U>terminal<CR>

if has("mac")
  set shell=/bin/zsh
endif
" }}}
" 開いているファイルをVSCodeなどいくつかのアプリケーションをfzfで選択的に開く {{{
if has("mac")
  function! OpenWithEditor()
    let l:file = expand('%:p')

    " アプリの追加・変更はここだけ
    let l:apps = {
      \ 'VSCode':  'code '        . shellescape(l:file),
      \ 'Bokuchi': 'open -a Bokuchi ' . shellescape(l:file),
      \ 'MacVimRemoteTab': 'open -a MacVimRemoteTab ' . shellescape(l:file),
    \ }

    call fzf#run(fzf#wrap({
      \ 'source':  keys(l:apps),
      \ 'sink':    {choice -> system(l:apps[choice])},
      \ 'options': ['--prompt=Open with> ', '--height=~50%'],
    \ }))
  endfunction

  nnoremap <C-W><C-C> :<C-U>call OpenWithEditor()<CR>
endif
" }}}
" utf8で開きなおす {{{
nnoremap <C-W><C-U><C-T> :<C-U>e ++enc=utf8<CR>
" }}}
" 行番号表示関連 {{{
" 行番号のトグル: number と nonumber をトグル
nnoremap ,,n :set number!<CR>
" 相対行番号のトグル: relativenumber と norelativenumber をトグル
nnoremap ,,r :set relativenumber!<CR>
" }}}
" 色々 {{{
" C-a,C-xで8進数を削除する
set nrformats-=octal
" Kでvimのヘルプを検索するようにする。mac,linuxのデフォルトは「man -s」。詳細は「help K」で。
set keywordprg=:help

augroup MyEtcAuGroup
  autocmd!

  " デフォルトvimrc_exampleのtextwidth設定上書き
  autocmd FileType text setlocal textwidth=0

  " 常に開いているファイルのディレクトリに移動する
  "autocmd BufReadPost *   execute ":lcd " . expand("%:p:h")
  autocmd BufReadPost * if expand("%") != "" && !isdirectory(expand("%:p")) | execute ":lcd " . expand("%:p:h") | endif

  " makeやgrep使用時にマッチしたファイルがあったらQuickFixを開くようにする
  autocmd QuickfixCmdPost make,grep,grepadd,vimgrep cw
augroup END
" }}}
" }}}
" filetype設定 {{{
let g:plantuml_executable_script="plantuml"

function! MyPhpSettings()
  set tabstop=4
  set shiftwidth=4
  set autoindent
endfunction

function! MyJsSettings()
  set tabstop=2
  set shiftwidth=2
  set autoindent
endfunction
"
augroup MyFiletypeAuGroup
  autocmd!
  autocmd BufNewFile,BufRead *.rb set tabstop=2 shiftwidth=2

  autocmd BufNewFile,BufRead *.slim set filetype=slim
  autocmd BufNewFile,BufRead *.scala set filetype=scala
  autocmd BufNewFile,BufRead *.sbt set filetype=scala
  autocmd BufNewFile,BufRead *.twig set filetype=html
  autocmd BufNewFile,BufRead *.es6 set filetype=javascript
  autocmd BufNewFile,BufRead *.ejs set filetype=ejs
  autocmd BufNewFile,BufRead *.dart set filetype=dart

  autocmd BufRead,BufNewFile,BufReadPre *.coffee set filetype=coffee
  autocmd BufNewFile,BufRead *.swift set filetype=swift

  autocmd BufNewFile,BufRead *.pu set filetype=plantuml
  autocmd BufNewFile,BufRead *.uml set filetype=plantuml
  autocmd BufNewFile,BufRead *.plantuml set filetype=plantuml
  autocmd Filetype plantuml let &l:makeprg=g:plantuml_executable_script . " " .  fnameescape(expand("%"))

  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile *.mkd set filetype=markdown

  autocmd BufNewFile,BufRead *.vue set filetype=vue

  autocmd BufNewFile,BufRead *.ts set filetype=typescript
  "autocmd FileType typescript setlocal completeopt-=menu

  autocmd FileType go setlocal noexpandtab ts=4 sw=4

  autocmd BufNewFile,BufRead *.kt setfiletype kotlin
  autocmd BufNewFile,BufRead *.kts setfiletype kotlin

  autocmd BufNewFile,BufRead *.bats setfiletype sh

  autocmd BufNewFile,BufRead *.prisma setfiletype graphql
  autocmd BufNewFile,BufRead *.graphql setfiletype graphql
  autocmd BufNewFile,BufRead *.graphqls setfiletype graphql
  autocmd BufNewFile,BufRead *.gql setfiletype graphql

  autocmd FileType *php* call MyPhpSettings()
  autocmd FileType *javascript* call MyJsSettings()
augroup END
" }}}
" 使用しているvim scriptの設定 {{{
" vim-plugの設定 {{{
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif


function! SetupRtputil(info)
  call system('mkdir -p ~/.vim/autoload')
  call system('cp -a ~/.vim/plugged/vim-rtputil/autoload/* ~/.vim/autoload/.')
endfunction

call plug#begin()

Plug 'thinca/vim-rtputil', { 'commit': 'c477b17e45f6e975ee54102468e9e1f5cd0dffa8', 'do': function('SetupRtputil') }
Plug 'eidera/BlockDiff', { 'commit': 'eadaf191c18b6a05e398ab42ca7183908fa27d05' }
Plug 'mileszs/ack.vim', { 'commit': '36e40f9ec91bdbf6f1adf408522a73a6925c3042' } " ag用
Plug 'junegunn/fzf', { 'tag': 'v0.71.0', 'do': { -> fzf#install() } }
Plug 'itchyny/lightline.vim', { 'commit': '6c283f8df85aa7219fa4096a6ed4ff45d48aa9e1' }
Plug 'mattn/vim-maketable', { 'commit': 'd72e73f333c64110524197ec637897bd1464830f' }
Plug 'simeji/winresizer', { 'commit': '299076f7f79e2e2f7706b2dfacbb3c074ce53257' }
Plug 'junegunn/vim-easy-align', { 'tag': '2.10.0' }
Plug 'thinca/vim-fontzoom', { 'commit': 'b411334b6abaaf07380521d8446a59553fc7f57f' }
Plug 'tpope/vim-surround', {'commit': '3d188ed2113431cf8dac77be61b842acb64433d9' }
Plug 'tpope/vim-fugitive', {'commit': '3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0' }
Plug 'kana/vim-operator-user', {'tag': '0.1.0' }
Plug 'tyru/operator-camelize.vim', {'commit': '1d029632bc7ba28a8ecf59274d2b958046348611' }
Plug 'deris/vim-rengbang', { 'commit': 'e8c58cade2208b90dca989abfa9bcf1d79c4e931' }
Plug 'Omochice/yank-remote-url.vim', { 'commit': '6b6d604ae7bf974d0733340f4d4338491dacab0d' }
Plug 'aklt/plantuml-syntax', {'commit': '9d4900aa16674bf5bb8296a72b975317d573b547' }
Plug 'supermomonga/projectlocal.vim', { 'commit': '4cc075b8be68f843d78e6a4cbbe4eaa1ecb1a31d' }
Plug 'vim-scripts/MultipleSearch', { 'tag': '1.3' }
Plug 'Shougo/vimfiler.vim', {'commit': '69d5bc6070d5b3ff4e73719d970bae50a71d2c67' }
Plug 'Shougo/vimproc.vim', { 'tag': 'ver.10.0', 'do': 'make' }

Plug 'vim-jp/vimdoc-ja', {'commit': 'ee16ecb8f802287302ff0317e52e27c274c16194' }
Plug 'altercation/vim-colors-solarized', {'commit': '528a59f26d12278698bb946f8fb82a63711eec21' }

" Unite
Plug 'Shougo/unite.vim', { 'commit': '0ccb3f7988d61a9a86525374be97360bd20db6bc' }
Plug 'Shougo/neomru.vim', { 'commit': 'd9b92f73f7d9158e803d72f2baeb7da9ea30040e' }
Plug 'Shougo/unite-outline', { 'commit': '1c0f9c80b9d76421f697be161819106b91c151f3' }
Plug 'osyo-manga/unite-quickfix', { 'commit': 'f9b8d5f95ff2536abca1e81bd67dc740e5ee24a6' }
Plug 'Shougo/tabpagebuffer.vim', { 'commit': '4d95c3e6fa5ad887498f4cbe486c11e39d4a1fbc' }
Plug 'eidera/unite-projectlocal', { 'commit': '47d46c43093c5bbd13a3f92244ee259ed5977ff5' }

" Document
Plug 'habamax/vim-asciidoctor', { 'commit': 'd45364d662489e0ffcad0e2bc6f41c859ba58799' }
Plug 'plasticboy/vim-markdown', { 'commit': '1bc9d0cd8e1cc3e901b0a49c2b50a843f1c89397' }

" Language
Plug 'Quramy/tsuquyomi', { 'commit': 'e1afca562d46907bf63270157c88b7ec8f66e46b' }
Plug 'leafgarland/typescript-vim', { 'commit': '4740441db1e070ef8366c888c658000dd032e4cb' }
Plug 'derekwyatt/vim-scala', { 'commit': '7657218f14837395a4e6759f15289bad6febd1b4' }
Plug 'posva/vim-vue', { 'commit': '6ae8fa751fbe4c6605961d2309f8326873fa40a6' }
Plug 'jparise/vim-graphql', { 'tag': 'v1.6' }
Plug 'udalov/kotlin-vim', { 'commit': '53fe045906df8eeb07cb77b078fc93acda6c90b8' }
Plug 'dart-lang/dart-vim-plugin', { 'commit': 'dd74e59c50e29896483a87373743136f2cbd24e7' }
Plug 'nikvdp/ejs-syntax', { 'commit': '0e704c523dacfda547215b5936067869e79103c4' }
Plug 'toyamarinyon/vim-swift', { 'commit': '85025c4af417b5462831935dd7c2d57e4a5559bd' }
Plug 'slim-template/vim-slim', { 'commit': 'a0a57f75f20a03d5fa798484743e98f4af623926' }
Plug 'kchmck/vim-coffee-script', { 'commit': '28421258a8dde5a50deafbfc19cd9873cacfaa79' }

call plug#end()

" }}}
" ProjectLocalの設定 {{{
let g:projectlocal#projectfile       = get(g:, 'projectlocal#projectfile', '.projectfile')
let g:projectlocal#ignore_targets    = ['\~$', '^\.idea', '/app/cache/', '/submodules/'] " 無視するパスパターン(ファイル一覧を取得後に間引く)
let g:projectlocal#ignore_top_directories = ['/vendor', '/node_modules'] " プロジェクトルート直下にあるディレクトリのうち検索対象としないディレクトリを指定すると高速になる。(ファイル一覧の取得対象から外れる)

" 入力されたファイルタイプのリストを書き出す
function! MakeProjectFileCore(filetypes)
	call writefile(a:filetypes, g:projectlocal#projectfile)
endfunction
" }}}
" fzfの設定 {{{
" ref:
"   https://github.com/junegunn/fzf/blob/master/README-VIM.md
"   https://github.com/junegunn/fzf.vim
set rtp+=~/.fzf

"let g:fzf_layout = { 'up': '35%' }
" }}}
" unite.vimの設定 {{{
" 入力モードで開始する
" let g:unite_enable_start_insert=1

" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

" grep検索
nnoremap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif

"call unite#set_profile('action', 'context', {'start_insert' : 1})
" Set "-no-quit" automatically in grep unite source.
call unite#set_profile('source/grep', 'context', {'no_quit' : 1})
call unite#set_profile('source/quickfix', 'context', {'no_quit' : 1})

" qfixhowm 更新日時順で表示するための設定
call unite#custom_source('qfixhowm', 'sorters', ['sorter_qfixhowm_updatetime', 'sorter_reverse'])

" Unite関連基本キーマップ {{{
" バッファ一覧
" nnoremap <silent> ,ab :<C-u>Unite buffer<CR>
nnoremap <silent> ,ab :<C-u>Unite buffer_tab<CR>

"nnoremap <silent> ,ao :<C-u>Unite buffer<CR>

" ファイル一覧
nnoremap <silent> ,af :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
"nnoremap <silent> ,ar :<C-u>Unite -buffer-name=register register<CR>
"" 最近使用したファイル一覧
"nnoremap <silent> ,am :<C-u>Unite file_mru<CR>
" 最近使用したファイル一覧
"nnoremap <silent> ,am :<C-u>Unite bookmark file_mru<CR>
nnoremap <silent> ,am :<C-u>Unite file_mru<CR>
" bookmarkと最近使用したファイル一覧
nnoremap <silent> ,an :<C-u>Unite bookmark file_mru<CR>
" window一覧
nnoremap <silent> ,aw :<C-u>Unite window<CR>
" 常用セット
"nnoremap <silent> ,au :<C-u>Unite buffer file_mru<CR>
" 全部乗せ
nnoremap <silent> ,aa :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

" Resume
nnoremap <silent> ,ar :<C-u>UniteResume<CR>

"nnoremap <silent> ,ag :<C-u>Unite quickfix -auto-preview<CR>

nnoremap <silent> ,ac :<C-u>Unite command<CR>

" unite-outlineの設定
nnoremap <silent> ,ao :<C-U>Unite outline<CR>
" バッファ内の全ての行を表示
nnoremap <silent> ,al :<C-u>Unite lines<CR>
" snippetを表示
""nnoremap <silent> ,as :<C-u>Unite snipmate<CR>
"nnoremap <silent> ,as :<C-u>Unite snippet<CR>

" コマンドランチャーの呼び出し
nnoremap <silent> ,a<Space> :<C-u>Unite menu:alias<CR>

" qfixhowm
nnoremap <silent> ,ah :<C-u>Unite qfixhowm:nocache<CR>
" }}}
" ファイル種別毎のキーマップ定義 {{{
augroup MyUniteAuGroup
  autocmd!

  " ウィンドウを分割して開く
  autocmd FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
  autocmd FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
  " ウィンドウを縦に分割して開く
  autocmd FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
  autocmd FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
  " ESCキーを2回押すと終了する
  autocmd FileType unite nnoremap <silent> <buffer> <ESC><ESC> q
  autocmd FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>q
augroup END
" }}}

" UniteBookMarkAddで追加したディレクトリをUnite bookmarkで開くときのアクションのデフォルトをVimfilerにする。
call unite#custom_default_action('source/bookmark/directory' , 'vimfiler')

" migemoで絞り込みをする
if has('migemo')
  " 遅いのでmigemoで絞り込みを削除
  "call unite#filters#matcher_default#use('matcher_migemo')
endif
" 特定のソースに対して、matcherを変更する場合(例えば、migemoではなく通常の検索にする)
"call unite#custom_source('buffer', 'matchers', 'matcher_glob')

" unite-menuの設定(ランチャーのようなもの) {{{
if !exists("g:unite_source_menu_menus")
   let g:unite_source_menu_menus = {}
endif

" alias {{{
let s:commands = {
\   'description' : 'alias',
\ }

" コマンドを登録
if has("mac")
	let s:commands.candidates = {
	\	"awesome"     : "!open ~/OmniPresence/awesome.ooutline",
	\	"chrome"    : "!open -a 'Google Chrome'",
	\	"edge"      : "!open -a 'Microsoft Edge'",
	\	"vivalid"   : "!open -a Vivaldi",
	\	"safari"    : "!open -a safari",
	\	"iterm"     : "!open -a iterm",
	\	"slack"     : "!open -a slack",
	\	"sequel"    : "!open -a 'Sequel Pro'",
	\	"paw"       : "!open -a Paw",
	\	"memo"      : "!open -a notes",
	\	"numbers"   : "!open -a numbers",
	\	"itunes"    : "!open -a itunes",
	\	"firefox"   : "!open -a firefox",
	\	"omnifocus" : "!open -a omnifocus",
	\	"omnioutliner" : "!open -a 'omnioutliner professional'",
	\	"omniplan"  : "!open -a omniplan",
	\	"home"      : "VimFiler ~",
	\ }
endif

" 上記で登録したコマンドを評価する関数
" 最終的にこれで評価した結果が unite に登録される
function s:commands.map(key, value)
   return {
\       'word' : a:key,
\       'kind' : 'command',
\       'action__command' : a:value,
\ }
endfunction

let g:unite_source_menu_menus["alias"] = deepcopy(s:commands)
unlet s:commands
" }}}
" }}}
" 簡単なunite source定義 {{{
" lines {{{
" 参考 : http://d.hatena.ne.jp/thinca/20101105/1288896674
let s:unite_source = {
  \   'name': 'lines',
  \ }

function! s:unite_source.gather_candidates(args, context)
  let path = expand('#:p')
  "let lines = getbufline('#', 1, '$')
  let lines = getbufline('%', 1, '$')
  let format = '%' . strlen(len(lines)) . 'd: %s'
  return map(lines, '{
    \   "word": printf(format, v:key + 1, v:val),
    \   "source": "lines",
    \   "kind": "jump_list",
    \   "action__path": path,
    \   "action__line": v:key + 1,
    \ }')
endfunction

call unite#define_source(s:unite_source)
unlet s:unite_source
" }}}
" }}}
" }}}
" unite projectlocalの設定 {{{
function! ProjectlocalSetting()
	nnoremap <buffer><C-W><C-R>tp :<C-U>Unite projectlocal/root<CR>
	nnoremap <buffer><C-W><C-G> :<C-U>call SearchInProject()<CR>
endfunction

function! ToggleProjectLocal()
  let types = split(&filetype, '\.')
  let on_off_flag = 1 " 0はOFF、1はON
  let newTypes = {}
  for t in types
    if t == 'projectlocal'
      let on_off_flag = 0
      continue
    endif
    if t == 'project'
      continue
    endif
    let newTypes[t] = 1
  endfor
  if 1 == on_off_flag
    let newTypes['project'] = 1
    let newTypes['projectlocal'] = 1
  endif
  let result = join(keys(newTypes), '.')
  let &filetype = result
endfunction
nnoremap <C-W><C-P><C-L> :<C-U>call ToggleProjectLocal()<CR>

function! SearchInProject()
  let path = b:projectlocal_root_dir . '/*'
  let run = 'Unite grep:' . path . ' -buffer-name=search-buffer<CR>'
  exe run
endfunction

augroup MyProjectLocalAuGroup
  autocmd!

	autocmd FileType *projectlocal* call ProjectlocalSetting()
	autocmd FileType *projectlocal* set autoindent
augroup END

function! MakeProjectFileForProjectlocal()
	call MakeProjectFileCore(["projectlocal"])
endfunction
command! -nargs=0 MakeProjectFileForProjectlocal :call MakeProjectFileForProjectlocal()
" }}}
" VimFiler.vimの設定 {{{
nnoremap <silent> ,,f :<C-u>VimFilerBufferDir<CR>
" }}}
" lightline.vimの設定 {{{
"        \ 'colorscheme': 'solarized',
let g:lightline = {
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'MyModified',
        \   'readonly': 'MyReadonly',
        \   'fugitive': 'MyFugitive',
        \   'filename': 'MyFilename',
        \   'fileformat': 'MyFileformat',
        \   'filetype': 'MyFiletype',
        \   'fileencoding': 'MyFileencoding',
        \   'mode': 'MyMode'
        \ }
        \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
	"return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
	return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '[RO]' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
      return fugitive#head()
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

" lightlineをReloadしたときにcallしておくもの
" https://github.com/itchyny/lightline.vim/issues/241
function! LightlineReload()
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction
command! LightlineReload call LightlineReload()
" }}}
" SubstituteExplorerの設定 {{{
if !exists('g:vscode')
  nnoremap  <silent> <F8> :SubstituteExplorerWrapper<CR>
  nnoremap  <silent> ,,e :SubstituteExplorerWrapper<CR>
endif
" }}}
" Exploreの設定 {{{
let g:explHideFiles='\~$,\.swp$'
" }}}
" vim-fontzoomの設定 {{{
let g:fontzoom_no_default_key_mappings = 1	" デフォルトのmapを無効にする
" }}}
" vim-easy-align の設定 {{{
" ref: https://github.com/junegunn/vim-easy-align
"      https://baqamore.hatenablog.com/entry/2015/06/27/074459
"      https://news.mynavi.jp/techplus/article/techp5175/
" ヴィジュアルモードで選択し，easy-align 呼んで整形．(e.g. vip<Enter>)
"vmap <Enter> <Plug>(EasyAlign)
vmap ga <Plug>(EasyAlign)
"" easy-align を呼んだ上で，移動したりテキストオブジェクトを指定して整形．(e.g. gaip)
"nmap ga <Plug>(EasyAlign)
" }}}
" vim-rengbang の設定 {{{
" ref: https://github.com/deris/vim-rengbang
let g:rengbang_default_start    = 1 " default: 0
" }}}
" MultipleSearchの設定 {{{
let g:MultipleSearchMaxColors = 8 " default: 4  設定できる最大値は8っぽい
" }}}
" WinResizer {{{
" ref: https://github.com/simeji/winresizer
let g:winresizer_gui_enable = 1
let g:winresizer_vert_resize	= 1	" default: 10, The change width of window size when left or right key is pressed
let g:winresizer_horiz_resize	= 1	" default: 3, The change height of window size when down or up key is pressed

let g:winresizer_start_key	   = '<C-W><C-W><C-R>'
let g:winresizer_gui_start_key = '<C-W><C-W><C-G>'
" }}}
" YankRemoteUrl: github url generator {{{
" ref: https://github.com/Omochice/yank-remote-url.vim
let g:yank_remote_url#use_direct_hash = 0
" }}}
" vim-markdownの設定 {{{
function! MarkdownLevel()
  let h = matchstr(getline(v:lnum), '^#\+')
  if empty(h)
    return "="
  else
    return ">" . len(h)
  endif
endfunction

augroup MyMarkdownAuGroup
  autocmd!

  "autocmd BufEnter *.md setlocal foldexpr=MarkdownLevel()
  "autocmd BufEnter *.md setlocal foldmethod=expr
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} setlocal foldexpr=MarkdownLevel()
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} setlocal foldmethod=expr
augroup END
"let g:vim_markdown_initial_foldlevel=0
" }}}
" }}}
