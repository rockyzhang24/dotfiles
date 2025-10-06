-- UPDATE (10/5/2025): Since the commit
-- https://github.com/neovim/neovim/commit/b6b80824cc71fb9f32ddf2e9a96205633342827e that added
-- "foldinner" suboption value to the "fillchars" option, we don't need the foldfunc below to
-- remove numeric foldlevel, and instead we just need to set foldinner to whitespace.

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

local error = ffi.new('Error')
local fillchars = vim.opt_local.fillchars:get()
local callargs = {}

-- Get an args table that will be passed into foldfunc(). The args table is per window and cached in
-- callargs indexed by winid. The structure of the args table shown below:
--
-- {
--     win,
--     wp, -- pointer to win_T
--     fold = {
--         close,
--         open,
--         sep,
--         width,
--     },
--     lnum,
--     relnum,
--     virtnum,
--     cursorline,
-- }
--
local function get_args()
    local win = vim.g.statusline_winid
    local args = callargs[win]
    if not args then
        args = {
            win = win,
            wp = ffi.C.find_window_by_handle(win, error),
            fold = {
                close = fillchars.foldclose,
                open = fillchars.foldopen,
                sep = fillchars.foldsep,
            },
        }
        callargs[win] = args
    end
    args.lnum = vim.v.lnum
    args.relnum = vim.v.relnum
    args.virtnum = vim.v.virtnum
    args.fold.width = ffi.C.compute_foldcolumn(args.wp, 0)
    return args
end

-- Return the string that will be displayed in foldcolumn
-- Reference luukvbaal/statuscol.nvim's builtin.foldfunc
local function foldfunc(args)
    local width = args.fold.width
    if width == 0 then
        return ''
    end
    local foldinfo = ffi.C.fold_info(args.wp, args.lnum)
    -- local string = args.cursorline and args.relnum == 0 and '%#CursorLineFold#' or '%#FoldColumn#'
    local level = foldinfo.level
    if level == 0 then
        return (' '):rep(width)
    end
    local closed = foldinfo.lines > 0
    local first_level = level - width - (closed and 1 or 0) + 1
    if first_level < 1 then
        first_level = 1
    end
    -- For each column, add a foldopen, foldclose, foldsep or padding char
    local range = level < width and level or width
    local string = ''
    -- Highlight the foldopen icon and foldclose icon on the current line
    local open = (args.relnum == 0 and '%#CursorLineFold#' or '%#FoldColumn#') .. args.fold.open .. '%*'
    local close = (args.relnum == 0 and '%#CursorLineFold#' or '%#FoldColumn#') .. args.fold.close .. '%*'
    local sep = '%#FoldColumn#' .. args.fold.sep .. '%*'
    for col = 1, range do
        if args.virtnum ~= 0 then
            string = string .. sep
        elseif closed and (col == level or col == width) then
            string = string .. close
        elseif foldinfo.start == args.lnum and first_level + col > foldinfo.llevel then
            string = string .. open
        else
            string = string .. sep
        end
    end
    if range < width then
        string = string .. (' '):rep(width - range)
    end
    return string
end

-- Return line number
local function lnumfunc(args)
    if args.virtnum ~= 0 then
        return '%='
    end
    return '%l'
end

function _G.statuscolumn()
    local args = get_args()
    local fold = foldfunc(args)
    local lnum = lnumfunc(args)
    return lnum .. '%s' .. fold .. ' '
end

-- statuscolumn is local to window, so here both "%{% ... %}" and "%! ... " work (as for their
-- difference, see :h statusline). I use the latter because the vim.g.statusline_winid variable will
-- be available to use (see :h g:statusline_winid).
vim.o.statuscolumn = '%!v:lua.statuscolumn()'
