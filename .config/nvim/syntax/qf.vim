" Syntax for quickfix window
" Ref: https://github.com/kevinhwang91/nvim-bqf#rebuild-syntax-for-quickfix
if exists('b:current_syntax')
    finish
endif

syn match qfFileName /^[^│]*/ nextgroup=qfSeparatorLeft
syn match qfSeparatorLeft /│/ contained nextgroup=qfLineNr
syn match qfLineNr /[^│]*/ contained nextgroup=qfSeparatorRight
syn match qfSeparatorRight '│' contained nextgroup=qfError,qfWarning,qfInfo,qfNote,qfOtherText
syn match qfError / E .*$/ contained
syn match qfWarning / W .*$/ contained
syn match qfInfo / I .*$/ contained
syn match qfNote / [NH] .*$/ contained
syn match qfOtherText / [^EWINH]*$/ contained

if g:colorscheme ==# 'arctic'
    hi def link qfFileName QfFileName
    hi def link qfSeparatorLeft WinSeparator
    hi def link qfLineNr QfText
    hi def link qfSeparatorRight FloatBorder
    hi def link qfError DiagnosticSignError
    hi def link qfWarning DiagnosticSignWarn
    hi def link qfInfo DiagnosticSignInfo
    hi def link qfNote DiagnosticSignHint
    hi def link qfOtherText QfText
else
    hi def link qfFileName Directory
    hi def link qfSeparatorLeft Delimiter
    hi def link qfLineNr LineNr
    hi def link qfSeparatorRight Delimiter
    hi def link qfError DiagnosticSignError
    hi def link qfWarning DiagnosticSignWarn
    hi def link qfInfo DiagnosticSignInfo
    hi def link qfNote DiagnosticSignHint
    hi def link qfOtherText Normal
endif

let b:current_syntax = 'qf'
