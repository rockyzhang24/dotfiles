if exists('b:current_syntax')
    finish
endif

syn match QuickfixFileName /^[^|]*/ nextgroup=QuickfixSeparatorLeft
syn match QuickfixSeparatorLeft /|/ contained nextgroup=QuickfixLnum
syn match QuickfixLnum /[^:]*/ contained nextgroup=QuickfixCol
syn match QuickfixCol /[^|]*/ contained nextgroup=QuickfixSeparatorRight
syn match QuickfixSeparatorRight '|' contained nextgroup=QuickfixError,QuickfixWarn,QuickfixInfo,QuickfixHint
syn match QuickfixError / E .*$/ contained
syn match QuickfixWarn / W .*$/ contained
syn match QuickfixInfo / I .*$/ contained
syn match QuickfixHint / H .*$/ contained

let b:current_syntax = 'qf'
