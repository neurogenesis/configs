" Vim color file
" Converted from Textmate theme Monokai using Coloration v0.3.2 (http://github.com/sickill/coloration)

" Modified by kine

set background=dark
highlight clear

if exists("syntax_on")
	syntax reset
endif

let g:colors_name = "Monokai-mod"

" COLOUR KEY:
" 0: black   -- #171514
" 1: magenta -- #ee274d
" 2: green   -- #a5e02d
" 3: yellow  -- #e2da6e
" 4: blue    -- #0000b2
" 5: purple  -- #8a6cb4
" 6: cyan    -- #64d9ed
" 7: white   -- 
" 233: grey  -- #121212
" 234: grey  -- #1c1c1c
" 235: grey  -- #262626
" 236: grey  -- #303030
" 237: grey  -- #3a3a3a
" 240: grey  -- #585858
" 241: grey  -- #626262
" 242: grey  -- #6c6c6c
" 251: grey  -- #c6c6c6

" Cursor
hi Cursor              ctermfg=231  ctermbg=5    cterm=NONE guifg=#ffffff  guibg=#8a6cb4  gui=NONE
" Cursor highlight: line
hi CursorLine          ctermfg=231  ctermbg=235  cterm=NONE guifg=NONE     guibg=#262626  gui=NONE
" Cursor highlight: column — not used
hi CursorColumn        ctermfg=NONE ctermbg=237  cterm=NONE guifg=NONE     guibg=#3c3d37  gui=NONE

" Selection highlight
hi Visual              ctermfg=NONE ctermbg=59   cterm=NONE guifg=#ffffff  guibg=#3774d6  gui=NONE

" Default text/background
hi Normal              ctermfg=231  ctermbg=NONE cterm=NONE guifg=#f8f8f8  guibg=#171514  gui=NONE

" Line numbers
hi LineNr              ctermfg=236  ctermbg=NONE cterm=NONE guifg=#303030  guibg=NONE     gui=NONE
" Current line number
hi CursorLineNr        ctermfg=5    ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE

" Status line for focussed buffer
hi StatusLine          ctermfg=0    ctermbg=3    cterm=NONE guifg=#171514  guibg=#e2da6e  gui=NONE
" Status line for unfocussed buffer
hi StatusLineNC        ctermfg=0    ctermbg=251  cterm=NONE guifg=#171514  guibg=#c6c6c6  gui=NONE

" Wildmenu selection highlight
hi WildMenu            ctermfg=231  ctermbg=5    cterm=NONE guifg=#ffffff  guibg=#8a6cb4  gui=NONE

" Vertical split dividers
hi VertSplit           ctermfg=241  ctermbg=241  cterm=NONE guifg=#3a3a3a  guibg=#3a3a3a  gui=NONE

" Text/background for lines exceeding column count
hi ColorColumn         ctermfg=NONE ctermbg=237  cterm=NONE guifg=NONE     guibg=#3c3d37  gui=NONE

" Error messages — seen in command bar
hi ErrorMsg            ctermfg=231  ctermbg=197  cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi WarningMsg          ctermfg=231  ctermbg=197  cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE

" Command-bar questions — including 'Press ENTER' prompt
hi Question            ctermfg=1    ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE

" Key sequences and <tab> characters
hi SpecialKey          ctermfg=236  ctermbg=NONE cterm=NONE guifg=#303030  guibg=NONE     gui=NONE
" Empty-line tildes and EOL characters
hi NonText             ctermfg=236  ctermbg=NONE cterm=NONE guifg=#303030  guibg=NONE     gui=NONE

" Incremental search highlight
hi IncSearch           ctermfg=233  ctermbg=3    cterm=NONE guifg=#121212  guibg=#e2da6e  gui=NONE
" Search result highlight
hi Search              ctermfg=3    ctermbg=235  cterm=NONE guifg=#e2da6e  guibg=#262626  gui=NONE

" Comments
hi Comment             ctermfg=242  ctermbg=NONE cterm=NONE guifg=#6c6c6c  guibg=NONE     gui=NONE
" Statements (e.g., vim commands and conditionals)
hi Statement           ctermfg=1    ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
" Conditionals                  (excluding       vim            conditionals)
hi Conditional         ctermfg=1    ctermbg=NONE cterm=NONE guifg=#f00072  guibg=NONE     gui=NONE
" Functions (e.g., *substitute*())
hi Function            ctermfg=2    ctermbg=NONE cterm=NONE guifg=#a5e02d  guibg=NONE     gui=NONE
" Pre-processor directives (in vim, these are things like set *background*=dark)
hi PreProc             ctermfg=1    ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE

" Operators (e.g., = / == / ||)
hi Operator            ctermfg=1    ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE

" Identifiers (in vim, these are things like a:var)
hi Identifier          ctermfg=6    ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE

" Strings (e.g., has(*'unix'*)
hi String              ctermfg=3    ctermbg=NONE cterm=NONE guifg=#e2da6e  guibg=NONE     gui=NONE
" Numbers (e.g., ctermfg=*141*)
hi Number              ctermfg=5    ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
" Constants
hi Constant            ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
" Booleans (e.g., true/false)
hi Boolean             ctermfg=5    ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE

" Bracket matching
hi MatchParen          ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE

hi Pmenu               ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi PmenuSel            ctermfg=NONE ctermbg=59   cterm=NONE guifg=NONE     guibg=#49483e  gui=NONE
hi Directory           ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi Folded              ctermfg=242  ctermbg=235  cterm=NONE guifg=#75715e  guibg=#272822  gui=NONE
hi Character           ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi Define              ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi DiffAdd             ctermfg=231  ctermbg=64   cterm=NONE guifg=#f8f8f2  guibg=#46830c  gui=bold
hi DiffDelete          ctermfg=88   ctermbg=NONE cterm=NONE guifg=#8b0807  guibg=NONE     gui=NONE
hi DiffChange          ctermfg=231  ctermbg=23   cterm=NONE guifg=#f8f8f2  guibg=#243955  gui=NONE
hi DiffText            ctermfg=231  ctermbg=24   cterm=NONE guifg=#f8f8f2  guibg=#204a87  gui=bold
hi Float               ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi Keyword             ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi Label               ctermfg=186  ctermbg=NONE cterm=NONE guifg=#e2da6e  guibg=NONE     gui=NONE
hi Special             ctermfg=231  ctermbg=NONE cterm=NONE guifg=#f8f8f2  guibg=NONE     gui=NONE
hi StorageClass        ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi Tag                 ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi Title               ctermfg=231  ctermbg=NONE cterm=NONE guifg=#f8f8f2  guibg=NONE     gui=bold
hi Todo                ctermfg=95   ctermbg=NONE cterm=NONE guifg=#75715e  guibg=NONE     gui=inverse,bold
hi Type                ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi Underlined          ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=underline


" ===================
" vim-specific syntax
" ===================

" User-defined functions (built-ins are covered by 'Function')
hi vimFunction         ctermfg=2    ctermbg=NONE cterm=NONE guifg=#a5e02d  guibg=NONE     gui=NONE
hi vimUserFunc         ctermfg=2    ctermbg=NONE cterm=NONE guifg=#a5e02d  guibg=NONE     gui=NONE

" Variables (some of these are covered by 'Identifier')
hi vimVar              ctermfg=6    ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi vimFBVar            ctermfg=6    ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE


" ====================
" HTML-specific syntax
" ====================
hi htmlTag             ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi htmlEndTag          ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi htmlTagName         ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi htmlArg             ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi htmlSpecialChar     ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE


" ===================
" CSS-specific syntax
" ===================
hi cssURL              ctermfg=208  ctermbg=NONE cterm=NONE guifg=#fd971f  guibg=NONE     gui=italic
hi cssFunctionName     ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi cssColor            ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi cssPseudoClassId    ctermfg=148  ctermbg=NONE cterm=NONE guifg=#a5e02d  guibg=NONE     gui=NONE
hi cssClassName        ctermfg=148  ctermbg=NONE cterm=NONE guifg=#a5e02d  guibg=NONE     gui=NONE
hi cssValueLength      ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi cssCommonAttr       ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi cssBraces           ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE


" ==========================
" JavaScript-specific syntax
" ==========================
hi javaScriptFunction      ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=italic
hi javaScriptRailsFunction ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi javaScriptBraces        ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE


" ====================
" YAML-specific syntax
" ====================
hi yamlKey             ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi yamlAnchor          ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi yamlAlias           ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi yamlDocumentHeader  ctermfg=186  ctermbg=NONE cterm=NONE guifg=#e2da6e  guibg=NONE     gui=NONE


" ====================
" ruby-specific               syntax
" ====================
hi rubyClass                    ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi rubyFunction                 ctermfg=148  ctermbg=NONE cterm=NONE guifg=#a5e02d  guibg=NONE     gui=NONE
hi rubyInterpolationDelimiter   ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi rubySymbol                   ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi rubyConstant                 ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=italic
hi rubyStringDelimiter          ctermfg=186  ctermbg=NONE cterm=NONE guifg=#e2da6e  guibg=NONE     gui=NONE
hi rubyBlockParameter           ctermfg=208  ctermbg=NONE cterm=NONE guifg=#fd971f  guibg=NONE     gui=italic
hi rubyInstanceVariable         ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi rubyInclude                  ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi rubyGlobalVariable           ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi rubyRegexp                   ctermfg=186  ctermbg=NONE cterm=NONE guifg=#e2da6e  guibg=NONE     gui=NONE
hi rubyRegexpDelimiter          ctermfg=186  ctermbg=NONE cterm=NONE guifg=#e2da6e  guibg=NONE     gui=NONE
hi rubyEscape                   ctermfg=141  ctermbg=NONE cterm=NONE guifg=#8a6cb4  guibg=NONE     gui=NONE
hi rubyControl                  ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi rubyClassVariable            ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi rubyOperator                 ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi rubyException                ctermfg=197  ctermbg=NONE cterm=NONE guifg=#ee274d  guibg=NONE     gui=NONE
hi rubyPseudoVariable           ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi rubyRailsUserClass           ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=italic
hi rubyRailsARAssociationMethod ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi rubyRailsARMethod            ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi rubyRailsRenderMethod        ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi rubyRailsMethod              ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE
hi erubyDelimiter               ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE     guibg=NONE     gui=NONE
hi erubyComment                 ctermfg=95   ctermbg=NONE cterm=NONE guifg=#75715e  guibg=NONE     gui=NONE
hi erubyRailsMethod             ctermfg=81   ctermbg=NONE cterm=NONE guifg=#64d9ed  guibg=NONE     gui=NONE


