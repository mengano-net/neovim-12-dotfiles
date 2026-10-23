# neovim-12-dotfiles

A ground-up Neovim 0.12 configuration that replaces community plugins with
native functionality wherever possible. Third-party plugins are kept only where
Neovim has no reasonable built-in alternative.

| Was a plugin              | Now native                              |
|---------------------------|-----------------------------------------|
| lazy.nvim / packer        | `vim.pack` (with `nvim-pack-lock.json`) |
| nvim-lspconfig            | `vim.lsp.config` + `vim.lsp.enable`     |
| nvim-cmp                  | `vim.lsp.completion` (autotrigger)      |
| LuaSnip                   | `vim.snippet`                           |
| lualine                   | native statusline (`statusline.lua`)    |
| nvim-tree / neo-tree      | netrw (with persistent tree state)      |
| telescope + plenary       | fzf-lua (uses the system `fzf` binary)  |

The UI uses **plain ASCII only** -- no Nerd Font / patched-font glyphs -- so it
renders correctly over SSH with a default terminal font.

---

## Contents

1. [Supported platforms](#supported-platforms)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [First launch](#first-launch)
5. [Language servers, formatters, and linters](#language-servers-formatters-and-linters)
6. [Verifying the setup](#verifying-the-setup)
7. [Daily use](#daily-use)
8. [Updating and managing plugins](#updating-and-managing-plugins)
9. [Customizing](#customizing)
10. [Troubleshooting](#troubleshooting)
11. [Known issues](#known-issues)
12. [Uninstalling](#uninstalling)

Full keymap reference: [docs/KEYMAPS.md](docs/KEYMAPS.md)

---

## Supported platforms

| Platform | Status | Notes |
| --- | --- | --- |
| macOS (Apple Silicon / Intel) | Supported, primary | Developed and tested here (Homebrew). |
| Linux (RHEL/CentOS/Rocky/Fedora, Debian/Ubuntu) | Supported | Install Neovim 0.12 from the official release; distro packages are usually too old. |
| Windows via WSL2 | Should work | Treat it as Linux. |
| Windows (native) | **Not supported** | The config assumes `zsh`, `$HOME`, `/usr/share/dict/words`, and POSIX paths. |

**Terminal:** any terminal with true-color support (`termguicolors` is on).
iTerm2, WezTerm, kitty, Alacritty, Ghostty, and recent macOS Terminal all work.
No special font is needed.

---

## Prerequisites

### Required

| Tool | Why | Check |
| --- | --- | --- |
| **Neovim >= 0.12.0** | `vim.pack`, `vim.lsp.config`, native completion | `nvim --version` |
| **git** | `vim.pack` clones plugins with it; also used by fugitive, gitsigns, and the statusline | `git --version` |
| **fzf** | fzf-lua calls the `fzf` binary directly. Without it, every `<leader>f*` picker is disabled. | `fzf --version` |
| **zsh** | toggleterm is hardcoded to `shell = "zsh"` | `zsh --version` |

### Strongly recommended

| Tool | Why |
| --- | --- |
| **Node.js + npm** | Mason installs `pyright`, `bash-language-server`, and `yaml-language-server` through npm. Without it, those installs fail. |
| **Python 3 (with `venv`)** | Mason installs `black`, `isort`, `pylint`, and `beautysh` into Python virtualenvs. |
| **ripgrep (`rg`)** | Backend for live grep (`<leader>fs`, `<leader>fc`). |
| **fd** | Faster file finder outside git repos (`<leader>ff`). fzf-lua falls back to `rg`/`find` if it's missing. |
| **curl, tar, gzip, unzip** | Mason uses these to download binaries for `lua-language-server`, `marksman`, `stylua`, and others. |
| **C compiler + `tree-sitter` CLI (>= 0.26.1)** | Needed to install extra treesitter parsers (bash, python, yaml, toml, ...). See [Known issues](#known-issues). |

### Optional

| Tool | Why |
| --- | --- |
| Clipboard provider (Linux only) | `clipboard=unnamedplus` needs `wl-clipboard` (Wayland) or `xclip`/`xsel` (X11). Over SSH, Neovim falls back to OSC 52 automatically. macOS needs nothing extra. |
| `/usr/share/dict/words` | Used by the `dictionary` option for `<C-x><C-k>` completion. It's on macOS by default. On Linux, install `words` (RHEL) or `wamerican` (Debian). |

### Install commands

**macOS (Homebrew):**

```bash
brew install neovim git fzf ripgrep fd node python tree-sitter-cli
# zsh, curl, tar, unzip and a C compiler (Xcode CLT) ship with macOS;
# if `cc` is missing: xcode-select --install
```

**RHEL / CentOS Stream / Rocky / Fedora:**

```bash
sudo dnf install -y git zsh fzf ripgrep fd-find nodejs npm python3 \
                    curl tar gzip unzip gcc words
# Neovim 0.12: use the official release tarball (dnf/EPEL is usually older)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

**Debian / Ubuntu:**

```bash
sudo apt install -y git zsh fzf ripgrep fd-find nodejs npm python3 python3-venv \
                    curl tar gzip unzip build-essential wamerican
# Debian names the fd binary `fdfind`; expose it as `fd`:
mkdir -p ~/.local/bin && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
# Neovim 0.12: same release tarball as above (apt is usually older)
```

The `tree-sitter` CLI on Linux: download a prebuilt binary from
<https://github.com/tree-sitter/tree-sitter/releases>, or run
`cargo install --locked tree-sitter-cli`. Don't use npm; nvim-treesitter
explicitly doesn't support the npm build.

> ARM Linux: replace `x86_64` with `arm64` in the Neovim tarball name.

---

## Installation

The repo must be cloned **directly into `~/.config/nvim`**. Symlinks,
`NVIM_APPNAME`, and `nvim -u` aren't supported: with those, `lua/` doesn't end
up on the runtimepath and `require()` fails.

```bash
# 1. Back up any existing config and its data (plugins, state, cache)
mv ~/.config/nvim        ~/.config/nvim.bak        2>/dev/null
mv ~/.local/share/nvim   ~/.local/share/nvim.bak   2>/dev/null
mv ~/.local/state/nvim   ~/.local/state/nvim.bak   2>/dev/null
mv ~/.cache/nvim         ~/.cache/nvim.bak         2>/dev/null

# 2. Clone
git clone https://github.com/mengano-net/neovim-12-dotfiles ~/.config/nvim

# 3. Launch
nvim
```

Backing up `~/.local/share/nvim` is important when migrating from a
lazy.nvim/packer setup, because old plugin directories there can conflict.

---

## First launch

What happens the first time you run `nvim`:

1. **Plugin install prompt.** `vim.pack` reads `nvim-pack-lock.json` and offers
   to install all 12 plugins at their locked commits. Accept it. Plugins go to
   `~/.local/share/nvim/site/pack/core/opt/`.
2. **Mason installs language servers** in the background: `lua_ls`, `pyright`,
   `bashls`, `yamlls`, `marksman`. Run `:Mason` to watch progress. They go to
   `~/.local/share/nvim/mason/bin`, which Mason adds to Neovim's `PATH`.
3. **Expect some warnings.** Messages like `<plugin> not yet loaded -- restart
   Nvim to complete setup` can show up during the first install. Quit and
   reopen Neovim (or run `:restart`). The treesitter one doesn't go away; see
   [Known issues](#known-issues).
4. **Install the remaining tools** (next section).

When you see the tokyonight colors, the ASCII statusline at the bottom, and no
warnings other than the treesitter one, the setup is working.

---

## Language servers, formatters, and linters

Neovim finds every external tool on `PATH`. You can install them through
**Mason** (works the same on every OS, needs no root) or through your **system
package manager**. Use either one.

### Language servers (`lua/lsp/init.lua`)

| Server | Filetypes | Auto-installed by Mason? | Mason package | Homebrew |
| --- | --- | --- | --- | --- |
| `lua_ls` | lua | Yes | `lua-language-server` | `lua-language-server` |
| `pyright` | python | Yes (needs npm) | `pyright` | `pyright` |
| `bashls` | sh, zsh | Yes (needs npm) | `bash-language-server` | `bash-language-server` |
| `yamlls` | yaml | Yes (needs npm) | `yaml-language-server` | `yaml-language-server` |
| `marksman` | markdown | Yes | `marksman` | `marksman` |
| `jsonls` | json, jsonc | **No** | `json-lsp` | `vscode-langservers-extracted` |
| `terraformls` | terraform | **No** | `terraform-ls` | `terraform-ls` |

### Formatters (`lua/plugins/conform.lua`)

Format-on-save is on (5 s timeout). When no formatter is configured for a
filetype, it falls back to LSP formatting.

| Filetype | Formatter(s) | Mason package | Homebrew / pip |
| --- | --- | --- | --- |
| lua | `stylua` | `stylua` | `brew install stylua` |
| python | `isort`, then `black` | `isort`, `black` | `pip install isort black` |
| sh, bash, zsh | `beautysh` | `beautysh` | `brew install beautysh` |
| json, css, html, javascript | `prettier` | `prettier` | `npm i -g prettier` |
| markdown | `markdownlint-cli2` (`--fix`) | `markdownlint-cli2` | `brew install markdownlint-cli2` |

### Linters (`lua/plugins/lint.lua`)

Linters run on `BufEnter`, `BufWritePost`, and `InsertLeave`.

| Filetype | Linter | Mason package |
| --- | --- | --- |
| python | `pylint` | `pylint` |
| markdown | `markdownlint-cli2` | `markdownlint-cli2` |

### Install everything Mason doesn't auto-install

Run this once, from inside Neovim:

```vim
:MasonInstall json-lsp terraform-ls stylua prettier black isort beautysh pylint markdownlint-cli2
```

A missing formatter or linter doesn't break anything. Conform and nvim-lint
skip tools they can't find, so only that one feature is lost.

---

## Verifying the setup

```vim
:checkhealth                  " full report; look at vim.pack, vim.lsp, mason
:checkhealth vim.lsp          " LSP-specific
:messages                     " startup warnings/errors
:lua vim.print(vim.pack.get())          " installed plugins
:lua vim.print(vim.lsp.get_clients())   " LSP clients attached to this buffer
:lua print(vim.fn.stdpath("config"))    " must print ~/.config/nvim
:ConformInfo                  " which formatters are found for this buffer
```

Quick LSP smoke test: open a `.lua` file in this repo and press `K` on
`vim.keymap.set`. A hover window with a rounded border should appear.

---

## Daily use

The leader key is **`<Space>`**. Press it and pause: which-key lists every
available mapping. `<leader>?` shows only the mappings local to the current
buffer.

Most-used keys (full list in [docs/KEYMAPS.md](docs/KEYMAPS.md)):

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files (git-aware) |
| `<leader>fs` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>bl` | List buffers |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>ee` | Toggle file explorer (netrw, keeps tree state) |
| `<leader>w` / `<leader>x` | Write buffer / close buffer |
| `K` | LSP hover |
| `<leader>gd` / `<leader>gr` | Go to definition / references |
| `<leader>la` / `<leader>lr` | Code action / rename |
| `<leader>lf` | Format (+ lint) |
| `<leader>gj` / `<leader>gk` | Next / previous diagnostic |
| `<leader>Gs` | Git status (fugitive) |
| `<leader>hj` / `<leader>hk` | Next / previous git hunk |
| `<C-\>` | Toggle terminal |
| `jk` | Leave insert or terminal mode |

### Behaviors to know about

- **Completion** pops up automatically as you type, from the LSP. Use
  `<C-n>`/`<C-p>` to move through it and `<C-y>` to accept. Nothing is
  pre-selected.
- **Format on save** is on for the filetypes listed above.
- **Clipboard:** yank and paste use the system clipboard (`unnamedplus`).
  `x` doesn't overwrite your register, and `<leader>p` pastes the last yank.
- **Persistent undo** is stored in `~/.cache/nvim/undodir`. Swap and backup
  files are off.
- **Spell check** turns on automatically for git commit, markdown, and LaTeX
  buffers. Words you add with `zg` go to `spell/en.utf-8.add` in this repo.
- **Mouse scrolling is disabled** (`mousescroll=ver:0,hor:0`).
- **Diagnostics** show as `E`/`W`/`H`/`I` in the sign column, with no virtual
  text. Hold the cursor on a line to see the message in a float.

---

## Updating and managing plugins

Plugins are managed by `vim.pack`, and every revision is pinned in
`nvim-pack-lock.json`. Commit that file so every machine gets the same plugin
versions.

```vim
:lua vim.pack.update()        " fetch updates; review in the new tab, :write to apply, :quit to cancel
:lua vim.pack.update(nil, { target = "lockfile" })   " sync this machine to the committed lockfile
:lua vim.pack.del({ "name" }) " remove a plugin (also delete its vim.pack.add() call)
```

To roll back a bad update:

```bash
git -C ~/.config/nvim checkout HEAD -- nvim-pack-lock.json
```

Then, in Neovim, run `:lua vim.pack.update(nil, { target = "lockfile" })`.

To pull config changes on another machine, run `git -C ~/.config/nvim pull`,
restart Neovim, and run the lockfile sync above if plugins changed.

Mason tools update separately: run `:Mason` and press `U`.

---

## Customizing

```text
init.lua                 leader keys, then require plugins -> config -> lsp
lua/
  config/                core editor; never requires a plugin
    init.lua             loads options -> keymaps -> autocmds -> statusline
    options.lua          vim.opt settings, netrw settings, disabled builtins
    keymaps.lua          general keymaps + persistent netrw explorer toggle
    autocmds.lua         treesitter start, winbar, yank highlight, filetype tweaks
    statusline.lua       native statusline (mode, branch, diagnostics, ft, pos)
  lsp/
    init.lua             diagnostics, LspAttach keymaps, server configs, enable list
  plugins/
    init.lua             one require() per plugin
    <plugin>.lua         vim.pack.add() + setup + that plugin's keymaps
nvim-pack-lock.json      pinned plugin revisions (commit this)
spell/en.utf-8.add       personal spell dictionary
```

Conventions:

- **Leader keys** are set at the top of `init.lua`, before any `require`. Don't
  move them. Changing `mapleader` after keymaps exist silently breaks every
  `<leader>` mapping.
- **Add a plugin:** create `lua/plugins/<name>.lua` with
  `vim.pack.add({ "https://github.com/owner/repo" })`, then the setup wrapped
  in `pcall(require, ...)`. Add `require("plugins.<name>")` to
  `lua/plugins/init.lua`, restart, and commit the updated lockfile.
- **Add a language server:** add a `vim.lsp.config("<name>", { cmd = ...,
  filetypes = ..., root_markers = ... })` block in `lua/lsp/init.lua`, then add
  the name to the `vim.lsp.enable({...})` list. Don't use nvim-lspconfig.
- **Add a formatter or linter:** add it to `formatters_by_ft` in
  `lua/plugins/conform.lua` or to `linters_by_ft` in `lua/plugins/lint.lua`,
  and install the binary.
- **Change the shell** used by toggleterm: `shell = "zsh"` in
  `lua/plugins/toggleterm.lua`.
- **Change the colorscheme:** `lua/plugins/tokyonight.lua`. The statusline
  colors are defined separately in `lua/config/statusline.lua`.
- **UI characters:** keep them plain ASCII. No Nerd Font glyphs.

---

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| `module 'config' not found` / `require` errors at startup | The config isn't in `~/.config/nvim`, or you launched with `NVIM_APPNAME`/`-u`. Check with `:lua print(vim.fn.stdpath("config"))`. |
| `fzf-lua: fzf binary not found in PATH` | Install fzf. If you launch Neovim from a GUI on macOS, make sure `/opt/homebrew/bin` is on the GUI's PATH. |
| `<leader>` mappings do nothing | Leader was changed after keymaps were registered. Keep `mapleader` as the first lines of `init.lua`. |
| LSP doesn't attach (`:checkhealth vim.lsp` shows no clients) | The server binary isn't on PATH. Run `:Mason` or `:MasonInstall <pkg>`, then `:e` to reload the buffer. |
| Mason install fails for pyright / bashls / yamlls | npm is missing or not on Neovim's PATH. Install Node.js and restart Neovim. |
| Mason install fails for black / isort / pylint / beautysh | Python 3 or its `venv` module is missing (Debian: `python3-venv`). |
| `:TSInstall` fails | The `tree-sitter` CLI (>= 0.26.1) or a C compiler is missing. |
| Format on save does nothing | The formatter isn't installed. `:ConformInfo` shows what it found. |
| Terminal (`<C-\>`) closes immediately | zsh isn't installed. Install it or change `shell` in `toggleterm.lua`. |
| Clipboard doesn't work on Linux | Install `wl-clipboard` or `xclip`. Run `:checkhealth provider`. |
| Plugin got into a weird state | `:lua vim.pack.del({ "name" })`, restart, and it's reinstalled from the lockfile. As a last resort, delete `~/.local/share/nvim/site/pack/core` and restart. |

---

## Known issues

- **Treesitter "not yet loaded" warning on every startup.** The locked
  `nvim-treesitter` revision is the `main` branch rewrite, which no longer has
  the `nvim-treesitter.configs` module that `lua/plugins/treesitter.lua`
  loads. The setup returns early, so `ensure_installed` and `auto_install`
  never run. Highlighting still works for the parsers bundled with Neovim
  (c, lua, markdown, markdown_inline, query, vim, vimdoc). For other languages,
  install parsers by hand (needs the `tree-sitter` CLI and a C compiler):

  ```vim
  :TSInstall bash python yaml toml
  ```

- **mason-lspconfig expects nvim-lspconfig**, which this config deliberately
  doesn't install. Its `ensure_installed` currently works without it, but that
  isn't guaranteed by the plugin. If server auto-install stops working, install
  the servers with `:MasonInstall` instead.
- **Statusline git diff counts** (`+N ~N -N`) aren't wired up yet; only the
  branch name is shown.

---

## Uninstalling

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
# restore a backup if you made one:
mv ~/.config/nvim.bak ~/.config/nvim   # etc.
```

---

## Background

This repo replaces the earlier, plugin-heavy
[mengano-net/neovim-dotfiles](https://github.com/mengano-net/neovim-dotfiles).
Release notes for the Neovim features it relies on:
<https://github.com/neovim/neovim/releases/tag/v0.12.0>.
