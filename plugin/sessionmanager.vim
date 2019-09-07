" This script makes use of the mksession command and saves sessions to g:session_directory
"===============================================================================
" GUARD
"===============================================================================
if v:version < 700
  finish
endif

if exists('sessionmanager')
  finish
endif

let g:sessionsave= 1
"===============================================================================
" END OF GUARD
"===============================================================================

"===============================================================================
" GLOBALS
"===============================================================================
let g:user_char_regex = "[a-zA-Z0-9]\\{1}"
let g:session_directory = "~/.vim/sessions/"
let g:session_extension = ".session"
let g:session_file = "default"
let g:autosave = 1
"===============================================================================
" END OF GLOBALS
"===============================================================================
function! SessionManager()
  if ! isdirectory(fnamemodify(g:session_directory, ":p"))
    echom g:session_directory. " not found. Creating one...\n"
    return mkdir(fnamemodify(g:session_directory, ":p"))
  else
    filewritable(fnamemodify(g:session_directory, ":p")) == 2 ? return 1 : return 0
  endif
endfunction

function! SessionSave()
  let g:session_file = nr2char(getchar()) 
  if g:session_file !~ g:user_char_regex
    echom "Char must match g:user_char_regex: ".g:user_char_regex
    return 0
  else
    let l:session_path = g:session_directory . g:session_file . g:session_extension
    execute "mksession! ".l:session_path
    return 1
  endif
endfunction

function! SessionAutoSave()
  if g:autosave
    let l:session_path = g:session_directory . g:session_file . g:session_extension
    execute "mksession! ".l:session_path
    return 1
  endif
  return 0
endfunction

function! SessionLoad() 
  let g:session_file = nr2char(getchar())
  if g:session_file !~ g:user_char_regex
    echom "Char must match g:user_char_regex: ".g:user_char_regex
    return 0
  else
    let l:session_path = fnamemodify(g:session_directory, ":p") . g:session_file . g:session_extension
    if !filereadable(l:session_path)
      echom "No session saved on \"".g:session_file."\""
      return 0
    else
      if !SessionClose()
	echom "Failed to close current session"
	return 0
      else
	echom l:session_path
	silent execute "source ".l:session_path
	return 1
      endif
    endif
  endif
endfunction

function! SessionClose()
  let l:unsaved_buffers = getbufinfo({'buflisted' : 1, 'bufmodified' : 1})
  let l:buffer_numbers = []
  for buffer in l:unsaved_buffers
    let l:buffer_numbers += [buffer['bufnr']]
  endfor
  if l:buffer_numbers !=# []
    echom "Session has modified buffers: ".l:buffer_numbers->join(', ')
    return 0
  else
    silent %bdelete
    return 1
  endif
endfunction

augroup sessionmanager
  autocmd!
  autocmd VimLeavePre * exe SessionAutoSave()
"  autocmd BufEnter * exe SessionAutoSave()
augroup END

command! -n=0 SessionSave call SessionSave()
