-- Skip backwards compatibility routines and speed up loading
vim.g.skip_ts_context_commentstring_module = true

require('ts_context_commentstring').setup({
})
