-- Neovim's `fillchars` option supports the `foldinner` value since 2025-10-05 (commit:
-- https://github.com/neovim/neovim/commit/b6b80824cc71fb9f32ddf2e9a96205633342827e).
--
-- Therefore, this implementation does not need to hide numeric fold levels.
--
-- Inspired by luukvbaal/statuscol.nvim

local ffi = require('ffi')
ffi.cdef([[
    typedef struct {} Error;
    typedef struct {} win_T; // Structure which contains all information that belongs to a window
    typedef struct {
        int start;  // line number where deepest fold starts
        int level;  // fold level, when zero other fields are N/A
        int llevel; // lowest level that starts in v:lnum
        int lines;  // number of lines from v:lnum to end of closed fold
    } foldinfo_T;
    foldinfo_T fold_info(win_T* wp, int lnum);
    win_T *find_window_by_handle(int Window, Error *err);
    int compute_foldcolumn(win_T *wp, int col); // compute the width of the foldcolumn
]])

local ffi_error = ffi.new('Error')
local fillchars = vim.opt_local.fillchars:get()

---@class rockyz.StatuscolumnFold
---@field close string
---@field open string
---@field sep string
---@field width integer

---@class rockyz.StatuscolumnArgs
---@field winid integer
---@field window_ptr ffi.cdata*
---@field fold rockyz.StatuscolumnFold
---@field lnum integer
---@field relnum integer
---@field virtnum integer

---@type table<integer, rockyz.StatuscolumnArgs>
local args_by_winid = {}

---Get an args table that will be passed into foldfunc(). The args table is per window and cached in
---args_by_winid indexed by winid. The structure of the args table shown below:
---
---{
---    winid,
---    window_ptr, -- pointer to win_T
---    fold = {
---        close,
---        open,
---        sep,
---        width,
---    },
---    lnum,
---    relnum,
---    virtnum,
---}
---
---@return rockyz.StatuscolumnArgs
local function get_statuscolumn_args()
    local winid = vim.g.statusline_winid
    local args = args_by_winid[winid]

    if not args then
        args = {
            winid = winid,
            window_ptr = ffi.C.find_window_by_handle(winid, ffi_error),
            fold = {
                close = fillchars.foldclose,
                open = fillchars.foldopen,
                sep = fillchars.foldsep,
                width = 0,
            },
        }
        args_by_winid[winid] = args
    end

    args.lnum = vim.v.lnum
    args.relnum = vim.v.relnum
    args.virtnum = vim.v.virtnum
    args.fold.width = ffi.C.compute_foldcolumn(args.window_ptr, 0)

    return args
end

local statuscolumn_augroup = vim.api.nvim_create_augroup('rockyz.statuscolumn_reference', { clear = true })

vim.api.nvim_create_autocmd('WinClosed', {
    group = statuscolumn_augroup,
    callback = function(event)
        args_by_winid[tonumber(event.match)] = nil
    end,
})

---Return the string that will be displayed in foldcolumn
---Reference luukvbaal/statuscol.nvim's builtin.foldfunc
---@param args rockyz.StatuscolumnArgs
---@return string
local function foldfunc(args)
    local width = args.fold.width
    if width == 0 then
        return ''
    end

    local fold_info = ffi.C.fold_info(args.window_ptr, args.lnum)
    local level = fold_info.level
    if level == 0 then
        return (' '):rep(width)
    end

    local is_closed = fold_info.lines > 0
    local first_level = math.max(level - width - (is_closed and 1 or 0) + 1, 1)
    local column_count = math.min(level, width)
    local parts = {}

    local fold_highlight = args.relnum == 0 and '%#CursorLineFold#' or '%#FoldColumn#'
    local open = fold_highlight .. args.fold.open .. '%*'
    local close = fold_highlight .. args.fold.close .. '%*'
    local separator = '%#FoldColumn#' .. args.fold.sep .. '%*'

    for column = 1, column_count do
        if args.virtnum ~= 0 then
            parts[#parts + 1] = separator
        elseif is_closed and (column == level or column == width) then
            parts[#parts + 1] = close
        elseif fold_info.start == args.lnum and first_level + column > fold_info.llevel then
            parts[#parts + 1] = open
        else
            parts[#parts + 1] = separator
        end
    end

    if column_count < width then
        parts[#parts + 1] = (' '):rep(width - column_count)
    end

    return table.concat(parts)
end

---Return line number
---@param args rockyz.StatuscolumnArgs
---@return string
local function lnumfunc(args)
    return args.virtnum ~= 0 and '%=' or '%l'
end

---@return string
function _G.statuscolumn()
    local args = get_statuscolumn_args()
    return lnumfunc(args) .. '%s' .. foldfunc(args) .. ' '
end

-- statuscolumn is local to window, so here both "%{% ... %}" and "%! ... " work (as for their
-- difference, see :h statusline). I use the latter because the vim.g.statusline_winid variable will
-- be available to use (see :h g:statusline_winid).
vim.o.statuscolumn = '%!v:lua.statuscolumn()'
