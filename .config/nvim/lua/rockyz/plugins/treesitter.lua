require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'cmake',
    'css',
    'go',
    'gomod',
    'gowork',
    'html',
    'java',
    'javascript',
    'json',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'ruby',
    'rust',
    'scss',
    'sql',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
  },
  ignore_install = {},
  highlight = {
    enable = true,
    -- Disable highlight for large files
    disable = function(lang, buf)
      local max_filesize = 1000 * 1024 -- 1000 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<Enter>',
      node_incremental = '<Enter>',
      node_decremental = '<Backspace>',
    },
  },
})
