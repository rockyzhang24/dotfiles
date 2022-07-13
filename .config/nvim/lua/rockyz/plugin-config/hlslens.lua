-- Do not show search count message when searching
vim.opt.shortmess:append('S')

-- Customize virtual text
require('hlslens').setup({
  override_lens = function(render, plist, nearest, idx, r_idx)
    local indicator, text, chunks
    local abs_r_idx = math.abs(r_idx)
    if abs_r_idx > 1 then
      indicator = ('%d%s'):format(abs_r_idx, (r_idx > 1) and 'n' or 'N')
    elseif abs_r_idx == 1 then
      indicator = (r_idx == 1) and 'n' or 'N'
    else
      indicator = ''
    end

    local lnum, col = unpack(plist[idx])
    if nearest then
      local cnt = #plist
      if indicator ~= '' then
        text = ('[%s %d/%d]'):format(indicator, idx, cnt)
      else
        text = ('[%d/%d]'):format(idx, cnt)
      end
      chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
    else
      text = ('[%s %d]'):format(indicator, idx)
      chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
    end
    render.set_virt(0, lnum - 1, col - 1, chunks, nearest)
  end
})

-- Mappings
local map_opts = { silent = true }
-- Integrated with vim-asterisk
vim.keymap.set({ 'n', 'x' }, '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
vim.keymap.set({ 'n', 'x' }, '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
vim.keymap.set({ 'n', 'x' }, 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
vim.keymap.set({ 'n', 'x' }, 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], map_opts)
