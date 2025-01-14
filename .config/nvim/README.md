<div align="center">

# Neovim Config

Simple but featured. Focused on ergonomics, mnemonics and consistency.

Cherry pick the lines you need and totally understand.

Always a WIP 🏗️

<img width="1774" alt="nvim-demo" src="https://github.com/user-attachments/assets/9bfbfa4f-a108-4479-b0ff-2113e74bbddf">

</div>

# ✨ Features

I'm a minimalist, adhering to the KISS principle and embracing the philosophy of "do one thing and do it better". I only install the plugins that are absolutely essential, avoiding all-in-one solutions. I favor plugins that enhance Vim’s native functionality while steering clear of those that alter its original behavior. For features that are straightforward to implement, I prefer to create them myself, maximizing reliability and control.

Functionalities I implemented:

* Comprehensive and aesthetic statusline: [Statusline](./lua/rockyz/statusline.lua)
* Concise LSP progress message in bottom right: [LSP progress](./lua/rockyz/lsp/progress.lua)
* Lightbulb with VSCode-style: [Lightbulb](./lua/rockyz/lsp/lightbulb.lua)
* Minimalist indent guide built on `listchars`: [Indent guide](./lua/rockyz/indentline.lua)
* Neat indent scope display with support for motions and text objects: [Indent scope](./lua/rockyz/indentscope.lua)
* Appealing winbar showing file path, diagnostics and breadcrumbss: [Winbar](./lua/rockyz/winbar.lua)
* Elegant tabline: [Tabline](./lua/rockyz/tabline.lua)
* Simple yet efficient statuscolumn: [Statuscolumn](./lua/rockyz/statuscolumn.lua)
* Clean and visually pleasing quickfix window: [Quickfix window](./lua/rockyz/quickfix.lua)
* Comprehensive set of lightning-fast fuzzy finders built on fzf.vim: [Fuzzy finders](./plugin/fzf.lua)

Plugins essential to my setup:

* Minimal plugin manager [minpac](https://github.com/k-takata/minpac)
* Nvim builtin LSP client configured by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* Treesitter support [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Ultra-fast auto-completion backed by [blink.cmp](https://github.com/Saghen/blink.cmp)
* Fully Git integration with [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [vim-flog](https://github.com/rbong/vim-flog), etc
* Consolidated code formatting via [conform.nvim](https://github.com/stevearc/conform.nvim)
* Snippet engine [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
* Undo history visualizer with [undotree](https://github.com/mbbill/undotree)
* Improved code search via [vim-grepper](https://github.com/mhinz/vim-grepper), [vim-asterisk](https://github.com/haya14busa/vim-asterisk), etc
* Enhanced text objects with [targets.vim](https://github.com/wellle/targets.vim), etc
* Symbol outline and tags with [aerial.nvim](https://github.com/stevearc/aerial.nvim) and [tagbar](https://github.com/preservim/tagbar)

To see all the plugins I am using 👉 [my plugins](./lua/rockyz/minpac.lua) and their configs 👉 [plugin configs](./plugin/)

# 🚀 Key mappings

I assign the key mappings rationally aiming to make them efficient and easy to remember.

* Multiple leader keys

  In addition to `<Space>` that is the general leader key, `,` serves as the leader key for git, while `yo` for toggling.

* Mnemonic

  Key bindings are organized using mnemonic prefixes like `<Leader>b` for buffer, `<Leader>f` for fuzzy finder, `<Leader>w` for window, and so forth.

* Consistent

  Similar functionalities have the same key binding throughout my dotfiles. For example, `,` and `.` for moving tabs in both kitty and Neovim.

# 🎪 Showcases

### Fuzzy finders

I implemented a series of fuzzy finders based on fzf.vim instead of using ready-made fuzzy finder plugins because I find them bloated and slower in extreme environments. Additionally, I prefer full control and not having to worry about essential plugins becoming unmaintained.

![fuzzy-finders](https://github.com/user-attachments/assets/0459ae54-b0bd-4187-8760-d19f5fc1731c)

### LSP progress message

![lsp-progress](https://github.com/user-attachments/assets/63f5fa48-cefe-4d32-9d8d-806418c066a2)

### Lightbulb

I use a lightning icon instead of a bulb.

![lightbulb](https://github.com/user-attachments/assets/882c0ddc-0f29-4844-b4dd-a243d8a4009d)

### Quickfix list

<img width="1774" alt="quickfix" src="https://github.com/user-attachments/assets/5084ffd3-ab23-46c0-abe8-a7960b5ae455">
