
" #############################################################################
" VIM CONFIGURATION
" 
" The way i use vim is almost completely contrary to the way everyone 
" recommends — all i want is a slightly more attractive and configurable 
" alternative to more basic editors like nano, so many of these settings are 
" intended to 'dumb down' some of vim's more complex features.
" 
" Keeping this in mind...
" #############################################################################


" =============================================================================
" GENERAL
" =============================================================================

" Set tab width to 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=0

" Don't expand tabs to spaces
set noexpandtab

" Ignore case when searching...
set ignorecase

" ... Except when entering capital letters
set smartcase

" Incremental search (like in Web browsers)
set incsearch

" Enable wildmenu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

" Regular expressions magic
set magic

" Disable error bells
set noerrorbells
set novisualbell
set t_vb=

" Reduce key-press time-out
set timeoutlen=350

" Set lines of history to remember
set history=500

" Auto-update files when they've been changed by other applications
" set autoread

" Use UTF-8 encoding by default
set encoding=utf8

" Set encodings to try when opening a file
set fileencodings=utf-8,latin1,iso-8859-n,utf-16,utf-16le,macroman,euc-jp

" Use Unix line endings by default
set ffs=unix,dos,mac

" Minimum of 3 lines visible at the bottom of the screen
set scrolloff=3

" Open new split windows below and to the right
set splitright splitbelow

" Enable syntax highlighting
syntax enable

" Use dark background
set background=dark

" Use Monokai-mod colour scheme
colorscheme Monokai-mod


" =============================================================================
" GUI (GVIM/MACVIM) SETTINGS
" =============================================================================

if has('gui_running')
	" GUI font
	set guifont=Andale\ Mono:h12

	" Disable antialiasing in MacVim
	if (exists('+antialias'))
		set noantialias
	endif

	" Hide tool bar
	set guioptions-=T

	" Hide scroll bars
	set guioptions-=L

	" Use Mac-like Shift-selection in MacVim
	if (has('gui_macvim'))
		let macvim_hig_shift_movement = 1
	endif
endif


" =============================================================================
" FUNCTIONS
" =============================================================================

" Return the edit mode for the status line
function! EditMode()
    let m = mode()

    if (m == 'n')
        return 'NORMAL'
    elseif (m == 'i')
        return 'INSERT'
    elseif (m == 'v') || (m == 'V') || (m == '')
        return 'VISUAL'
	elseif (m == 's') || (m == 'S') || (m == '')
		return 'SELECT'
    elseif (m == 'R')
        return 'REPLACE'
    elseif (m == 'no')
        return 'PENDING'
    elseif (m == 'c')
        return 'COMMAND'
    endif
endfunction

" Return the host name for the status line, &c.
" (The normal hostname() returns an FQDN, at least on my Mac)
function! HostName()
	" (On Windows, `hostname -s` isn't supported, but it works anyway, so w/e)
	let hn = substitute(system("hostname -s"), "\n", "", "g")
	return hn
endfunction

" Return the file name for the status line
function! FileName()
	if (expand('%:t') == '')
		return '-'
	else
		return expand('%:t')
	endif
endfunction

" Return the 'modified' icon for the status line
" (also whether it's read-only)
function! Modified()
	let mr = ''

	if (&readonly == 1)
		let mr .= ' [RO]'
	endif

	if (&modified == 1)
		let mr .= ' ●'
	endif

	return mr
endfunction

" Format line endings and file encoding for the status line
" (only display the endings/encoding if it's NOT unix:utf-8)
function! FileInfo(ff, fe)
    let fl = ''

    if (a:ff != 'unix') || (a:fe != 'utf-8')
        let fl .= ' ('
    endif

    if (a:ff == 'dos')
        let fl .= 'CRLF'
    elseif (a:ff == 'mac')
        let fl .= 'CR'
    endif

    if (a:ff != 'unix') && (a:fe != 'utf-8') && (a:fe != '')
        let fl .= ' / '
    endif

    if (a:fe != 'utf-8') && (a:fe != '')
        let fl .= a:fe
    endif

    if (a:ff != 'unix') || (a:fe != 'utf-8')
        let fl .= ')'
    endif

    " Do nothing if the file is empty
    if (a:ff == 'unix') && (a:fe == '')
        let fl = ''
    endif

    return fl
endfunction
 
" Return the percentage through the file
" (basically this re-implements %P with symbols instead of All/Top/Bot)
function! Percentage()
	" Entire file is visible ('All' in %P)
	if (line("w0") == 1) && (line("w$") == line("$"))
		return '  ∞'
	" Beginning of file is visible ('Top' in %P)
	elseif (line("w0") == 1)
		" Up-arrow thing doesn't work in Windows...
		if (has('unix'))
			return '  ⤒'
		else
			return '  t'
		endif
	" End of file is visible ('Bot' in %P)
	elseif (line("w$") == line("$"))
		" Down-arrow thing doesn't work in Windows...
		if (has('unix'))
			return '  ⤓'
		else
			return '  b'
		endif
	" Anything else (nn% in %P)
	else
		let pos  = line(".") + 1 - 1
		let size = line("$") + 1 - 1

		let pcnt = (pos * 100) / size

		if (pcnt < 10)
			return ' ' . pcnt . '%'
		else
			return '' . pcnt . '%'
		endif
	endif
endfunction

" Return battery charge level
" (requires batcharge.py in PATH)
function! BatteryCharge(ct, last)
	" Always run once at start-up
	if (a:ct == 0)
		let g:batlast = system("batcharge.py 2>/dev/null")
		let g:batcheck = strftime("%s")
		return g:batlast . ' strf: ' . g:batcheck . ' / lastch: ' . a:ct

	" If it's been less than 2 minutes, return the last value
	elseif ((strftime("%s") - a:ct) < 120)
		return a:last

	" Otherwise, continue and update the last run time
	else
		let g:batlast = system("batcharge.py 2>/dev/null")
		let g:batcheck = strftime("%s")
		return g:batlast
	endif
endfunction

" Command-bar query colour (used with NanoClose(), &c.)
hi NanoMsg ctermfg=1    ctermbg=NONE cterm=NONE guifg=#ee274d guibg=NONE gui=NONE

" Emulate nano's Ctrl+X feature
function! NanoClose()
	" If the file hasn't been modified, exit immediately
	if (&modified == 0)
		:q

	" If the file has been modified, prompt
	else
		call inputsave()
		echohl NanoMsg
		let yesno = tolower(input('Save modified buffer (ANSWERING "No" WILL DESTROY CHANGES) ? '))
		echohl None
		call inputrestore()

		" Yes => exit and save
		if (yesno == 'yes') || (yesno == 'y')
			:wq
			echo '^x — Saved and closed buffer.'
		" No => exit without saving
		elseif (yesno == 'no') || (yesno == 'n')
			:q!
			echo '^x — Closed buffer without saving.'
		" Cancel => do nothing
		else
			echo ''
		endif
	endif
endfunction


" =============================================================================
" VARIABLES
" =============================================================================

" Get the current host name. Since this will amost never change during a 
" session, it's wasteful to keep calling the function over and over 
let hostname = HostName()

" This variable will limit the frequency of calls to the battery-charge script.
" Setting it to 0 here ensures that it's run once at start-up
let batcheck = 0

" This will be used by the battery script also
let batlast = ''


" =============================================================================
" USER INTERFACE
" =============================================================================

" COLOUR KEY:
" 0: black       8: bright black
" 1: magenta     9: bright magenta
" 2: green      10: bright green
" 3: yellow     11: bright yellow
" 4: blue       12: bright blue
" 5: purple     13: bright purple
" 6: cyan       14: bright cyan
" 7: white      15: bright white

" Set command-bar height to 1 line
set cmdheight=1

" White-space characters (don't display by default)
set nolist
set listchars=trail:▫,nbsp:▫,tab:‣\ ,eol:¬

" Display line numbers
set nu

" Highlight the current line
set cursorline

" Highlight search results
set hlsearch

" Always show the status line
set laststatus=2

" Set up the status line
set statusline=\ 

" Edit mode
if (has('unix'))
	if ($USER == 'root') 
		set statusline+=%{EditMode()}#\ 
	else
		set statusline+=%{EditMode()}‣\ 
	endif
else
	" The triangle thing doesn't work on Windows...
	set statusline+=%{EditMode()}:\ 
endif

" Battery charge — requires batcharge.py
if (has('unix')) && (system("which batcharge.py") != 'batcharge.py not found')
	set statusline+=%{BatteryCharge(batcheck,batlast)}\ 
endif

set statusline+=%{hostname}:                          " Host name
set statusline+=%{FileName()}                         " File name
set statusline+=%{Modified()}\                        " Modified flag
set statusline+=%{FileInfo(&ff,&fenc)}\               " Line endings
set statusline+=%=                                    " Right-align
set statusline+=%l:%c\                                " Current line:column
set statusline+=(%L:%{strlen(getline('.'))})\         " Total lines:columns
set statusline+=%{Percentage()}\                      " Percentage

" Change the status line colour in INSERT mode
au InsertEnter * hi statusline ctermfg=0    ctermbg=2    cterm=NONE guifg=#121110 guibg=#96dd22 gui=NONE
au InsertLeave * hi statusline ctermfg=0    ctermbg=3    cterm=NONE guifg=#121110 guibg=#e2da6e gui=NONE


" =============================================================================
" LEADER BINDINGS
" =============================================================================

" Set leader key to comma
let mapleader = ","

" ,/  => Clear search highlights
nnoremap <leader>/ :set hlsearch!<CR>:echo ',/ — Toggle search highlights'<CR>

" ,n => Show/hide line numbers
nnoremap <leader>n :set nonumber!<CR>:echo ',n — Toggle line numbers'<CR>

" ,w => Show/hide white-space characters
nnoremap <leader>w :set list!<CR>:echo ',w — Toggle white-space characters'<CR>

" ,m => Strip Windows line endings (^M)
nnoremap <leader>m :%s///g<CR>:echo ',m — Windows line endings (^M)'<CR>

" ,^ => Strip leading white space
nnoremap <leader>^ :%s/^\s\+//g<CR>:echo ',^ — Strip leading white space'<CR>

" ,$ => Strip trailing white space
nnoremap <leader>$ :%s/\s\+$//g<CR>:echo ',$ — Strip trailing white space'<CR>

" ,vi => Edit .vimrc in new split window
nnoremap <leader>vi <C-w><C-v><C-w><C-l>:e $MYVIMRC<CR>:echo ',vi — Open and edit .vimrc'<CR>

" ,v => Open vertical split with new file
nnoremap <leader>v :vnew<CR>:echo ',v — Vertical split with new file'<CR>

" ,V => Open vertical split with existing file
nnoremap <leader>V :vsplit<CR>:echo ',V — Vertical split with existing file'<CR>

" ,s => Open horizontal split with new file
nnoremap <leader>s :new<CR>:echo ',s — Horizontal split with new file'<CR>

" ,S => Open horizontal split with existing file
nnoremap <leader>S :split<CR>:echo ',S — Horizontal split with existing file'<CR>

" ,hi => Show highlight group(s) of the character beneath the cursor
nnoremap <leader>hi :echo ",hi — Highlight group(s) of character:\n      hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


" =============================================================================
" KEY BINDINGS
" =============================================================================

" Make Ctrl+X behave like in nano
map  <C-x>  :call NanoClose()<CR>
imap <C-x>  <C-o>:call NanoClose()<CR>

" Make left/right arrows go up and down lines
set whichwrap+=<,>,[,],h,l

" Make Backspace and Delete behave normally
set backspace=2

" Make ; behave like : in normal mode
nnoremap ; :

" Make Ctrl+w v open a new vertical buffer with a blank file
nnoremap <C-w>v :vnew<CR>

" Make Ctrl+w Ctrl+v open a new vertical buffer with the current file
nnoremap <C-w><C-v> :vsplit<CR>

" Make Ctrl+w Ctrl+n open a new horizontal buffer with the current file (equal to Ctrl+s)
nnoremap <C-w><C-n> :split<CR>

" Map Ctrl+arrows to the correct escape sequences
" (Terminal vim doesn't recognise C-Up and C-Down, nfi why)
set <C-Left>=[D
set <C-Right>=[C
set <F13>=[A
set <F14>=[B

" Make Ctrl+arrows navigate split windows
map  <C-Left>   <C-w>h
map  <C-Right>  <C-w>l
map  <C-Up>     <C-w>k
map  <C-Down>   <C-w>j
map  <F13>      <C-w>k
map  <F14>      <C-w>j
imap <C-Left>   <C-o><C-w>h
imap <C-Right>  <C-o><C-w>l
imap <C-Up>     <C-o><C-w>k
imap <C-Down>   <C-o><C-w>j
imap <F13>      <C-o><C-w>k
imap <F14>      <C-o><C-w>j

" Fix Ctrl+A and Ctrl+E
map  <C-a>  ^
map  <C-e>  $
imap <C-a>  <Esc>^i
imap <C-e>  <Esc>$a
cmap <C-a>  <C-b>

" Fix Ctrl+K
imap <C-k>  <Esc>ddi

" Fix Home and End
map  <Home>  ^
map  <End>   $
imap <Home>  <Esc>^i
imap <End>   <Esc>$a
cmap <Home>  <C-b>
cmap <End>   <C-e>

" Fix PageUp and PageDown
map  <PageUp>    <C-u>
map  <PageDown>  <C-d>
imap <PageUp>    <C-o><C-u>
imap <PageDown>  <C-o><C-d>

" Fix Option+arrows
if (has('gui_macvim'))
	map <A-Left>   b
	map <A-Right>  e
	imap <A-Left>  <Esc>b
	imap <A-Right> <Esc>ea
else
	noremap  <Esc>b  b
	noremap  <Esc>f  e
	inoremap <Esc>b  <Esc>bi
	inoremap <Esc>f  <Esc>ea
endif

" Don't reset the cursor column
set nostartofline


" =============================================================================
" AUTO-COMMANDS / MISC.
" =============================================================================

" Automatically reload .vimrc after editing
au! BufWritePost .vimrc so %


" Automatically resize windows when terminal is resized
" (Don't do this in GUI mode or whatever)
if (&term == "screen" || &term == "xterm" || &term == "xterm-256color")
	au VimResized * exe "normal! \<C-w>="
endif

" Update the terminal title
au BufEnter * let &titlestring = hostname . ":vim:" . substitute(expand("%:t"),"^$","-","")

if (&term == "screen")
	set t_ts=k
	set t_fs=\
endif

if (&term == "screen" || &term == "xterm" || &term == "xterm-256color")
	set title
endif

