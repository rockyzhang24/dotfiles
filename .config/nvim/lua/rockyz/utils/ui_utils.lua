local M = {}

---Show a prompt and execute the handler upon y/Y
---@param prompt string
---@param on_yes function
function M.input_yes(prompt, on_yes)
    vim.ui.input({ prompt = prompt }, function(input)
        if input and input:lower() == 'y' then
            on_yes()
        end
    end)
end

return M
