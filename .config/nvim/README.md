<div align="center">

# Neovim Config

Simple but featured. Focused on ergonomics, mnemonics and consistency.

Cherry pick the lines you need and totally understand.

Always a WIP 🏗

<img width="1774" alt="image" src="https://user-images.githubusercontent.com/11582667/178826407-5dbc50eb-46a5-4fd5-9dfb-40ebfa6ba0fd.png">

</div>

# Features

* Nvim builtin LSP client ([nvim-lspconfig](https://github.com/neovim/nvim-lspconfig))
* Powerful completion backed by [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
* Fuzzy finder for everything via [telescope](https://github.com/nvim-telescope/telescope.nvim)
* Enhanced quickfix ([nvim-bqf](https://github.com/kevinhwang91/nvim-bqf))
* Modern fold ([nvim-ufo](https://github.com/kevinhwang91/nvim-ufo))
* Comprehensive text objects
* Treesitter support
* Well organized key mappings (see next section below)
* Snippet support powered by [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
* Fully Git integration
* Many essential plugins to boost productivity

# Key mappings

I assign the key mappings rationally aiming to make them efficient and easy to remember.

* Multiple leader keys

  In addition to `<Space>` that is the general leader key, `\` and `,` are set as the leader keys for toggling and LSP respectively.

* Mnemonic

  Key bindings are organized using mnemonic prefixes like `<Leader>b` for buffer, `<Leader>f` for fuzzy finder, `<Leader>w` for window, etc.

* Consistent

  Similar functionalities have the same key binding throughout my dotfiles. For example, `,` and `.` for moving tabs in both kitty and Neovim.
