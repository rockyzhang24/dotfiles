local system = require('rockyz.utils.system')
local notify = require('rockyz.utils.notify')

local opts = {
    buffer = true,
    silent = true,
}

-- Align the markdown table when typing |
vim.keymap.set('i', '<Bar>', "<Bar><Esc>:lua require('rockyz.utils.misc').md_table_bar_align()<CR>a", opts)

local function open_preview(file)
    -- Applescript to open Marked 2 and arrange it side by side with terminal
    local pin_and_move_right = [[
    if not (exists application "Marked 2") then
        return
    end
    -- (1). Save frontmost terminal app
    tell application "System Events"
        set terminalApp to name of first application process whose frontmost is true
    end tell
    -- (2). Move terminal to the right half
    tell application "System Events"
        tell process terminalApp
            click menu item "Right" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
    -- (3). Open the markdown file in Marked 2
    tell application "Marked 2"
        open POSIX file "]] .. file .. [["
        activate
    end tell
    delay 0.5
    -- (4). Move Marked 2 to the left half
    tell application "System Events"
        tell process "Marked 2"
            set frontmost to true
            delay 0.3
            click menu item "Left" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
    -- (5). Refocus terminal
    tell application terminalApp to activate
    ]]

    local obj = system.sync({
        'osascript',
        '-e',
        pin_and_move_right,
    })
    if obj.stderr:find('Can’t get application "Marked 2"') then
        notify.warn('Marked 2 is not installed')
    end
end

-- Open preview
vim.keymap.set('n', '<Leader>v', function()
    if vim.uv.os_uname().sysname == 'Darwin' then
        local bufname = vim.api.nvim_buf_get_name(0)
        open_preview(bufname)
    end
end, opts)
