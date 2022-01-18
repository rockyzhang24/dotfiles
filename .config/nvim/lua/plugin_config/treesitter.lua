require'nvim-treesitter.configs'.setup {

  -- nvim-treesitter config

  ensure_installed = "maintained",
  ignore_install = {},  -- List of parsers to ignore installing

  -- Modules

  highlight = {
    enable = true,
    disable = {"vim", }  -- List of language that will be disabled
  },
}
