require('nvim-treesitter.configs').setup {

  ensure_installed = {
    "bash",
    "c", "cpp", "cmake", "css",
    "go", "gomod", "gowork",
    "html",
    "java", "javascript", "json",
    "lua",
    "make", "markdown", "markdown_inline",
    "python",
    "query",
    "ruby", "rust",
    "scss", "sql",
    "toml", "tsx", "typescript",
    "vim", "vimdoc",
    "yaml",
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
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]a"] = "@parameter.inner",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[a"] = "@parameter.inner",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
      },
    },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Enter>",
      node_incremental = "<Enter>",
      node_decremental = "<Backspace>",
    },
  },

  -- nvim-ts-context-commentstring
  context_commentstring = {
    enable = true,
  },
  -- nvim-treesitter/playground
  playground = {
    enable = true,
  },
  -- vim-matchup
  matchup = {
    enable = true,
    disable_virtual_text = true,
  }
}
