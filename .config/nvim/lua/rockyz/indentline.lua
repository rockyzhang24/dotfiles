-- Display indent guides using Neovim's builtin 'listchars'.
--
-- This module updates the 'tab' and 'leadmultispace' listchars according to the current indentation
-- style:
--
-- - Space indentation:
--   Use 'leadmultispace' as the indent guide, and use 'tab' only as a marker for literal tab
--   characters.
--
-- - Tab indentation:
--   Use 'tab' as the indent guide, and use 'leadmultispace' only as a marker for leading spaces.

local has_icons, icons = pcall(require, 'rockyz.icons')
local indentline_char = has_icons and icons.lines.double_dash_vertical or '╎'

local tab_marker = '› '
local space_marker = '␣'

---@return integer
local function get_indent_width()
    local shiftwidth = vim.api.nvim_get_option_value('shiftwidth', {})
    if shiftwidth > 0 then
        return shiftwidth
    end
    -- 'shiftwidth=0' means to use 'tabstop'
    return vim.api.nvim_get_option_value('tabstop', {})
end

---@return table<string, string>
local function build_indent_listchars()
    if vim.api.nvim_get_option_value('expandtab', {}) then
        local indent_width = get_indent_width()
        return {
            tab = tab_marker,
            leadmultispace = indentline_char .. string.rep(' ', indent_width - 1),
        }
    end

    return {
        tab = indentline_char .. ' ',
        leadmultispace = space_marker,
    }
end

---@param opt table vim.opt, vim.opt_local, vim.opt_global
local function update_listchars(opt)
    local listchars = build_indent_listchars()
    opt.listchars:append(listchars)
end

local indentline_augroup = vim.api.nvim_create_augroup('rockyz.indentline', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
    group = indentline_augroup,
    callback = function()
        update_listchars(vim.opt)
    end,
})

vim.api.nvim_create_autocmd('OptionSet', {
    group = indentline_augroup,
    pattern = { 'shiftwidth', 'expandtab', 'tabstop' },
    callback = function()
        update_listchars(vim.v.option_type == 'local' and vim.opt_local or vim.opt)
    end,
})
