# neovim-12-dotfiles

A ground-up Neovim 0.12 configuration that replaces community plugins with
native functionality wherever possible.

## Why

My [previous config](https://github.com/mengano-net/neovim-dotfiles) accumulated
years of plugins to fill gaps that Neovim didn't cover natively. Neovim 0.12
ships with many of those gaps closed:

| Was a plugin | Now native |
|---|---|
| lazy.nvim / packer | `vim.pack` |
| nvim-lspconfig | `vim.lsp.config` + `vim.lsp.enable` |
| nvim-cmp | `vim.lsp.completion` |
| LuaSnip | `vim.snippet` |
| colorscheme plugins | built-in themes |

The goal of this repo is to build a clean, minimal config that leans on those
native systems — keeping third-party plugins only where there is no reasonable
native alternative.

## Requirements

- Neovim >= 0.12
- Language servers installed separately (e.g. via `mason` or system package manager)

## Structure

```
init.lua              ← entry point; require("config"), require("lsp"), etc.
lua/
  config/
    init.lua          ← loads options → keymaps → autocmds in order
    options.lua
    keymaps.lua
    autocmds.lua
  lsp/
    init.lua          ← vim.lsp.config + vim.lsp.enable per server
  plugins/            ← third-party only where no native alternative exists
```

## Installation

```bash
# Remove or back up your existing config first
git clone https://github.com/mengano-net/neovim-12-dotfiles ~/.config/nvim
nvim
```
