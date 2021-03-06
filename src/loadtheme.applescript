#######################################
# 読み込むファイル名を""の間に記入してください

property filename : "simple.txt"

#######################################

-- 文章中から特定の文字と指定した文字を置換
on replace(txt, findstr, substr)
	set temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to findstr
	set retList to every text item of txt
	set AppleScript's text item delimiters to substr
	set retList to retList as text
	set AppleScript's text item delimiters to temp
	return retList
end replace

-- 文章を区切ってそのリストを返す
on split(txt, delimiter)
	set temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set retList to every text item of txt
	set AppleScript's text item delimiters to temp
	return retList
end split

--指定した文字を挟んでリストを結合
on bind(listhtml, bindstr)
	set temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to bindstr
	set retList to listhtml as text
	set AppleScript's text item delimiters to temp
	return retList
end bind

-- http://d.hatena.ne.jp/zariganitosh/20111005/coding_value_world
on set_key(a_record, a_key, a_value)
	return (run script "{|" & a_key & "|:" & a_value & "}") & a_record
end set_key

on tocr(txt)
	set lf to ASCII character (10)
	set cr to ASCII character (13)
	set crlf to cr & lf
	set txt to replace(txt, cr & lf, cr)
	set txt to replace(txt, lf, cr)
	return txt
end tocr

-- http://www.script-factory.net/XModules/index.html
on value_of(an_object, a_label)
	try
		set t to (make_with(a_label))'s value_of(an_object)
		return true
	on error
		return false
	end try
end value_of
on make_with(a_label)
	return run script "
on value_of(an_object)
return " & a_label & " of an_object
end value
return me"
end make_with

on main()
	set loadfile to ""
	set cssdata to ""
	set loadfile to (path to scripts folder from user domain as string) & "madever:themes:" & filename as alias
	set openfile to open for access loadfile
	
	try
		set cssdata to read openfile as «class utf8»
	on error number n
		close access openfile
		if (n = -43) then
			return display dialog "ファイルが見つかりません。loadcss.scptの名前を確認してください。" buttons {"OK"} default button 1 with icon 2
		else if (n = -39) then
			return display dialog "ファイルの中身が空です。cssを書いてください。" buttons {"OK"} default button 1 with icon 2
		end if
	end try
	close access openfile
	
	-- 改行コードをCRに統一
	set cssdata to tocr(cssdata)
	script wrap
		property css : cssdata
	end script
	
	-- コメント削除
	set wrap's css to split(wrap's css, return)
	set tmp to {}
	repeat with elem in wrap's css
		if (elem's length > 1) then
			set comment to (elem's item 1 as text) & (elem's item 2 as text)
			if (not comment as text = "--") then
				set tmp's end to elem as text
			end if
		else
			set tmp's end to elem as text
		end if
	end repeat
	set wrap's css to bind(tmp, return)
	
	-- 改行除去
	set wrap's css to split(wrap's css, return & return)
	
	-- スターセレクタのプロパティ取得
	set starselecter to ""
	repeat with elem in wrap's css
		set alist to split(elem as text, return)
		set star to alist's item 1 as text
		if (star = "*") then set starselecter to bind(alist's rest, "")
	end repeat
	
	-- レコード型でセレクタとプロパティをまとめる
	set tmp to {}
	repeat with i from 1 to wrap's css's length
		set elem to wrap's css's item i
		set elem to split(elem as text, return)
		set selecter to elem's item 1 as text
		set cssprop to bind(elem's rest, "") as text
		
		-- starselecterのプロパティを適用
		if (not (selecter = "h1first" or selecter = "childul" or selecter = "childol" or selecter = "bqchildp" or selecter = "prechildcode")) then
			if (not cssprop = "") then
				set cssprop to starselecter & cssprop
			end if
		end if
		
		set tmp to set_key(tmp, selecter, "\"" & cssprop & "\"")
	end repeat
	
	-- 特別なセレクタ
	if (value_of(tmp, "h1first")) then set tmp's h1first to tmp's h1 & tmp's h1first
	if (value_of(tmp, "childul")) then set tmp's childul to tmp's ul & tmp's childul
	if (value_of(tmp, "childol")) then set tmp's childol to tmp's ol & tmp's childol
	if (value_of(tmp, "bqchildp")) then set tmp's bqchildp to tmp's p & tmp's bqchildp
	if (value_of(tmp, "prechildcode")) then set tmp's prechildcode to tmp's code & tmp's prechildcode
	
	return tmp
end main