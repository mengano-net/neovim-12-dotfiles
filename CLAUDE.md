# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This is a **ground-up Neovim 0.12 configuration** built to replace the prior
plugin-heavy setup at
[mengano-net/neovim-dotfiles](https://github.com/mengano-net/neovim-dotfiles).
The driving constraint is: **prefer native Neovim 0.12 functionality over
community plugins wherever possible.**

Key native features in 0.12 to leverage (and prefer over plugins):

- **`vim.pack`** — built-in package/plugin manager (replaces lazy.nvim, packer, etc.)
- **Native LSP** (`vim.lsp`) — replaces nvim-lspconfig as the orchestration layer
- **Native completion** (`vim.lsp.completion`) — replaces nvim-cmp
- **Native color themes** — replaces theme plugins for built-in colorschemes
- **`vim.snippet`** — built-in snippet engine (replaces LuaSnip)
- **`vim.iter`**, **`vim.fs`**, **`vim.system`** — stdlib utilities to use over external libs

## Repository Layout (target structure)

```
~/.config/nvim/          ← or stowed here from this repo
├── init.lua             ← entry point; calls require("config"), require("lsp"), etc.
└── lua/
    ├── config/
    │   ├── init.lua     ← requires options, keymaps, autocmds in order
    │   ├── options.lua
    │   ├── keymaps.lua
    │   └── autocmds.lua
    ├── lsp/             ← LSP server configs using vim.lsp directly
    │   └── init.lua
    └── plugins/         ← only plugins that have NO native replacement
        └── <plugin>.lua
```

**Module loading pattern:** `init.lua` calls `require("config")`, which
delegates to `lua/config/init.lua`. That file is responsible for requiring
`options`, `keymaps`, and `autocmds` in the correct order. Same pattern for
`lsp/` and `plugins/`. This keeps the top-level `init.lua` minimal and each
domain self-contained.

The `lua/config/` layer must never require a plugin. The `lua/lsp/` layer uses `vim.lsp.config` and `vim.lsp.enable` (0.12 API), not nvim-lspconfig.

## Installation

The repo is cloned **directly** into `~/.config/nvim` — no symlinks, no `NVIM_APPNAME`:

```bash
git clone https://github.com/mengano-net/neovim-12-dotfiles ~/.config/nvim
nvim
```

Do not use `nvim -u` or `NVIM_APPNAME` — both cause `require()` to fail because
Neovim won't add `lua/` to the runtimepath correctly. Cloning into `~/.config/nvim`
is the only supported setup.

## How to Validate

```bash
# Check for startup errors after editing config
:messages

# Inspect loaded packages at runtime
:lua vim.print(vim.pack.list())

# Check LSP status for the current buffer
:checkhealth lsp
:lua vim.print(vim.lsp.get_clients())

# Verify which config directory is active
:lua print(vim.fn.stdpath("config"))
```

## Current State (as of last session)

- `lua/config/options.lua` — complete
- `lua/config/keymaps.lua` — terminal mode only (`jk`, `<Esc>` to exit terminal insert mode); full keymap migration from prior config not yet done
- `lua/config/autocmds.lua` — complete (winbar, yank highlight, git, markdown/tex, terminal, plantuml, netrw)
- `lua/config/statusline.lua` — complete; replaces lualine; git diff counts pending gitsigns verification
- `lua/lsp/` — not started
- `lua/plugins/` — in progress:
  - `tokyonight`, `treesitter`, `which-key`, `mason`, `lint`, `conform` — complete
  - `gitsigns` — installed; keymaps in `on_attach`; statusline diff wiring pending
  - Telescope, terminal plugin, additional git tooling — not yet added

## Hard Constraints

- **No patched-font characters** — do not use Nerd Font glyphs or Unicode characters that require special font rendering (e.g. `↳`, `↴`, powerline symbols, devicons). This config must render correctly on SSH targets with default terminal fonts. Use plain ASCII for UI decorators (`>`, `--`, `|`, etc.).
- **netrw is intentionally enabled** — it serves as the native file browser (`:Ex`, `:Vex`, `:Sex`). Do not disable it or add a file explorer plugin without explicit instruction.

## Key Conventions

- **No plugin manager plugin** — use `vim.pack` (`:help vim.pack`)
- **No nvim-lspconfig** — configure servers with `vim.lsp.config('server', { ... })` and enable with `vim.lsp.enable('server')`
- **No nvim-cmp** — use `vim.lsp.completion.enable(true, client_id, bufnr)` or the built-in `completefunc`
- **Keymaps** are split by concern: general keymaps in `lua/config/keymaps.lua`; plugin-specific keymaps co-located in `lua/plugins/<plugin>.lua`; LSP keymaps inside the `LspAttach` autocmd in `lua/lsp/`
- **Options** follow `:help option-list`; use `vim.opt` not `vim.o` for table-valued options
- **Autocommands** use `vim.api.nvim_create_autocmd` with named `augroup`s to prevent duplication on re-source

## Reference

- Neovim 0.12 release notes: <https://github.com/neovim/neovim/releases/tag/v0.12.0>
- Prior config (for reference/migration): <https://github.com/mengano-net/neovim-dotfiles>
