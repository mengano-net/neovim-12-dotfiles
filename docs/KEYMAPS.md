# Keymap reference

Leader is **`<Space>`** (local leader is also `<Space>`). Press `<Space>` and
pause to see these live in which-key; `<leader>?` shows buffer-local maps only.

Where each map is defined is noted in brackets so you can find and change it.

## General [lua/config/keymaps.lua, lua/plugins/which-key.lua]

| Mode | Key | Action |
| --- | --- | --- |
| i | `jk` | Exit insert mode |
| i | `,` `.` `!` `?` | Insert the character and set an undo breakpoint |
| n | `x` | Delete char without yanking |
| n | `<leader>p` | Paste from yank register (`"0p`) |
| n | `<leader>w` | Write buffer (`:w!`) |
| n | `<leader>x` | Close buffer (`:bd!`) |
| n | `<Tab>` / `<S-Tab>` | Next / previous buffer |
| n | `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move to left / lower / upper / right window |
| n | `<leader>sv` / `<leader>sh` | New vertical / horizontal split |
| n | `n` / `N` | Next / previous search result, centered |
| n | `<leader>nh` | Clear search highlight |
| n | `J` | Join lines, keep cursor position |
| v | `<leader>Er` | Replace all occurrences of selection (prompts on cmdline) |
| v | `<` / `>` | Indent, keep selection |
| v | `J` / `K` | Move selected block down / up |
| n | `<leader>?` | Show buffer-local keymaps (which-key) |

## File explorer -- netrw [lua/config/keymaps.lua, lua/config/autocmds.lua]

| Mode | Key | Action |
| --- | --- | --- |
| n | `<leader>ee` | Toggle left explorer; tree expansion and cursor are preserved |
| n (netrw) | `<leader>eR` | Refresh tree |
| n (netrw) | `<leader>eh` | Toggle hidden files |

Inside netrw you can also use its own keys: `<CR>` open, `%` new file, `d` new
dir, `D` delete, `R` rename, `-` up a directory. See `:help netrw-quickmap`.
The explorer closes itself when you open a file.

## Find -- fzf-lua [lua/plugins/fzf-lua.lua]

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files (git files inside a repo, otherwise all files) |
| `<leader>fs` | Live grep (ripgrep) |
| `<leader>fc` | Grep word under cursor |
| `<leader>fb` | Fuzzy search lines in current buffer |
| `<leader>fr` | Recent files |
| `<leader>fj` | Jump list |
| `<leader>bl` | List buffers |
| `<leader>vt` | Help tags |
| `<leader>vc` | Commands |

Inside a picker: `<C-q>` sends all results to the quickfix list.

## LSP (only when a server is attached) [lua/lsp/init.lua, lua/plugins/fzf-lua.lua]

| Key | Action |
| --- | --- |
| `K` | Hover documentation |
| `<leader>lk` | Signature help |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code actions |
| `<leader>gd` | Go to definition |
| `<leader>gr` | Go to references |
| `<leader>gi` | Implementations (fzf picker) |
| `<leader>ls` | Document symbols (fzf picker) |
| `<leader>lt` | Type definitions (fzf picker) |

`<leader>gd` and `<leader>gr` are mapped twice, once by fzf-lua and once by
`lua/lsp/init.lua`. The `lua/lsp` version is registered last, so the native
`vim.lsp.buf.definition` / `references` win (references open in the quickfix
list, not in fzf).

Completion is native and opens automatically: `<C-n>` / `<C-p>` to move,
`<C-y>` to accept, `<C-e>` to dismiss.

## Diagnostics [lua/plugins/which-key.lua]

| Key | Action |
| --- | --- |
| `<leader>gj` | Next diagnostic, with float |
| `<leader>gk` | Previous diagnostic, with float |
| `<leader>gf` | Focus the diagnostic float (to scroll or copy it) |

## Format & lint [lua/plugins/conform.lua]

| Mode | Key          | Action                                  |
| ---- | ------------ | --------------------------------------- |
| n, v | `<leader>lf` | Save, format buffer or range, then lint |

Formatting also runs automatically on save.

## Git -- fugitive & gitsigns [lua/plugins/fugitive.lua, lua/plugins/gitsigns.lua]

| Key | Action |
| --- | --- |
| `<leader>Gs` | Fugitive status / staging area |
| `<leader>Gc` | `git commit -s` (signed-off) |
| `<leader>Gp` / `<leader>GP` | `git pull` / `git push` |
| `<leader>GB` | Blame current line |
| `<leader>GS` / `<leader>GR` | Stage / reset whole buffer |
| `<leader>hj` / `<leader>hk` | Next / previous hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` / `<leader>hu` | Stage / undo-stage hunk |
| `<leader>hr` | Reset hunk |

`:Gclog`, `:Gdiffsplit`, and all other fugitive commands are available as
usual. Gitsigns maps are only set in buffers inside a git repo.

## Terminal -- toggleterm [lua/plugins/toggleterm.lua, lua/config/keymaps.lua]

| Mode | Key | Action |
| --- | --- | --- |
| n, i, t | `<C-\>` | Toggle terminal |
| n | `<leader>tf` | Floating terminal |
| n | `<leader>th` | Horizontal terminal (40% height) |
| n | `<leader>tv` | Vertical terminal (40% width) |
| t | `jk` or `<Esc>` | Leave terminal mode (back to normal mode) |
