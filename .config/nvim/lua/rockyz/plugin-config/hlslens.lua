local map = require('rockyz.keymap').map
local cmd = vim.cmd
local api = vim.api
local hlslens = require('hlslens')

-- Do not show search count message when searching
vim.opt.shortmess:append('S')

hlslens.setup({
  -- calm_down = true,
  float_shadow_blend = 5,
})

-- Mappings
-- Integrate with vim-asterisk
map({ 'n', 'x' }, '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]])
map({ 'n', 'x' }, '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]])
map({ 'n', 'x' }, 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]])
map({ 'n', 'x' }, 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]])
-- Integrate with nvim-ufo
local function nN(char)
  local ok, winid = hlslens.nNPeekWithUFO(char)
  if ok and winid then
    -- Safe to override buffer scope keymaps remapped by ufo,
    -- ufo will restore previous buffer keymaps before closing preview window
    -- Type <CR> will switch to preview window and fire `trace` action
    map('n', '<CR>', function()
      local keyCodes = api.nvim_replace_termcodes('<Tab><CR>', true, false, true)
      api.nvim_feedkeys(keyCodes, 'im', false)
    end, {buffer = true})
  end
  cmd('normal! zz')
end
map({'n', 'x'}, 'n', function() nN('n') end)
map({'n', 'x'}, 'N', function() nN('N') end)
-- Dump the search results into quickfix list
map({'n', 'x'}, '<Leader>q/', function ()
  vim.schedule(function()
    if require('hlslens').exportLastSearchToQuickfix() then
      cmd('cwindow')
    end
  end)
  return ':noh<CR>'
end, { expr = true })
