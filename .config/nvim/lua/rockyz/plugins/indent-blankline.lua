require('ibl').setup({
  indent = {
    char = '▏',
    tab_char = '▏',
  },
  exclude = {
    filetypes = {
      'aerial',
      'checkhealth',
      'git',
      'help',
      'json',
      'jsonc',
      'lspinfo',
      'man',
      'minpac',
      'minpacprgs',
      'markdown',
      'NvimTree',
      'neo-tree',
      'TelescopePrompt',
      'WhichKey',
      '',
    },
    buftypes = {
      'nofile',
      'quickfix',
      'terminal',
    },
  },
})
