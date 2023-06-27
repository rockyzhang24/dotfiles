-- Some functions are highly inspired by LunarVim

local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local v = vim.v
local tabline = require('tabline.setup')
local colors = {
  white = '#ffffff',
  yellow = '#E8AB53',
  green = '#16825d',
  red = '#c72e0f',
  gray = '#858585',
}

-- Format for mode: only show the first char (or first two chars to distinguish
-- different VISUALs)
local function simplifiedMode(str)
  return " " .. (str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1)))
end

-- Format for filename: show the filename and the filesize
local function fileNameAndSize(str)
  -- For doc, only show filename
  if (string.find(str, '.*/doc/.*%.txt')) then
    str = fn.expand('%:t')
  end
  local size = require('lualine.components.filesize')()
  return size == '' and str or str .. ' [' .. size .. ']'
end

-- Location
local function location()
  return '%3l/%-3L:%-2v [%3p%%]'
end

-- LSP clients
local index = 1
local has_clients = false
local function lsp_clients()
  local bufnr = api.nvim_get_current_buf()
  local clients = lsp.get_active_clients({ bufnr = bufnr })
  local client_names = {}
  local spinner = { '🌖', '🌗', '🌘', '🌑', '🌒', '🌓', '🌔' }

  -- Use a table to contain the LSP clients for the current buffer
  for _, client in pairs(clients) do
    if client.name ~= 'null-ls' then
      table.insert(client_names, client.name)
    end
  end

  -- TODO
  -- Add formater
  -- Add linter

  if next(client_names) == nil then
    return 'LS Inactive'
  end

  has_clients = true

  local progress = '🌕'
  if lsp.status() ~= "" then
    index = index == #spinner and 1 or index + 1
    progress = spinner[index]
  end
  return progress .. ' ' .. table.concat(client_names, ', ')
end

-- Indent type (tab or space) and number of spaces
local function spaces()
  local get_local_option = function(option_name)
    return api.nvim_get_option_value(option_name, { scope = 'local' })
  end
  local expandtab = get_local_option('expandtab')
  local spaces_cnt = expandtab and get_local_option('shiftwidth') or get_local_option('tabstop')
  return (expandtab and 'S:' or 'T:') .. spaces_cnt
end

local function hide_in_width()
  return fn.winwidth(0) > 100
end

require 'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'arctic',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = simplifiedMode,
      },
    },
    lualine_b = {
      -- Git branch (fetched from gitsigns.nvim)
      {
        'b:gitsigns_head',
        icon = { '', color = { fg = colors.yellow } },
      },
    },
    lualine_c = {
      -- Git diff (use gitsigns.nvim as its source)
      {
        'diff',
        symbols = { added = ' ', modified = ' ', removed = ' ' },
        source = function()
          local status = vim.b.gitsigns_status_dict
          if status then
            return {
              added = status.added,
              modified = status.changed,
              removed = status.removed,
            }
          end
        end,
      },
    },
    lualine_x = {
      {
        'diagnostics',
        sources = { "nvim_diagnostic" },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
        cond = function()
          return not vim.diagnostic.is_disabled()
        end,
      },
      -- Show a symbol when diagnostic is off
      {
        function()
          return ' '
        end,
        color = { fg = colors.red },
        cond = function()
          return vim.diagnostic.is_disabled()
        end,
      },
      -- Show a symbol when spell is on
      {
        function()
          return vim.o.spell and ' ' or ''
        end,
        color = { fg = colors.green },
      },
      {
        'searchcount',
      },
      {
        lsp_clients,
        color = function()
          return { fg = has_clients and colors.white or colors.gray }
        end,
        cond = hide_in_width,
      },
      {
        -- Treesitter status
        -- Use different colors to denote whether it has a parser for the
        -- current file and whether the highlight is enabled:
        -- - gray  : no parser
        -- - green : has parser and highlight is enabled
        -- - red   : has parser but highlight is disabled
        function()
          return 'TS'
        end,
        color = function()
          local buf = api.nvim_get_current_buf()
          local hl_is_enabled = vim.treesitter.highlighter.active[buf]
          local has_parser = require('nvim-treesitter.parsers').has_parser()
          return { fg = has_parser and
              (hl_is_enabled and colors.green or colors.red) or colors.gray }
        end,
        cond = hide_in_width,
      },
      {
        spaces,
        icon = { '', color = { fg = colors.yellow } },
        cond = hide_in_width,
      },
      {
        -- Session indicator
        -- It shows the current session name and use a color to indicate whether
        -- the session persistance (brought by mg979/tabline.nvim) is enabled:
        -- - green: session persistance is enabled
        -- - white: session persistance is disabled
        function()
          local ss = v.this_session
          if ss ~= '' then
            return fn.fnamemodify(ss, ':t')
          else
            return 'None'
          end
        end,
        color = function()
          return { fg = v.this_session == '' and colors.gray or
              (tabline.global.persist and colors.green or colors.white) }
        end,
        icon = { '', color = { fg = colors.yellow } },
        cond = hide_in_width,
      },
    },
    lualine_y = {
      {
        'filetype',
      },
      -- {
      --   'filesize',
      --   fmt = function(str)
      --     return str == "" and str or "[" .. str .. "]"
      --   end,
      --   padding = { left = 0, right = 1 },
      -- },
    },
    lualine_z = {
      {
        location,
      },
    },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {
    'aerial',
    'fugitive',
    'man',
    'quickfix',
    'symbols-outline',
  }
}

-- For indicating the progress, update the statusline when the progress notification
-- is reported from the server
api.nvim_create_autocmd({ 'LspProgress' }, {
  pattern = '*',
  callback = function()
    require('lualine').refresh()
  end,
})
