local M = {}

local bar = require('rockyz.icons').separators.bar

--
-- Change the appearance for the texts displayed in quickfix
-- Ref: https://github.com/kevinhwang91/nvim-bqf#customize-quickfix-window-easter-egg
--

-- The length limit of the file name
local limit = vim.o.columns / 4
local fname_fmt1, fname_fmt2 = '%-' .. limit .. 's', ' %.' .. (limit - 2) .. 's'
local valid_fmt = '%s ' .. bar .. '%5d:%-3d' .. bar .. '%s %s'

function M.format_qf_item(item)
  local fname = ''
  local str
  if item.valid == 1 then
    if item.bufnr > 0 then
      fname = vim.fn.bufname(item.bufnr)
      if fname == '' then
        fname = '[No Name]'
      else
        fname = fname:gsub('^' .. vim.env.HOME, '~')
      end
      -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
      if #fname <= limit then
        fname = fname_fmt1:format(fname)
      else
        fname = fname_fmt2:format(fname:sub(1 - limit))
      end
    end
    local lnum = item.lnum > 99999 and -1 or item.lnum
    local col = item.col > 999 and -1 or item.col
    local qtype = item.type == '' and '' or ' ' .. item.type:sub(1, 1):upper()
    str = valid_fmt:format(fname, lnum, col, qtype, item.text)
  else
    str = item.text
  end
  return str
end

return M
