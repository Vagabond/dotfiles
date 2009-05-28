" Vim syntax file
" Language:	Asterisk voicemail config file
" Maintainer: Tilghman Lesher (Corydon76)
" Last Change:	2006 Mar 20 
" version 0.2
"
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn sync clear
syn sync fromstart


syn keyword     asteriskTodo    TODO contained
syn match       asteriskComment         ";.*" contains=asteriskTodo
syn match       asteriskContext         "\[.\{-}\]"

" ZoneMessages
syn match       asteriskZone            "^[[:alnum:]]\+\s*=>\?\s*[[:alnum:]/_]\+|.*$" contains=zoneName,zoneDef
syn match       zoneName                "=\zs[[:alnum:]/_]\+\ze" contained
syn match       zoneDef                 "|\zs.*\ze$" contained

syn match       asteriskSetting         "\<\(format\|serveremail\|minmessage\|maxmessage\|maxgreet\|skipms\|maxsilence\|silencethreshold\|maxlogins\)="
syn match       asteriskSetting         "\<\(externnotify\|externpass\|directoryintro\|charset\|adsi\(fdn\|sec\|ver\)\|\(pager\)\?fromstring\|email\(subject\|body\|cmd\)\|tz\|cidinternalcontexts\|saydurationm\|dialout\|callback\)="
syn match       asteriskSettingBool     "\<\(attach\|pbxskip\|usedirectory\|saycid\|sayduration\|sendvoicemail\|review\|operator\|envelope\|delete\|nextaftercmd\|forcename\|forcegreeting\)=\(yes\|no\|1\|0\|true\|false\|t\|f\)"

" Individual mailbox definitions
syn match       asteriskMailbox         "^[[:digit:]]\+\s*=>\?\s*[[:digit:]]\+\(,[^,]*\(,[^,]*\(,[^,]*\(,[^,]*\)\?\)\?\)\?\)\?" contains=mailboxEmail,asteriskSetting,asteriskSettingBool,comma
syn match       mailboxEmail            ",\zs[^@=,]*@[[:alnum:]\-\.]\+\.[[:alpha:]]\{2,10}\ze" contains=comma
syn match       comma                   "[,|]" contained

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
:if version >= 508 || !exists("did_conf_syntax_inits")
  if version < 508
    let did_conf_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink        asteriskComment Comment
  HiLink        asteriskContext         Identifier
  HiLink        asteriskZone            Type
  HiLink        zoneName                String
  HiLink        zoneDef                 String
  HiLink        asteriskSetting         Type
  HiLink        asteriskSettingBool     Type

  HiLink        asteriskMailbox         Statement
  HiLink        mailboxEmail            String
 delcommand HiLink
endif

let b:current_syntax = "asterisk_voicemail"

" vim: ts=8 sw=2
