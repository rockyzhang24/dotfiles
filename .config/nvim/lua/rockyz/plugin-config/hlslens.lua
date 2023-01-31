-- Do not show search count message when searching
vim.opt.shortmess:append('S')

local hlslens = require('hlslens')

hlslens.setup({
  -- calm_down = true,
  float_shadow_blend = 5,
})

-- Mappings
local map_opts = { silent = true }
-- Integrate with vim-asterisk
vim.keymap.set({ 'n', 'x' }, '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
vim.keymap.set({ 'n', 'x' }, '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
vim.keymap.set({ 'n', 'x' }, 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
vim.keymap.set({ 'n', 'x' }, 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
-- Integrate with nvim-ufo
local function nN(char)
  local ok, winid = hlslens.nNPeekWithUFO(char)
  if ok and winid then
    -- Safe to override buffer scope keymaps remapped by ufo,
    -- ufo will restore previous buffer keymaps before closing preview window
    -- Type <CR> will switch to preview window and fire `trace` action
    vim.keymap.set('n', '<CR>', function()
      local keyCodes = vim.api.nvim_replace_termcodes('<Tab><CR>', true, false, true)
      vim.api.nvim_feedkeys(keyCodes, 'im', false)
    end, {buffer = true})
  end
  vim.cmd('normal! zz')
end
vim.keymap.set({'n', 'x'}, 'n', function() nN('n') end)
vim.keymap.set({'n', 'x'}, 'N', function() nN('N') end)
-- Dump the search results into quickfix list
vim.keymap.set({'n', 'x'}, '<Leader>q/', function ()
  vim.schedule(function()
    if require('hlslens').exportLastSearchToQuickfix() then
      vim.cmd('cwindow')
    end
  end)
  return ':noh<CR>'
end, { expr = true })
