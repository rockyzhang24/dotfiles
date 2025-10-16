# Neovim Config

Simple but featured. Focused on ergonomics, mnemonics and consistency.

Cherry pick the lines you need and totally understand.

Always a WIP 🏗️

![demo](https://github.com/user-attachments/assets/9bfbfa4f-a108-4479-b0ff-2113e74bbddf)

↗ For more pics, please check [Showcases](#-showcases) below

# ✨ Features

I'm a minimalist, adhering to the KISS principle and embracing the philosophy of "do one thing and do it better". I only install the plugins that are absolutely essential, avoiding all-in-one solutions. I favor plugins that enhance Vim’s native functionality while steering clear of those that alter its original behavior. For features that are straightforward to implement, I prefer to create them myself, maximizing reliability and control.

Functionalities I implemented:

* Comprehensive and aesthetic statusline: [Statusline](./lua/rockyz/statusline.lua) ([showcase](#statusline-config))
* Concise LSP progress message in bottom right: [LSP progress](./lua/rockyz/lsp/progress.lua) ([showcase](#lsp-progress-message-config))
* Lightbulb with VSCode-style: [Lightbulb](./lua/rockyz/lsp/lightbulb.lua) ([showcase](#lightbulb-config))
* Minimalist indent guide built on `listchars`: [Indent guide](./lua/rockyz/indentline.lua)
* Neat indent scope display with support for motions and text objects: [Indent scope](./lua/rockyz/indentscope.lua) ([showcase](#indent-scope-config))
* Appealing winbar showing file path and diagnostics: [Winbar](./lua/rockyz/winbar.lua) ([showcase](#winbar-config))
* Elegant tabline: [Tabline](./lua/rockyz/tabline.lua) ([showcase](#tabline-config))
* Simple yet efficient statuscolumn: [Statuscolumn](./lua/rockyz/statuscolumn.lua)
* Clean and visually pleasing quickfix window: [Quickfix window](./lua/rockyz/quickfix.lua) ([showcase](#quickfix-list-config))
* Comprehensive set of lightning-fast fuzzy finders: [Fuzzy finders](./lua/rockyz/fzf.lua) ([showcase](#fuzzy-finders-config))
* Handy togglable popup for lf file manager: [lf](./lua/rockyz/lf.lua) ([showcase](#lf-file-manager-config))
* Minimal but fully featured terminal: [Terminal](./lua/rockyz/terminal.lua) ([showcase](#terminal-config))

Plugins essential to my setup:

* Treesitter support [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Ultra-fast auto-completion backed by [blink.cmp](https://github.com/Saghen/blink.cmp)
* Fully Git integration with [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [vim-flog](https://github.com/rbong/vim-flog), etc
* Consolidated code formatting via [conform.nvim](https://github.com/stevearc/conform.nvim)
* Snippet engine [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
* Undo history visualizer with [undotree](https://github.com/mbbill/undotree)
* Improved code search via [vim-grepper](https://github.com/mhinz/vim-grepper), [vim-asterisk](https://github.com/haya14busa/vim-asterisk), etc
* Enhanced text objects with [targets.vim](https://github.com/wellle/targets.vim), etc
* Symbol outline and tags with [outline.nvim](https://github.com/hedyhli/outline.nvim) and [tagbar](https://github.com/preservim/tagbar)

I use the built-in plugin manager `vim.pack` to manage my plugins. Check out the list of plugins I use [here](./lua/rockyz/plugins.lua) and their configs [here](./plugin/).

# 🚀 Key mappings

I assign the key mappings rationally aiming to make them efficient and easy to remember.

* Multiple leader keys

  Besides using `<Space>` as the primary leader key, `,` serves as the leader key for Git-related keymaps, and `\` is designated for toggling.

* Mnemonic

  Key bindings are organized using mnemonic prefixes like `<Leader>b` for buffer, `<Leader>f` for fuzzy finder, `<Leader>w` for window, and so forth.

* Consistent

  Similar functionalities have the same key binding throughout my dotfiles. For example, `,` and `.` for moving tabs in both kitty and Neovim.

# 🎪 Showcases

### Fuzzy finders ([config](./lua/rockyz/fzf.lua))

I implemented a series of fuzzy finders based on fzf.vim instead of using ready-made fuzzy finder plugins because I find them bloated and slower in extreme environments. Additionally, I prefer full control and not having to worry about essential plugins becoming unmaintained.

![fuzzy-finders](https://github.com/user-attachments/assets/0459ae54-b0bd-4187-8760-d19f5fc1731c)

### LSP progress message ([config](./lua/rockyz/lsp/progress.lua))

![lsp-progress](https://github.com/user-attachments/assets/63f5fa48-cefe-4d32-9d8d-806418c066a2)

### Statusline ([config](./lua/rockyz/statusline.lua))

![statusline](https://github.com/user-attachments/assets/bb20a33d-a7f6-4bf8-90ab-772eb721dcf8)

### Winbar ([config](./lua/rockyz/winbar.lua))

![winbar](https://github.com/user-attachments/assets/2c9055c4-f7ed-4086-9bf9-603a160121c8)

### Tabline ([config](./lua/rockyz/tabline.lua))

![tabline](https://github.com/user-attachments/assets/9b62713f-62f7-4ca2-870c-738539c06357)

### Indent scope ([config](./lua/rockyz/indentscope.lua))

![indentscope](https://github.com/user-attachments/assets/5732405e-d5fe-4d2d-a36f-fbc7d27f4747)

### Lightbulb ([config](./lua/rockyz/lsp/lightbulb.lua))

![lightbulb](https://github.com/user-attachments/assets/882c0ddc-0f29-4844-b4dd-a243d8a4009d)

### Quickfix list ([config](./lua/rockyz/quickfix.lua))

![quickfix](https://github.com/user-attachments/assets/7c3446d4-3fb1-47ad-a1c5-c96b06a999a3)

### lf file manager ([config](./lua/rockyz/lf.lua))

![lf](https://github.com/user-attachments/assets/b4055211-d0c4-4422-82b6-c447fb0d5902)

### Terminal ([config](./lua/rockyz/terminal.lua))

https://github.com/user-attachments/assets/37acb4f1-002c-418f-8c01-d2c5ecb44626
