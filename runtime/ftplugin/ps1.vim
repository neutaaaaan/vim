" Vim filetype plugin file
" Language:    Windows PowerShell
" URL:         https://github.com/PProvost/vim-ps1
" Last Change: 2021 Apr 02
"              2024 Jan 14 by Vim Project (browsefilter)
"              2024 May 23 by Riley Bruins <ribru17@gmail.com> ('commentstring')
"              2024 Sep 19 by Konfekt (simplify keywordprg #15696)
"              2025 Jul 22 by phanium (use :hor term #17822)

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin") | finish | endif

" Don't load another plug-in for this buffer
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal tw=0
setlocal commentstring=#\ %s
setlocal formatoptions=tcqro
" Enable autocompletion of hyphenated PowerShell commands,
" e.g. Get-Content or Get-ADUser
setlocal iskeyword+=-

" Change the browse dialog on Win32 and GTK to show mainly PowerShell-related files
if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
	let b:browsefilter =
				\ "All PowerShell Files (*.ps1, *.psd1, *.psm1, *.ps1xml)\t*.ps1;*.psd1;*.psm1;*.ps1xml\n" .
				\ "PowerShell Script Files (*.ps1)\t*.ps1\n" .
				\ "PowerShell Module Files (*.psd1, *.psm1)\t*.psd1;*.psm1\n" .
				\ "PowerShell XML Files (*.ps1xml)\t*.ps1xml\n"
	if has("win32")
		let b:browsefilter .= "All Files (*.*)\t*\n"
	else
		let b:browsefilter .= "All Files (*)\t*\n"
	endif
endif

" Undo the stuff we changed
let b:undo_ftplugin = "setlocal tw< cms< fo< iskeyword<" .
			\ " | unlet! b:browsefilter"

" Look up keywords by Get-Help:
" check for PowerShell Core in Windows, Linux or MacOS
if executable('pwsh') | let s:pwsh_cmd = 'pwsh'
  " on Windows Subsystem for Linux, check for PowerShell Core in Windows
elseif exists('$WSLENV') && executable('pwsh.exe') | let s:pwsh_cmd = 'pwsh.exe'
  " check for PowerShell <= 5.1 in Windows
elseif executable('powershell.exe') | let s:pwsh_cmd = 'powershell.exe'
endif

if exists('s:pwsh_cmd')
  if exists(':terminal') == 2
    command! -buffer -nargs=1 GetHelp silent exe 'hor term ' . s:pwsh_cmd . ' -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command Get-Help -Full "<args>"' . (executable('less') ? ' | less' : '')
  else
    command! -buffer -nargs=1 GetHelp echo system(s:pwsh_cmd . ' -NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command Get-Help -Full <args>')
  endif
  setlocal keywordprg=:GetHelp
  let b:undo_ftplugin ..= " | setl kp< | sil! delc -buffer GetHelp"
endif

let &cpo = s:cpo_save
unlet s:cpo_save
