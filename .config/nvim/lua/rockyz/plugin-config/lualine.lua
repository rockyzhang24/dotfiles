-- Some functions are highly inspired by LunarVim

local lsp = vim.lsp
local colors = {
  yellow = '#E8AB53',
  green = '#6a9955',
  red = '#d16969',
  gray ='#858585',
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
    str = vim.fn.expand('%:t')
  end
  local size = require('lualine.components.filesize')()
  return size == '' and str or str .. ' [' .. size .. ']'
end

-- Location
local function location()
  return '%3l/%-3L:%-2v [%3p%%]'
end

-- LSP progress
local function lsp_progress()
  local messages = lsp.util.get_progress_messages()[1]
  if not messages then
    return ""
  end
  local name = messages.name or ""
  local title = messages.title or ""
  local msg = messages.message or ""
  local percentage = messages.percentage or 0
  return string.format(" %%<[%s] %s %s (%s%%%%)", name, title, msg, percentage)
end

-- LSP clients
local function lsp_clients()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = lsp.get_active_clients({ bufnr = bufnr })
  local client_names = {}

  -- Clients
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
  local language_servers = '[' .. table.concat(client_names, ', ') .. ']'
  return language_servers
end

-- Indent type (tab or space) and number of spaces
local function spaces()
  local get_option = vim.api.nvim_buf_get_option
  local expandtab = get_option(0, 'expandtab')
  local spaces_cnt = expandtab and get_option(0, 'shiftwidth') or get_option(0, 'tabstop')
  return (expandtab and 'S:' or 'T:') .. spaces_cnt
end

local function hide_in_width()
  return vim.fn.winwidth(0) > 100
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
      {
        'branch',
        icon = { '', color = { fg = colors.yellow } },
      },
    },
    lualine_c = {
      {
        'diff',
        symbols = { added = ' ', modified = ' ', removed = ' ' },
      },
      {
        lsp_progress,
        padding = { left = 0, right = 1 },
      },
    },
    lualine_x = {
      {
        'diagnostics',
        sources = { "nvim_diagnostic" },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      },
      {
        lsp_clients,
        padding = { left = 1, right = 0 },
        cond = hide_in_width,
      },
      {
        -- Treesitter status
        function()
          return 'TS'
        end,
        color = function()
          local buf = vim.api.nvim_get_current_buf()
          local hl_is_enabled = vim.treesitter.highlighter.active[buf]
          local has_parser = require('nvim-treesitter.parsers').has_parser()
          return { fg = has_parser and (hl_is_enabled and colors.green or colors.red) or colors.gray }
        end,
        padding = { left = 1, right = 0 },
        cond = hide_in_width,
      },
      {
        spaces,
        icon = { '', color = { fg = colors.yellow } },
        cond = hide_in_width,
      },
    },
    lualine_y = {
      {
        'filetype',
      },
      {
        'filesize',
        fmt = function(str)
          return str == "" and str or "[" .. str .. "]"
        end,
        padding = { left = 0, right = 1 },
      },
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
