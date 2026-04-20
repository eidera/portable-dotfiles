" File: get_calendar_info.vim
" Author: wei may
" Version: 1.1
" Last Change: 01-Apr-2019.
" First Release: Feb 28, 2012
"

" 二重インクルードガード {{{
if exists('loaded_get_calendar_info') || &cp
    finish
endif
let loaded_get_calendar_info=1
" }}}
" constant define {{{
let s:GCI_TYPE_SEIREKI	= 0x01
let s:GCI_TYPE_WAREKI	= 0x02

let s:GCI_TEXTTYPE_FULL			= 0x01
let s:GCI_TEXTTYPE_SIMPLE		= 0x02
let s:GCI_TEXTTYPE_SEIREKI		= 0x03
let s:GCI_TEXTTYPE_WAREKI		= 0x04

let s:GCI_EXTTEXTTYPE_FULLTIME		= 0x01
let s:GCI_EXTTEXTTYPE_SIMPLETIME	= 0x02
let	s:GCI_EXTTEXTTYPE_NOTIME		= 0x03

let s:GCI_YEAR_MEIJI	= 1867
let s:GCI_YEAR_TAISHO	= 1911
let s:GCI_YEAR_SHOWA	= 1925
let s:GCI_YEAR_HEISEI	= 1988
let s:GCI_YEAR_REIWA	= 2018
" }}}
" script local variables {{{
let	s:GCI_texttype = s:GCI_TEXTTYPE_FULL
let	s:GCI_exttexttype = s:GCI_EXTTEXTTYPE_FULLTIME
let	s:GCI_suffixString = ""
" }}}
" 関数定義 {{{
" Interface {{{
function! s:GCI_GetCalendarInfo(...)
	call s:GCI_SetTextType(s:GCI_TEXTTYPE_FULL)
	call s:GCI_SetExtTextType(s:GCI_EXTTEXTTYPE_FULLTIME)
	call s:GCI_GetCalendarInfoCore(a:000)
endfunction

function! s:GCI_GetCalendarInfoSimple(...)
	call s:GCI_SetTextType(s:GCI_TEXTTYPE_SIMPLE)
	call s:GCI_SetExtTextType(s:GCI_EXTTEXTTYPE_NOTIME)
	call s:GCI_GetCalendarInfoCore(a:000)
endfunction

function! s:GCI_GetCalendarInfoSimpleUnderBar(...)
	let tmpSuffix = s:GCI_GetSuffixString()
	call s:GCI_SetSuffixString("_")

	call s:GCI_SetTextType(s:GCI_TEXTTYPE_SIMPLE)
	call s:GCI_SetExtTextType(s:GCI_EXTTEXTTYPE_NOTIME)
	call s:GCI_GetCalendarInfoCore(a:000)

	call s:GCI_SetSuffixString(tmpSuffix)
endfunction

function! s:GCI_GetCalendarInfoSimpleTime(...)
	call s:GCI_SetTextType(s:GCI_TEXTTYPE_SIMPLE)
	call s:GCI_SetExtTextType(s:GCI_EXTTEXTTYPE_SIMPLETIME)
	call s:GCI_GetCalendarInfoCore(a:000)
endfunction

function! s:GCI_GetCalendarInfoSeireki(...)
	call s:GCI_SetTextType(s:GCI_TEXTTYPE_SEIREKI)
	call s:GCI_SetExtTextType(s:GCI_EXTTEXTTYPE_FULLTIME)
	call s:GCI_GetCalendarInfoCore(a:000)
endfunction

function! s:GCI_GetCalendarInfoWareki(...)
	call s:GCI_SetTextType(s:GCI_TEXTTYPE_WAREKI)
	call s:GCI_SetExtTextType(s:GCI_EXTTEXTTYPE_FULLTIME)
	call s:GCI_GetCalendarInfoCore(a:000)
endfunction

function! s:GCI_GetCalendarInfoSetSuffix(suffix)
	call s:GCI_SetSuffixString(a:suffix)
endfunction
" }}}
" Internal {{{
" accessor {{{
function! s:GCI_SetTextType(type)
	let	s:GCI_texttype = a:type
endfunction
function! s:GCI_GetTextType()
	return	s:GCI_texttype
endfunction

function! s:GCI_SetExtTextType(type)
	let	s:GCI_exttexttype = a:type
endfunction
function! s:GCI_GetExtTextType()
	return	s:GCI_exttexttype
endfunction

function! s:GCI_SetSuffixString(string)
	let	s:GCI_suffixString = a:string
endfunction
function! s:GCI_GetSuffixString()
	return	s:GCI_suffixString
endfunction
" }}}

function! s:GCI_GetCalendarInfoCore(list)
	let length = len(a:list)
	if 0 == length
		let result = s:GCI_GetTodayInfo()
	else
		let type = s:GCI_GetType(a:list)
		let ymd = s:GCI_Split(a:list)
		if s:GCI_TYPE_SEIREKI == type
			let result = s:GCI_YMDStringBySeireki(ymd[0], ymd[1], ymd[2])
		endif

		if s:GCI_TYPE_WAREKI == type
			let result = s:GCI_YMDStringByWareki(ymd[0], ymd[1], ymd[2])
		endif
	endif

	call s:GCI_CopyClipboard(result)
	echo result
endfunction

function! s:GCI_GetTodayInfo()
	if !exists("*strftime")
		echo "Not supported : strftime"
		return
	endif

	let year	= strftime('%Y')
	let month	= strftime('%m')
	let day		= strftime('%d')

	let hour	= strftime('%H')
	let minute	= strftime('%M')
	let second	= strftime('%S')

	let hms_full = hour . ":" . minute . ":" . second
	let hms_simple = hour . minute . second
	let hms = hms_full

	let extTextType = s:GCI_GetExtTextType()
	if		s:GCI_EXTTEXTTYPE_FULLTIME == extTextType
		let hms = " " . hms_full
	elseif	s:GCI_EXTTEXTTYPE_SIMPLETIME == extTextType
		let hms = hms_simple
	elseif	s:GCI_EXTTEXTTYPE_NOTIME == extTextType
		let hms = ""
	else
		let hms = " " . hms_full
	endif

	let ymd = s:GCI_YMDStringBySeireki(year, month, day)
	let suffix = s:GCI_GetSuffixString()
	return	ymd . hms . suffix
endfunction

function! s:GCI_YMDString(seireki_year, wareki_year, month, day)
	let ymd = s:GCI_GetYMDList(a:seireki_year, a:month, a:day)

	if  "" != ymd[0]
		let wareki_year = a:wareki_year
	else
		let wareki_year = ""
	endif

	let simple_ymd = ymd[0] . s:GCI_GetYMDElementString(ymd[1], "", 1) . s:GCI_GetYMDElementString(ymd[2], "", 1)
	let seireki_ymd = ymd[0] . s:GCI_GetYMDElementString(ymd[1], "/", 1) . s:GCI_GetYMDElementString(ymd[2], "/", 1)
	let wareki_ymd = s:GCI_MakeWarekiYomi(wareki_year) . "年" . s:GCI_GetYMDElementString(ymd[1], "月", 0) . s:GCI_GetYMDElementString(ymd[2], "日", 0)

	let dayOfTheWeek = s:GCI_GetDayOfTheWeek(a:seireki_year, a:month, a:day)
	if  0 < strlen(dayOfTheWeek)
		let dayOfTheWeek = "(" . dayOfTheWeek . ")"
	endif

	let textType = s:GCI_GetTextType()
	if		s:GCI_TEXTTYPE_FULL == textType
		return	seireki_ymd . "(" . wareki_ymd . dayOfTheWeek . ")"
	elseif	s:GCI_TEXTTYPE_SEIREKI == textType
		return	seireki_ymd
	elseif	s:GCI_TEXTTYPE_WAREKI == textType
		return	wareki_ymd . dayOfTheWeek
	elseif	s:GCI_TEXTTYPE_SIMPLE == textType
		return	simple_ymd
	endif

	return	"Unknown text type" . textType

	"let result = seireki_ymd . "(" . wareki_ymd . dayOfTheWeek . ")"
	"return	result
endfunction

function! s:GCI_GetYMDElementString(element, substring, pp)
	if  0 == str2nr(a:element)
		return	""
	endif
	if  a:pp
		" 前置なら
		return	a:substring . a:element
	else
		" 後置なら
		return	a:element . a:substring
	endif
endfunction

function! s:GCI_YMDStringBySeireki(year, month, day)
	let wareki = s:GCI_ConvertSeireki2Wareki(a:year, a:month, a:day)
	return	s:GCI_YMDString(a:year, wareki, a:month, a:day)
endfunction

function! s:GCI_YMDStringByWareki(year, month, day)
	let seireki = s:GCI_ConvertWareki2Seireki(a:year, a:month, a:day)
	return	s:GCI_YMDString(seireki, a:year, a:month, a:day)
endfunction

function! s:GCI_ConvertSeireki2Wareki(year, month, day)
" 参考 https://www.keisan.nta.go.jp/survey/publish/25692/faq/25702/faq_26687.php
"   明治(1868/9/8〜1912/7/29)	西暦-1867
"   大正(1912/7/30〜1926/12/24)	西暦-1911
"   昭和(1926/12/25〜1989/1/7)	西暦-1925
"   平成(1989/1/8〜2019/4/30)	西暦-1988
"   令和(2019/5/1〜)			西暦-2018

	if  0 > s:GCI_ValidBeforeAfter(a:year, a:month, a:day, 1868,9,8)
		echo "Not supported before 明治"
		return	""
	endif

	if  0 > s:GCI_ValidBeforeAfter(a:year, a:month, a:day, 1912,7,30)
		let wareki_year = a:year - s:GCI_YEAR_MEIJI
		let wareki_yomi = "明治" . wareki_year
	elseif  0 > s:GCI_ValidBeforeAfter(a:year, a:month, a:day, 1926,12,25)
		let wareki_year = a:year - s:GCI_YEAR_TAISHO
		let wareki_yomi = "大正" . wareki_year
	elseif  0 > s:GCI_ValidBeforeAfter(a:year, a:month, a:day, 1989,1,8)
		let wareki_year = a:year - s:GCI_YEAR_SHOWA
		let wareki_yomi = "昭和" . wareki_year
	elseif  0 > s:GCI_ValidBeforeAfter(a:year, a:month, a:day, 2019,5,1)
		let wareki_year = a:year - s:GCI_YEAR_HEISEI
		let wareki_yomi = "平成" . wareki_year
	else
		let wareki_year = a:year - s:GCI_YEAR_REIWA
		let wareki_yomi = "令和" . wareki_year
	endif

	return	s:GCI_MakeWarekiYomi(wareki_yomi)
endfunction

function! s:GCI_MakeWarekiYomi(year)
	let yeartmp = substitute(a:year, '年', "", "")
	let yeartmp = substitute(yeartmp, '元$', "1", "")
	let wareki = substitute(yeartmp, '[0-9]\+', "", "")
	let wareki_year = substitute(yeartmp, '^[^0-9]\+', "", "")

	if  s:GCI_IsMeiji(wareki)
		let wareki_yomi = "明治"
	elseif  s:GCI_IsTaisho(wareki)
		let wareki_yomi = "大正"
	elseif  s:GCI_IsShowa(wareki)
		let wareki_yomi = "昭和"
	elseif  s:GCI_IsHeisei(wareki)
		let wareki_yomi = "平成"
	elseif  s:GCI_IsReiwa(wareki)
		let wareki_yomi = "令和"
	else
		let wareki_yomi = "Unknown"
	endif

	if  1 == wareki_year
		let year = "元"
	else
		let year = wareki_year
	endif

	return	wareki_yomi . year
endfunction

function! s:GCI_ValidBeforeAfter(year1, month1, day1, year2, month2, day2)
	" 1>2だと正、1<2だと負、1==2だと0
	if	a:year1 > a:year2
		return	1
	elseif	a:year1 < a:year2
		return	-1
	endif

	if	a:month1 > a:month2
		return	1
	elseif	a:month1 < a:month2
		return	-1
	endif

	if	a:day1 > a:day2
		return	1
	elseif	a:day1 < a:day2
		return	-1
	endif

	return	0
endfunction

function! s:GCI_GetType(list)
	if  -1 != match(a:list[0], "^[0-9]\\+")
		return	s:GCI_TYPE_SEIREKI
	endif

	return	s:GCI_TYPE_WAREKI
endfunction

function! s:GCI_ConvertWareki2Seireki(year, month, day)
" 参考 https://www.keisan.nta.go.jp/survey/publish/25692/faq/25702/faq_26687.php
"   明治(1868/9/8〜1912[45]/7/29)	和暦+1867
"   大正(1912/7/30〜1926[15]/12/24)	和暦+1911
"   昭和(1926/12/25〜1989[64]/1/7)	和暦+1925
"   平成(1989/1/8〜2019/4/30)		和暦+1988
"   令和(2019/5/1〜)				和暦+2018

	let yeartmp = substitute(a:year, '年', "", "")
	let yeartmp = substitute(yeartmp, '元$', "1", "")
	let wareki = substitute(yeartmp, '[0-9]\+', "", "")
	let wareki_year = substitute(yeartmp, '^[^0-9]\+', "", "")

	if  s:GCI_IsMeiji(wareki)
		let seireki_year = wareki_year + s:GCI_YEAR_MEIJI
	elseif  s:GCI_IsTaisho(wareki)
		let seireki_year = wareki_year + s:GCI_YEAR_TAISHO
	elseif  s:GCI_IsShowa(wareki)
		let seireki_year = wareki_year + s:GCI_YEAR_SHOWA
	elseif  s:GCI_IsHeisei(wareki)
		let seireki_year = wareki_year + s:GCI_YEAR_HEISEI
	elseif  s:GCI_IsReiwa(wareki)
		let seireki_year = wareki_year + s:GCI_YEAR_REIWA
	else
		return	""
	endif

	return	seireki_year
endfunction

function! s:GCI_IsMeiji(string)
	if  -1 != match(a:string, "^明") || "M" == a:string || "m" == a:string
		return	1
	endif
	return	0
endfunction

function! s:GCI_IsTaisho(string)
	if  -1 != match(a:string, "^大") || "T" == a:string || "t" == a:string
		return	1
	endif
	return	0
endfunction

function! s:GCI_IsShowa(string)
	if  -1 != match(a:string, "^昭") || "S" == a:string || "s" == a:string
		return	1
	endif
	return	0
endfunction

function! s:GCI_IsHeisei(string)
	if  -1 != match(a:string, "^平") || "H" == a:string || "h" == a:string
		return	1
	endif
	return	0
endfunction

function! s:GCI_IsReiwa(string)
	if  -1 != match(a:string, "^令") || "R" == a:string || "r" == a:string
		return	1
	endif
	return	0
endfunction

function! s:GCI_Split(list)
	let length = len(a:list)

	if  (1 == length) && (-1 != match(a:list[0], "^[0-9]\\+$"))
		if  8 == strlen(a:list[0])
			" 8文字連続数字用の特殊対応(最初の要素のみで判断)
			let year	= substitute(a:list[0], '\(....\)....', '\1', "")
			let month	= substitute(a:list[0], '....\(..\)..', '\1', "")
			let day		= substitute(a:list[0], '......\(..\)', '\1', "")
			return	s:GCI_Split([year, month, day])
		elseif  6 == strlen(a:list[0])
			" 6文字連続数字用の特殊対応(最初の要素のみで判断)
			let year	= substitute(a:list[0], '\(....\)..', '\1', "")
			let month	= substitute(a:list[0], '....\(..\)', '\1', "")
			let day		= ""
			return	s:GCI_Split([year, month, day])
		elseif  4 == strlen(a:list[0])
			" 4文字連続数字用の特殊対応(西暦として常識的にありえない場合:1200年以前)
			if 1231 >= a:list[0]
				let year	= strftime('%Y')
				let month	= substitute(a:list[0], '\(..\)..', '\1', "")
				let day		= substitute(a:list[0], '..\(..\)', '\1', "")
				return	s:GCI_Split([year, month, day])
			endif
		endif
	endif

	if	3 <= length
		return	[a:list[0], a:list[1], a:list[2]]
	endif

	if	2 == length
		return	s:GCI_Split(split(a:list[0], "[/_.]") + split(a:list[1], "[/_.]") + [""])
	endif

	if	1 == length
		return s:GCI_Split(split(a:list[0], "[/_.]")+ ["", ""])
	endif
endfunction

function! s:GCI_GetYMDList(year, month, day)
	let year  = s:GCI_YearValid(a:year)
	let month = s:GCI_MonthValid(a:month)
	let day   = s:GCI_DayValid(a:year, a:month, a:day)

	if  0 == len(year)
		return	["", "", ""]
	elseif  0 == len(month)
		return	[year, "", ""]
	elseif  0 == len(day)
		return	[year, month, ""]
	else
		return	[year, month, day]
	endif
endfunction

function! s:GCI_GetDay(year, month)
	if  s:GCI_Is31Day(a:month)
		return	31
	elseif  2 == a:month
		if  s:GCI_IsLeapYear(a:year)
			return	29
		else
			return	28
		endif
	else
		return	30
	endif
endfunction

function! s:GCI_Is31Day(month)
	let no31_month_list = [2, 4, 6, 9, 11]
	let max = len(no31_month_list)
	let i = 0
	while max > i
		if  a:month == no31_month_list[i]
			return	0
		endif
		let i = i + 1
	endwhile
	return	1
endfunction

function! s:GCI_IsLeapYear(year)
	if  0 == a:year % 400
		return	1
	endif
	if  0 == a:year % 100
		return	0
	endif
	if  0 == a:year % 4
		return	1
	endif
endfunction

function! s:GCI_YearValid(year)
	return	s:GCI_YMDElementValid(a:year, 1, 9999)
endfunction

function! s:GCI_MonthValid(month)
	return	s:GCI_YMDElementValid(a:month, 1, 12)
endfunction

function! s:GCI_DayValid(year, month, day)
	return	s:GCI_YMDElementValid(a:day, 1, s:GCI_GetDay(a:year, a:month))
endfunction

function! s:GCI_YMDElementValid(value, min, max)
	if  a:min > a:value
		return	""
	endif
	if  a:max < a:value
		return	""
	endif
	return	a:value
endfunction

function! s:GCI_GetDayOfTheWeek(year, month, day)
	if  !s:GCI_YearValid(a:year)
		return	""
	endif
	if	!s:GCI_MonthValid(a:month)
		return	""
	endif
	if	!s:GCI_DayValid(a:year, a:month, a:day)
		return	""
	endif

	" まず求めたい日の年の千の位と百の位の連続の数字（例えば2310年ならば23）をJ、
	" 年の下2桁（例えば2310年ならば10）をK、
	" 月をm、
	" 日をq、
	" 曜日をhとする。
	" 但し、求めたい日の月が1月、2月の場合はそれぞれ前年の13月、14月とする

	let tmp_year = a:year
	let m = a:month
	if (1 == m) || (2 == m)
		let m += 12
		let tmp_year -= 1
	endif
	let J = floor(tmp_year/100)
	let K = tmp_year % 100
	let q = a:day

	" ユリウス歴からグレゴリオ歴への変更年月日を「1752/09/03」とする(calに準拠)
	" 1752/09/03 〜 1752/09/13の空白期間のチェックは行わない。
	if 0 > s:GCI_ValidBeforeAfter(a:year, a:month, a:day, 1752, 9, 3)
		" ユリウス歴
		let h = float2nr(q + floor((m+1)*26/10) + K + floor(K/4) + 5 + 6*J) % 7
	else
		" グレゴリオ歴
		let h = float2nr(q + floor((m+1)*26/10) + K + floor(K/4) + floor(J/4) + 5*J) % 7
	endif

	let dayOfTheWeek = [ "土", "日", "月", "火", "水", "木", "金" ]

	return	dayOfTheWeek[h]
endfunction

function! s:GCI_CopyClipboard(strings)
    let @*=a:strings
    let @"=a:strings
endfunction
" }}}
" }}}
" テストデータ{{{
"GetCalendarInfo
"
"GetCalendarInfo 0
"GetCalendarInfo 10000
"GetCalendarInfo 00010101
"GetCalendarInfo 1 1 1
"
"GetCalendarInfo 2000 0 0
"GetCalendarInfo 2000 01 0
"GetCalendarInfo 2000 12 0
"GetCalendarInfo 2000 13 0
"
"GetCalendarInfo 2000 1 1
"GetCalendarInfo 2000 1 31
"GetCalendarInfo 2000 1 32
"GetCalendarInfo 2000 2 0
"GetCalendarInfo 2000 2 01
"GetCalendarInfo 2000 3 0
"GetCalendarInfo 2000 3 1
"GetCalendarInfo 2000 3 31
"GetCalendarInfo 2000 3 32
"GetCalendarInfo 2000 4 0
"GetCalendarInfo 2000 4 1
"GetCalendarInfo 2000 4 30
"GetCalendarInfo 2000 4 31
"GetCalendarInfo 2000 5 0
"GetCalendarInfo 2000 5 1
"GetCalendarInfo 2000 5 31
"GetCalendarInfo 2000 5 32
"GetCalendarInfo 2000 6 0
"GetCalendarInfo 2000 6 1
"GetCalendarInfo 2000 6 30
"GetCalendarInfo 2000 6 31
"GetCalendarInfo 2000 7 0
"GetCalendarInfo 2000 7 1
"GetCalendarInfo 2000 7 31
"GetCalendarInfo 2000 7 32
"GetCalendarInfo 2000 8 0
"GetCalendarInfo 2000 8 1
"GetCalendarInfo 2000 8 31
"GetCalendarInfo 2000 8 32
"GetCalendarInfo 2000 9 0
"GetCalendarInfo 2000 9 1
"GetCalendarInfo 2000 9 30
"GetCalendarInfo 2000 9 31
"GetCalendarInfo 2000 10 0
"GetCalendarInfo 2000 10 1
"GetCalendarInfo 2000 10 31
"GetCalendarInfo 2000 10 32
"GetCalendarInfo 2000 11 0
"GetCalendarInfo 2000 11 1
"GetCalendarInfo 2000 11 30
"GetCalendarInfo 2000 11 31
"GetCalendarInfo 2000 12 0
"GetCalendarInfo 2000 12 1
"GetCalendarInfo 2000 12 31
"GetCalendarInfo 2000 12 32
"
"" 閏年判定チェック
"GetCalendarInfo 2000 2 28
"GetCalendarInfo 2000 2 29
"GetCalendarInfo 2000 2 30
"GetCalendarInfo 2004 2 28
"GetCalendarInfo 2004 2 29
"GetCalendarInfo 2004 2 30
"GetCalendarInfo 2100 2 28
"GetCalendarInfo 2100 2 29
"GetCalendarInfo 2100 2 30
"
"" 西暦分割チェック
"GetCalendarInfo 2000_2_29
"GetCalendarInfo 2000.2.29
"GetCalendarInfo 2000/2/29
"GetCalendarInfo 20000229
"GetCalendarInfo 200002
"GetCalendarInfo 20001301
"GetCalendarInfo 200013
"GetCalendarInfo 1232
"GetCalendarInfo 1231
"GetCalendarInfo 0101
"GetCalendarInfo 0100
"GetCalendarInfo 0000
"
""ユリウス歴、グレゴリオ歴切替チェック
"" ユリウス最終日(水)
"GetCalendarInfo 17520902
"" 空白期間
"GetCalendarInfo 17520903
"GetCalendarInfo 17520913
"" グレゴリオ暦初日(木)
"GetCalendarInfo 17520914
"
""以下、元号切替チェック
"GetCalendarInfo 1868 9 7
"
"GetCalendarInfo 1868 9 8
"GetCalendarInfo 明治元年 9 8
"GetCalendarInfo 明治1年 9 8
"GetCalendarInfo M元年 9 8
"GetCalendarInfo M1年 9 8
"GetCalendarInfo m元年 9 8
"GetCalendarInfo m1年 9 8
"GetCalendarInfo 明治元 9 8
"GetCalendarInfo 明治1 9 8
"GetCalendarInfo M元 9 8
"GetCalendarInfo M1 9 8
"GetCalendarInfo m元 9 8
"GetCalendarInfo m1 9 8
"
"GetCalendarInfo 1912 7 29
"GetCalendarInfo 明治45年 7 29
"GetCalendarInfo M45年 7 29
"GetCalendarInfo m45年 7 29
"GetCalendarInfo 明治45 7 29
"GetCalendarInfo M45 7 29
"GetCalendarInfo m45 7 29
"
"GetCalendarInfo 1912 7 30
"GetCalendarInfo 大正元年 7 30
"GetCalendarInfo 大正1年 7 30
"GetCalendarInfo T元年 7 30
"GetCalendarInfo T1年 7 30
"GetCalendarInfo t元年 7 30
"GetCalendarInfo t1年 7 30
"GetCalendarInfo 大正元 7 30
"GetCalendarInfo 大正1 7 30
"GetCalendarInfo T元 7 30
"GetCalendarInfo T1 7 30
"GetCalendarInfo t元 7 30
"GetCalendarInfo t1 7 30
"
"GetCalendarInfo 1926 12 24
"GetCalendarInfo 大正15年 12 24
"GetCalendarInfo T15年 12 24
"GetCalendarInfo t15年 12 24
"GetCalendarInfo 大正15 12 24
"GetCalendarInfo T15 12 24
"GetCalendarInfo t15 12 24
"
"GetCalendarInfo 1926 12 25
"GetCalendarInfo 昭和元年 12 25
"GetCalendarInfo 昭和1年 12 25
"GetCalendarInfo S元年 12 25
"GetCalendarInfo S1年 12 25
"GetCalendarInfo s元年 12 25
"GetCalendarInfo s1年 12 25
"GetCalendarInfo 昭和元 12 25
"GetCalendarInfo 昭和1 12 25
"GetCalendarInfo S元 12 25
"GetCalendarInfo S1 12 25
"GetCalendarInfo s元 12 25
"GetCalendarInfo s1 12 25
"
"GetCalendarInfo 1989 1 7
"GetCalendarInfo 昭和64年 1 7
"GetCalendarInfo S64年 1 7
"GetCalendarInfo s64年 1 7
"GetCalendarInfo 昭和64 1 7
"GetCalendarInfo S64 1 7
"GetCalendarInfo s64 1 7
"
"GetCalendarInfo 1989 1 8
"GetCalendarInfo 平成元年 1 8
"GetCalendarInfo 平成1年 1 8
"GetCalendarInfo H元年 1 8
"GetCalendarInfo H1年 1 8
"GetCalendarInfo h元年 1 8
"GetCalendarInfo h1年 1 8
"GetCalendarInfo 平成元 1 8
"GetCalendarInfo 平成1 1 8
"GetCalendarInfo H元 1 8
"GetCalendarInfo H1 1 8
"GetCalendarInfo h元 1 8
"GetCalendarInfo h1 1 8
"
"GetCalendarInfo 2012 2 29
"GetCalendarInfo 平成24年 2 29
"GetCalendarInfo H24年 2 29
"GetCalendarInfo h24年 2 29
"GetCalendarInfo 平成24 2 29
"GetCalendarInfo H24 2 29
"GetCalendarInfo h24 2 29
" }}}
" コマンド定義 {{{
command! -nargs=* GetCalendarInfo :call s:GCI_GetCalendarInfo(<f-args>)
command! -nargs=* GetCalendarInfoSimple :call s:GCI_GetCalendarInfoSimple(<f-args>)
command! -nargs=* GetCalendarInfoSimpleUB :call s:GCI_GetCalendarInfoSimpleUnderBar(<f-args>)
command! -nargs=* GetCalendarInfoSimpleTime :call s:GCI_GetCalendarInfoSimpleTime(<f-args>)
command! -nargs=* GetCalendarInfoSeireki :call s:GCI_GetCalendarInfoSeireki(<f-args>)
command! -nargs=* GetCalendarInfoWareki :call s:GCI_GetCalendarInfoWareki(<f-args>)
command! -nargs=? GetCalendarInfoSetSuffix :call s:GCI_GetCalendarInfoSetSuffix(<q-args>)

" }}}
" vim: set fdm=marker :
