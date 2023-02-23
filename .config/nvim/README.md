<div align="center">

# Neovim Config

Simple but featured. Focused on ergonomics, mnemonics and consistency.

Cherry pick the lines you need and totally understand.

Always a WIP 🏗

![nvim-demo](https://user-images.githubusercontent.com/11582667/220524725-08513f05-2190-49e1-8fba-2483896fd75f.png)
  <sub>For the colorscheme, check [arctic.nvim](https://github.com/rockyzhang24/arctic.nvim). For more showcases, check [showcases](https://github.com/rockyzhang24/dotfiles/tree/master/.config/nvim#showcases) section below.</sub>

</div>

# ✨ Features

* Beautiful colorscheme with my own [arctic.nvim](https://github.com/rockyzhang24/arctic.nvim)
* Nvim builtin LSP client configured by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* Enhanced code formatting and linting with [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim)
* Powerful auto-completion backed by [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
* Fuzzy finder for everything with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* Modern fold with [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)
* Better quickfix window with [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf)
* Fully Git integration with [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [vim-flog](https://github.com/rbong/vim-flog), etc
* Treesitter support [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Blazing fast statusline with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
* Better glance at search information with [nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens)
* Snippet engine with [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
* Smart code comment with [Comment.nvim](https://github.com/numToStr/Comment.nvim)
* Undo history visualizer with [undotree](https://github.com/mbbill/undotree)
* Indentation guide with [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
* Improved code search via [vim-grepper](https://github.com/mhinz/vim-grepper), [vim-asterisk](https://github.com/haya14busa/vim-asterisk), etc
* Comprehensive text objects with [vim-after-object](https://github.com/junegunn/vim-after-object), [targets.vim](https://github.com/wellle/targets.vim), etc
* Markdown preview with [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
* ...

To see all the plugins I am using 👉 [plugins](./.config/nvim/viml/plugins.vim)

# 🚀 Key mappings

I assign the key mappings rationally aiming to make them efficient and easy to remember.

* Multiple leader keys

  In addition to `<Space>` that is the general leader key, `<BS>` and `,` are set as the leader keys for toggling and LSP respectively.

* Mnemonic

  Key bindings are organized using mnemonic prefixes like `<Leader>b` for buffer, `<Leader>f` for fuzzy finder, `<Leader>w` for window, etc.
  
* Consistent

  Similar functionalities have the same key binding throughout my dotfiles. For example, `,` and `.` for moving tabs in both kitty and Neovim.

# 🎪 Showcases

### Ultimate fold with [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)

Now the fold is asynchronous and powered by LSP with a customizable appearance for the folded line and peek window.

https://user-images.githubusercontent.com/11582667/220818557-a136df65-aaa4-4742-908c-cf0a656df353.mp4

### Enhanced quickfix window with [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf)

Equip the quickfix with a preview window and an interactive filter (backed by `fzf`), and introduce many convenient actions for quickfix

https://user-images.githubusercontent.com/11582667/220798455-e5463890-8176-40c1-b27b-9210451eadd8.mp4

### All-in-one Fuzzy Finder via [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Fuzzy finder over lists of files, buffers, search results, git commits, etc.

https://user-images.githubusercontent.com/11582667/220837891-f23ada38-c7d9-447f-a28b-e092d40b111b.mp4
