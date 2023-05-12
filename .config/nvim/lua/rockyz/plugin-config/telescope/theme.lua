local M = {}

local themes = require("telescope.themes")

-- Return the builtin ivy theme
function M.get_ivy(has_preview, height)
  local opts = {
    results_title = false,
    prompt_title = false,
    previewer = false,
    preview_title = "Preview",
    layout_config = {
      height = 15,
    }
  }
  if has_preview then
    opts.previewer = true
    opts.layout_config.height = 40
  end
  if height then
    opts.layout_config.height = height
  end
  return themes.get_ivy(opts)
end

return M
