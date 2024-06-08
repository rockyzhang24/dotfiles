-- I am using tab and leadmultispace in listchars to display the indent line. The chars for tab and
-- leadmultispace should be updated based on whether the indentation has been changed.
-- 1. If using space as indentation: set tab to a special character for denotation and
--    leadmultispace to the indent line character followed by multiple spaces whose amounts depends
--    on the number of spaces to use in each step of indent.
-- 2. If using tab as indentation: set leadmultispace to a special character for denotation and tab
--    to the indent line character.

local function set_or_update(is_local)

  local indentchar_update = function(items)
    local listchars = vim.api.nvim_get_option_value('listchars', {})
    for item, val in pairs(items) do
      if listchars:match(item) then
        listchars = listchars:gsub('(' .. item .. ':)[^,]*', '%1' .. val)
      else
        listchars = listchars .. ',' .. item .. ':' .. val
      end
    end
    return listchars
  end

  local new_chars = ''
  if vim.api.nvim_get_option_value('expandtab', {}) then
    -- For space indentation
    local spaces = vim.api.nvim_get_option_value('shiftwidth', {})
    -- If shiftwidth is 0, vim will use tabstop value
    if spaces == 0 then
      spaces = vim.api.nvim_get_option_value('tabstop', {})
    end
    new_chars = indentchar_update({
      tab = '› ',
      leadmultispace = vim.g.indentline_char .. string.rep(' ', spaces - 1),
    })
  else
    -- For tab indentation
    new_chars = indentchar_update({
      tab = vim.g.indentline_char .. ' ',
      leadmultispace = '␣'
    })
  end
  local opts = {}
  if is_local then
    opts.scope = 'local'
  end
  vim.api.nvim_set_option_value('listchars', new_chars, opts)
end

vim.api.nvim_create_augroup('rockyz/indentline', { clear = true })

-- Initialize the indent line
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = 'rockyz/indentline',
  callback = function()
    set_or_update(false)
  end,
})
-- Update the indent line
vim.api.nvim_create_autocmd({ 'OptionSet' }, {
  group = 'rockyz/indentline',
  pattern = { 'shiftwidth', 'expandtab', 'tabstop' },
  callback = function()
    set_or_update(vim.v.option_type == 'local')
  end,
})

