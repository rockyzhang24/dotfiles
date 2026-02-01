# Neovim Config

Simple but featured. Focused on ergonomics, mnemonics and consistency.

Cherry pick the lines you need and totally understand.

Always a WIP 🏗️

![demo](https://github.com/user-attachments/assets/9bfbfa4f-a108-4479-b0ff-2113e74bbddf)

↗ For more pics, please check [Showcases](#-showcases) below

# ✨ Features

I'm a minimalist, adhering to the KISS principle and embracing the philosophy of "do one thing and do it well". I only install the plugins that are absolutely essential, avoiding all-in-one solutions, and favor plugins that enhance Vim’s native capabilities while steering clear of those that alter its original behavior. For features that are straightforward to implement, I prefer to build them myself, prioritizing reliability, clarity and full control.

Functionalities I implemented:

* Feature-rich and aesthetic statusline: [Statusline](./lua/rockyz/statusline.lua) ([showcase](#statusline-config))
* Concise LSP progress message in the bottom right: [LSP progress](./lua/rockyz/lsp/progress.lua) ([showcase](#lsp-progress-message-config))
* Subtle LSP lightbulb indicator for code actions: [Lightbulb](./lua/rockyz/lsp/lightbulb.lua) ([showcase](#lightbulb-config))
* Versatile outline sidebar with LSP, Ctags and man providers, plus fzf-based filtering: [Outline](./lua/rockyz/outline.lua) ([showcase](#outline-config))
* Minimalist indent guide using `listchars`: [Indent guide](./lua/rockyz/indentline.lua)
* Neat indent scope display with motions and text objects support: [Indent scope](./lua/rockyz/indentscope.lua) ([showcase](#indent-scope-config))
* Appealing winbar with file path and diagnostics: [Winbar](./lua/rockyz/winbar.lua) ([showcase](#winbar-config))
* Elegant scrollable tabline: [Tabline](./lua/rockyz/tabline.lua) ([showcase](#tabline-config))
* Simple yet efficient statuscolumn: [Statuscolumn](./lua/rockyz/statuscolumn.lua)
* Clean and visually pleasing quickfix window: [Quickfix window](./lua/rockyz/quickfix.lua) ([showcase](#quickfix-list-config))
* Extensive set of lightning-fast fuzzy finders: [Fuzzy finders](./lua/rockyz/fzf.lua) ([showcase](#fuzzy-finders-config))
* Handy togglable popup for lf file manager: [lf](./lua/rockyz/lf.lua) ([showcase](#lf-file-manager-config))
* Minimal but fully featured terminal: [Terminal](./lua/rockyz/terminal.lua) ([showcase](#terminal-config))
* High-performance scrollbar with diagnostics, git and search integration: [Scrollbar](./lua/rockyz/scrollbar.lua) ([showcase](#scrollbar-config))

Plugins essential to my setup:

* Treesitter support via [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
* Ultra-fast auto-completion powered by [blink.cmp](https://github.com/Saghen/blink.cmp)
* Full Git integration with [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [vim-flog](https://github.com/rbong/vim-flog), etc
* Consolidated code formatting via [conform.nvim](https://github.com/stevearc/conform.nvim)
* Snippet engine powered by [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
* Undo history visualizer with [undotree](https://github.com/mbbill/undotree)
* Improved code search via [vim-grepper](https://github.com/mhinz/vim-grepper), [vim-asterisk](https://github.com/haya14busa/vim-asterisk), etc
* Enhanced text objects with [targets.vim](https://github.com/wellle/targets.vim), etc

I use the built-in plugin manager `vim.pack` to manage my plugins.

See the full list of plugins [here](./lua/rockyz/plugins.lua) and their configurations [here](./plugin/).

# 🚀 Key mappings

I assign key mappings deliberately, aiming for efficiency and ease of recall.

* Multiple leader keys

  In addition to using `<Space>` as the primary leader key, `,` serves as the leader key for Git-related keymaps, while `\` is designated for toggles.

* Mnemonic

  Key bindings are organized using mnemonic prefixes like `<Leader>b` for buffer, `<Leader>f` for fuzzy finder, `<Leader>w` for window, and so on.

* Consistent

  Similar functionalities share the same key bindings across my dotfiles. For example, `,` and `.` are used for moving tabs in both Kitty and Neovim.

# 🎪 Showcases

### Fuzzy finders ([config](./lua/rockyz/fzf.lua))

I implemented a set of fuzzy finders built around `fzf`, instead of relying on full-fledged fuzzy finder plugins.

This approach keeps the implementation lightweight, predictable, and fully under my control, while remaining responsive even in constrained environments.

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

Supports creating, deleting, and renaming terminals.

Terminals can be moved into their own tabpages and later restored back to the panel.

It also supports opening filetype-specific REPLs, sending selected lines for execution, and running the current file directly in a terminal.

https://github.com/user-attachments/assets/37acb4f1-002c-418f-8c01-d2c5ecb44626

### Scrollbar ([config](./lua/rockyz/scrollbar.lua))

![scrollbar](https://github.com/user-attachments/assets/40402934-1849-47e1-96b7-caacd28a092d)

### Outline ([config](./lua/rockyz/outline.lua))

Provides a toggleable outline sidebar for structural navigation.

Supports multiple providers, including LSP, Ctags and man (for man page specifically).

Symbols can be interactively filtered by kind using fzf.

![outline](https://github.com/user-attachments/assets/5caf9204-fb46-49aa-80d6-c729a017adcc)
