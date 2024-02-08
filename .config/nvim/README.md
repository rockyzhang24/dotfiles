<div align="center">

# Neovim Config

Simple but featured. Focused on ergonomics, mnemonics and consistency.

Cherry pick the lines you need and totally understand.

Always a WIP 🏗

![nvim-demo](https://user-images.githubusercontent.com/11582667/220524725-08513f05-2190-49e1-8fba-2483896fd75f.png)
  <sub>For the colorscheme, check [arctic.nvim](https://github.com/rockyzhang24/arctic.nvim). For more showcases, check [showcases](https://github.com/rockyzhang24/dotfiles/tree/master/.config/nvim#-showcases) section below.</sub>

</div>

# ✨ Features

* Beautiful colorscheme with my own [arctic.nvim](https://github.com/rockyzhang24/arctic.nvim)
* Nvim builtin LSP client configured by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* Treesitter support [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Powerful auto-completion backed by [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
* Blazing fast fuzzy finder by integrating [fzf.vim](https://github.com/junegunn/fzf.vim) and [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* Fully Git integration with [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [vim-flog](https://github.com/rbong/vim-flog), etc
* Consolidated code formatting with [conform.nvim](https://github.com/stevearc/conform.nvim)
* Modern fold with [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)
* Better quickfix window with [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf)
* Comprehensive statusline with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
* Better glance at search information with [nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens)
* Snippet engine with [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
* Smart code comment with [Comment.nvim](https://github.com/numToStr/Comment.nvim)
* Undo history visualizer with [undotree](https://github.com/mbbill/undotree)
* Improved code search via [vim-grepper](https://github.com/mhinz/vim-grepper), [vim-asterisk](https://github.com/haya14busa/vim-asterisk), etc
* Enhanced text objects with [targets.vim](https://github.com/wellle/targets.vim), etc
* File explorer with [oil.nvim](https://github.com/stevearc/oil.nvim)
* Markdown preview with [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
* ...

I'm a minimalist, adhering to the KISS principle and embracing the philosophy of "do one thing and do it better". I only install and use plugins that are absolutely essential. I dislike those all-in-one plugins. I prefer plugins that enhance the native functionality of Vim and strongly avoid those that modify Vim's original features. For functionalities that can be implemented with just a few lines of code, I prefer to implement them myself, such as [LSP progress](./lua/rockyz/lsp/progress.lua), [lightbulb](./lua/rockyz/lsp/lightbulb.lua) and [indent guide](./lua/rockyz/autocmds.lua).

To see all the plugins I am using 👉 [plugins](./viml/plugins.vim)

# 🚀 Key mappings

I assign the key mappings rationally aiming to make them efficient and easy to remember.

* Multiple leader keys

  In addition to `<Space>` that is the general leader key, `,` serves as the leader key for git, while `<BS>` functions as the leader key for toggling.

* Mnemonic

  Key bindings are organized using mnemonic prefixes like `<Leader>b` for buffer, `<Leader>f` for fuzzy finder, `<Leader>w` for window, and so forth.

* Consistent

  Similar functionalities have the same key binding throughout my dotfiles. For example, `,` and `.` for moving tabs in both kitty and Neovim.

# 🎪 Showcases

### Blazing fast fuzzy finder via [fzf.vim](https://github.com/junegunn/fzf.vim) and [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

Use `fzf` for the performance-critical operations such as files finder and grep, and `telescope` for interacting with other plugins such as [nvim-navbuddy](https://github.com/SmiteshP/nvim-navbuddy) due to its great ecosystem.

https://github.com/rockyzhang24/dotfiles/assets/11582667/9b680aba-dc77-470d-b28b-048eb995e7f0

### Ultimate fold with [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)

Now the fold is asynchronous and powered by LSP with a customizable appearance for the folded line and peek window.

https://user-images.githubusercontent.com/11582667/220818557-a136df65-aaa4-4742-908c-cf0a656df353.mp4

### Enhanced quickfix window with [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf)

Equip the quickfix with a preview window and an interactive filter (backed by `fzf`), and introduce many convenient actions for quickfix.

https://user-images.githubusercontent.com/11582667/220798455-e5463890-8176-40c1-b27b-9210451eadd8.mp4
