" Andrew's awesome .vimrc
" Steal, reproduce and enjoy

set nocompatible
filetype indent plugin on
set history=1000
"filetype plugin on
set isk+=_,$,@,%,#,-

"cool autocomplete dealie
set wildmenu

set encoding=utf-8

syntax on
set showmatch
set mat=5
"set number
"set acd
set ruler
set rulerformat=%22(%3.b\ 0x%B\ \ %l,%c%V\ %p%%%)
set backspace=2
set modeline
set modelines=5

"autoindent, smartindent. use tabs, indent is 4 spaces
set ai
set si
set tabstop=2
set softtabstop=2
set shiftwidth=2
set noexpandtab
set shiftround
set smarttab

"searches are case sensitive only if capital letters are used
set ignorecase
set smartcase

set hidden

"make f4 toggle search highl:ighting
map <F4> :set hls! hls?<CR>
set hlsearch

"Draw tabs/newlines/trailing spaces
set listchars=tab:>-,eol:$,trail:.,extends:#
set list

" function to only add tabs at the beginning
" of the line, use spaces elsewhere so that if
" tabstop changes, the non-indent formatting is
" maintained
function AddTab()
	let line = getline('.')
	let pos = col('.')
	if col('.') == 1 || strpart(line, 0, pos-1) =~ '^\t*$' || line =~ '^$'
		return "\t"
	else
		return repeat(" ", &tabstop)
	endif
endfunction

imap <silent> <Tab> <C-r>=AddTab()<CR>

" Make commented lines more readable for color terminals
autocmd BufReadPre,FileReadPre * hi! Comment ctermfg=blue cterm=bold

"Add Additional file types
autocmd BufEnter * :syntax sync fromstart
au BufNewFile,BufRead *.rbx :set ft=ruby
au BufNewFile,BufRead *.xhtml :set ft=html

" Asterisk config files
au BufNewFile,BufRead *asterisk*/*voicemail.conf* :set ft=asterisk_voicemail
au BufNewFile,BufRead *asterisk/*.conf* :set ft=asterisk 

" riak
au BufNewFile,BufRead *riak*/**/*.erl :set expandtab tabstop=4 shiftwidth=4 tw=78
au BufNewFile,BufRead *riak*/**/*.erl :call ToggleHighlightLongLines()

" Unbind the fscking F1 key so it doesn't pop the help screen all the time
nmap <F1> :echo<CR>
imap <F1> <C-o>:echo<CR>

" Global tracker var
let g:HighlightLongLines = 0 "set to 0 so we can run it to enable
" Function to toggle highlighting of lines longer than 80 character
" It also toggles textwidth to 80 so newlines are forced when typing
fu! ToggleHighlightLongLines()
	if(g:HighlightLongLines == 1)
		" Disable highlighting and textwidth
		highlight clear rightMargin
		"set textwidth=0
		let g:HighlightLongLines = 0
	else
		" Enable highlighting and textwidth
		"set textwidth=80
		highlight rightMargin ctermbg=LightRed guibg=LightRed
		let foo = 'match rightMargin /\%>'.&textwidth.'v/'
		exec foo
		let g:HighlightLongLines = 1
	endif
endfunction

map <F2> :call ToggleHighlightLongLines()<CR>

" Change to working directory
autocmd BufEnter * cd %:p:h

" Lisp magic
autocmd BufRead,BufNewFile *.lisp,*.scm set lisp ai sm expandtab formatoptions=corq cinoptions=:0(0 textwidth=72 comments=n:; sw=2
autocmd BufRead,BufNewFile *.lsp,*.lisp so ~/vilisp/VIlisp.vim

au BufRead,BufNewFile *.json setfiletype json 

" try to detect and set the comment type
autocmd BufReadPost,BufNewFile,FileReadPost * call SetCommentType()

vmap q <Esc>:call VisualComment(line("'<"), line("'>"))<CR>
nmap q :call Comment(line('.'))<CR>

function SetCommentType()
	"no switch statement, feh
	if &ft == 'ruby' || &ft == 'pf' || &ft == 'sh' || &ft == 'xf86conf' || &ft == 'zsh'
		let b:comment_begin = '#'
	elseif &ft == 'vim'
		let b:comment_begin = '"'
	elseif &ft == 'c' || &ft == 'javascript' || &ft == 'php'
		let b:comment_begin = '/*'
		let b:comment_end = '*/'
	elseif &ft == 'xml' || &ft == 'html'
		let b:comment_begin = '<!--'
		let b:comment_end = '-->'
	elseif &ft == 'erlang'
		let b:comment_begin = '%'
	elseif &ft == 'xmodmap'
		let b:comment_begin = '!'
	" TODO - other languages
	else
		"Unhandled syntax
	end
endfunction

" (Un)Comment all selected lines
function VisualComment(b, e)
	if !(exists('b:comment_begin'))
		return
	end
	"iterate over selected lines
	for i in range(a:b, a:e)
		call Comment(i)<CR>
	endfor
endfunction

" (Un)Comment out a line using the comment type defined for this syntax type
function Comment(i)
	" comment details not defined...
	if !exists('b:comment_begin')
		return
	end

	" test for an empty line
	if match(getline(a:i), "^$") == 0
		return
	end

	if exists('b:comment_end')
		let comment_begin_esc = escape(b:comment_begin, '*')
		let comment_end_esc = escape(b:comment_end, '*')
		let regex = ('^\s*'.comment_begin_esc.'.\+'.comment_end_esc.'\s*$')
	else 
		let comment_begin_esc = escape(b:comment_begin, '*')
		let regex = '^\s*'.comment_begin_esc.'.\+$'
	end

	let idx = match(getline(a:i), regex)

	if idx >= 0
		let newline = substitute(getline(a:i),  comment_begin_esc, '', '')
		if exists('b:comment_end')
			let ridx = strridx(newline, comment_end_esc)
			let part1 = strpart(newline, 0, ridx)
			let part2 = strpart(newline, ridx)
			let newline = part1.substitute(part2, comment_end_esc, '', '')
		end
		call setline(a:i, newline)
	else
		let newline = substitute(getline(a:i), '^\s*', '\0'.comment_begin_esc, '')
		if exists('b:comment_end')
			let newline = substitute(newline, '$', comment_end_esc, '')
		end
		call setline(a:i, newline)
	end
endfunction

if v:version >= 700
	set spelllang=en_us
	" Set up the tab bindings for alt-n
	map 1 :tabn 1<CR>
	map 2 :tabn 2<CR>
	map 3 :tabn 3<CR>
	map 4 :tabn 4<CR>
	map 5 :tabn 5<CR>
	map 6 :tabn 6<CR>
	map 7 :tabn 7<CR>
	map 8 :tabn 8<CR>
	map 9 :tabn 9<CR>
	map 0 :tabn 10<CR>
	map OC :tabn
	
	" shorten up the tab titles by calculating relative paths when possible
	function GetRelativePath(path)
		if bufname('') == a:path
			return a:path
		end
		let here = fnamemodify(bufname(''), ':p')
		let a = split(fnamemodify(a:path, ':p'), '/')
		let b = split(here, '/')
		let i = 0
		while join(a[0:i], '/') == join(b[0:i], '/')
			let i += 1
		endwhile
		let i -= 1
		if i < 0
			return a:path
		elseif len(a[i : -1]) > len(b[i : -1])
			return './'.join(a[i+1 : -1], '/')
		elseif len(a[i : -1]) < len(b[i : -1])
			let diff = len(b[i : -1]) - len(a[i : -1])
			let r = []
			while diff > 0
				let r += ['..']
				let diff -= 1
			endwhile
			let r += a[i+1 : -1]
			return join(r, '/')
		else " lengths are equal, same working directory
			return a[-1]
		end
	endfunction
	
	" ensure that the active tab is positioned as close to the middle of the
	" tabline as reasonable
	function CenterActiveTab(tabs, attributes)
		let middle = tabpagenr() - 1
		let res = [a:tabs[middle]]
		let att = [a:attributes[middle].a:tabs[middle]]
		let i = 2
		while len(res) < len(a:tabs) && strlen(join(res, '')) < &columns
			if (i % 2) == 0 && (middle + (i / 2)) < len(a:tabs)
				let res += [a:tabs[middle + (i / 2)]]
				let att += [a:attributes[middle + (i/2)].a:tabs[middle + (i/2)]]
			elseif (i % 2 == 1) && (middle - (i / 2)) >= 0
				let res = [a:tabs[middle - (i / 2)]] + res
				let att = [a:attributes[middle - (i/2)].a:tabs[middle - (i/2)]] + att
			endif
			let i += 1
		endwhile
		if strlen(join(res, '')) > &columns
			if middle > len(a:tabs) / 2
				return att[1:-1]
			else
				return att[0:-2]
			endif
		else
			return att
	endfunction

	" define a function for drawing the tab line - stolen from the
	" documentation and hacked relentlessly
	function DrawTabLine()
		let s = ''
		"let maxwidth = &columns / tabpagenr('$')
		let tabs = []
		let attributes = []
		for i in range(tabpagenr('$'))
			let buflist = tabpagebuflist(i+1)
			let winnr = tabpagewinnr(i+1)
			if getbufvar(buflist[winnr - 1], '&modified')
				if tabpagenr() == i + 1
					let attributes += ['%#TabLineModSel#']
				else
					let attributes += ['%#TabLineMod#']
				endif
				let tabs += ['+['.(i + 1).':'.substitute(GetRelativePath(bufname(buflist[winnr - 1])), '^'.$HOME, '~', '').']']
			else
				if tabpagenr() == i + 1
					let attributes += ['%#TabLineSel#']
				else
					let attributes += ['%#TabLine#']
				endif
				let tabs += ['['.(i + 1).':'.substitute(GetRelativePath(bufname(buflist[winnr - 1])), '^'.$HOME, '~', '').']']
			end
		endfor

		return join(CenterActiveTab(tabs, attributes), '').'%#TabLineFill#'
	endfunction

	set tabline=%!DrawTabLine()

	" define the highlight rules
	hi! TabLineMod ctermfg=darkmagenta ctermbg=white
	hi! TabLineSel ctermfg=white ctermbg=blue
	hi! TabLineModSel ctermfg=red ctermbg=blue
	hi! TabLine ctermfg=black ctermbg=white
else
	" TODO - source TabBar for fallback usefulness on vim < 7
	" TabBar options
	let g:Tb_TabWrap = 1
	let	g:Tb_UseSingleClick = 1
end

" ###### Mcrypt file handling #####

" ###### LOADING ######
autocmd BufReadPre,FileReadPre *.nc set bin "binary mode
autocmd BufReadPre,FileReadPre *.nc set noshelltemp "force the use of pipes
autocmd BufReadPre,FileReadPre *.nc set noswapfile "disable swapfiles
"decrypt the file
autocmd BufReadPost,FileReadPost *.nc '[,']!mcrypt -d
autocmd BufReadPost,FileReadPost *.nc set nobin "turn off binary mode

" ###### SAVING ######
"grab the contents of the file to the register 'j'
autocmd BufWritePre,FileWritePre *.nc normal gg"jyG
autocmd BufWritePre,FileWritePre *.nc set bin "binary mode
"encrypt the data
autocmd BufWritePre,FileWritePre *.nc '[,']!mcrypt
"restore the contents of the register 'j'
autocmd BufWritePost,FileWritePost *.nc normal ggdG"jp
autocmd BufWritePost,FileWritePost *.nc set nobin "turn off binary
"delete the contents of the register 'j'
autocmd BufWritePost,FileWritePost *.nc let @j = ""
"trigger a screen redraw cuz things are fucked up
autocmd BufWritePost,FileWritePost *.nc normal 

autocmd FileType mail call ToggleHighlightLongLines()

" fixup home/end keys
" Solaris (isn't this the default?!)
map OH <Home>
map OF <End>
imap OH <Home>
imap OF <End>

" screen
map [1~ <Home>
map [4~ <End>
imap [1~ <Home>
imap [4~ <End>

map  
imap  
