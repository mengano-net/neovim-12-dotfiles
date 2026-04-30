# Claude Sessions Summary

This file contains a chronological narrative of all work sessions for this repository.

Session data is tracked in git for team context and long-term memory.
For programmatic access, use the centralized JSON files at `~/.claude/sessions/`.

---

---

## 2026-04-22 - Neovim 0.12 config: scaffold, options, autocmds

**Purpose**: Start a ground-up Neovim 0.12 config replacing plugin-heavy setup with native functionality

**Ideas Explored**:
- NVIM_APPNAME vs symlink vs -u flag for running multiple configs side by side
- Option B module loading: init.lua calls require('config'), config/init.lua loads submodules
- Native winbar with _G.WinbarEval via %{%v:lua...%} instead of a separate module
- Delegated Haiku agent to research 0.12 config layout best practices

**Problems Solved**:
- Problem: vim.loop deprecated; Solution: replaced with vim.uv throughout; Works because vim.uv is the 0.10+ canonical alias
- Problem: spelllang=en_us caused 'spell checking not possible'; Root: en_us.utf-8.spl not bundled with Neovim; Solution: spelllang=en covers US English with bundled en.utf-8.spl
- Problem: nvim -u lua/config/init.lua broke require(); Root: -u does not add lua/ to runtimepath; Solution: clone directly into ~/.config/nvim, no -u flag needed
- Problem: _markdown augroup was named 'terminal' (collision with terminal group); Root: copy-paste bug in old config; Solution: fixed group name to 'markdown'

**Work Completed**:
- Created CLAUDE.md with project purpose, layout, hard constraints, conventions
- Updated README.md with plugin-to-native mapping table and layout
- Scaffolded init.lua, lua/config/init.lua, lua/config/, lua/lsp/, lua/plugins/
- lua/config/options.lua: migrated from old config, modernized (vim.uv, vim.hl, removed deprecated options, individual assignments replacing loops)
- lua/config/autocmds.lua: full migration with bug fixes, API modernizations, native winbar
- lua/config/keymaps.lua: created with terminal mode jk/<Esc> mappings

**Decisions Made**:
- No patched/Nerd Font characters anywhere — config must work on SSH targets with default fonts
- netrw kept enabled as native file browser instead of adding a plugin
- laststatus=3 (global statusline) over laststatus=2
- undofile=true kept — persistent undo across sessions is strictly better
- Repo cloned directly into ~/.config/nvim — no NVIM_APPNAME, no symlink, no -u flag
- completeopt keeps 'preview' for now; note to replace with 'popup' when vim.lsp.completion is wired up

**Current State**: Branch: main. Core config layer complete (options, keymaps, autocmds). LSP and plugins layers not started. Config loads cleanly via plain nvim after cloning to ~/.config/nvim.

**Next Steps**:
- - [ ] Migrate remaining keymaps from old mappings.lua (lua/config/keymaps.lua is minimal)
- - [ ] Start lua/lsp/ — configure language servers with vim.lsp.config + vim.lsp.enable
- - [ ] Update completeopt from 'preview' to 'popup' when LSP completion is wired up
- - [ ] Decide on colorscheme (native built-in vs third-party)
- - [ ] Evaluate what plugins still need to be added to lua/plugins/ (no native replacement)

---

## 2026-04-23 - Neovim 0.12 config — conform formatting debug + format_on_save fix

**Purpose**: Continue building ground-up Neovim 0.12 config; this session focused on conform.nvim formatting behavior

**Ideas Explored**:
- File-based formatters (markdownlint-cli2) require file on disk — silent write before conform.format() fixes manual leader-lf; format_on_save changed from markdown-only to universal; attempted custom trim_whitespace formatter (line-based) — user rejected, reverted

**Problems Solved**:
- leader-lf not triggering markdownlint-cli2: fixed by writing buffer first; format_on_save now fires for all filetypes

**Work Completed**:
- Fixed leader-lf keymap with silent write; simplified format_on_save to always-on; reverted line-based trim_whitespace per user request

**Decisions Made**:
- format_on_save fires for ALL filetypes; trailing whitespace handled by each filetype's own formatter, not custom Lua; silent write before manual conform.format() required for file-based formatters

**Current State**: conform.nvim fully configured. Core config (options, keymaps, autocmds, LSP, mason, lint, conform, which-key, tokyonight, treesitter) all complete.

**Next Steps**:
- 1) Verify leader-lf works for markdown after silent-write fix; 2) Telescope plugin — leader-er recent files, leader-f group; 3) Git plugin — leader-G group; 4) Git hunks — leader-h group; 5) Terminal plugin — leader-t group; 6) Audit old config for missed keymaps; 7) Wire vim.lsp.completion (completeopt popup)

---

## 2026-04-23 - Neovim 0.12: winbar redesign, statusline, gitsigns

**Purpose**: Redesign winbar with two-tone ASCII styling, implement native statusline replacing lualine, and add gitsigns plugin

**Ideas Explored**:
- Two-tone ASCII pill for winbar — light bg pill on dark bar, no patched-font chars needed
- Native statusline via _G.StatuslineRender() + %{%v:lua...%} — same pattern as winbar
- Git branch read from .git/HEAD directly — fast sync read, no plugin dependency
- Statusline diff counts deferred until gitsigns confirmed working (vim.b.gitsigns_status_dict)

**Problems Solved**:
- Old winbar used nvim_eval_statusline for path but new config used expand(); switched to nvim_eval_statusline for better unnamed buffer handling
- Old lualine gitsigns keymaps placed as table values inside setup() — ran eagerly at startup; fixed by moving to on_attach callback for proper per-buffer scoping

**Work Completed**:
- Winbar redesigned: nvim_eval_statusline path, two-tone light-pill style, [No Name] fallback, WinBarCaps removed
- lua/config/statusline.lua created: mode blocks (colored bg), branch, diagnostics, filetype, word count, location, progress
- Statusline wired into lua/config/init.lua
- ColorScheme autocmd added so highlights survive theme changes
- lua/plugins/gitsigns.lua created with on_attach keymaps, vim.pack.add pattern
- gitsigns added to lua/plugins/init.lua

**Decisions Made**:
- Statusline in its own file (lua/config/statusline.lua) — keeps autocmds.lua focused on event handling
- Git diff counts NOT wired into statusline yet — left NOTE comment pointing to vim.b.gitsigns_status_dict; wire after confirming gitsigns works
- plenary.nvim dependency dropped from gitsigns — not required by recent versions
- No Nerd Font glyphs anywhere — ▎ sign for gitsigns kept (standard Unicode, not patched-font)

**Current State**: Branch: main; winbar and statusline live; gitsigns installed but not yet confirmed running; statusline diff counts pending gitsigns verification

**Next Steps**:
- - [ ] Restart Neovim, confirm gitsigns loads and on_attach keymaps work
- - [ ] Wire statusline diff counts via vim.b.gitsigns_status_dict once gitsigns confirmed
- - [ ] Telescope plugin — leader-er recent files, leader-f group
- - [ ] Git buffer operations — leader-G group (beyond gitsigns: fugitive or native?)
- - [ ] Terminal plugin — leader-t group
- - [ ] Audit old config for missed keymaps
- - [ ] Wire vim.lsp.completion (completeopt popup)

---

## 2026-04-23 - Neovim 0.12: fzf-lua, statusline, mapleader bug fix

**Purpose**: Replace telescope with fzf-lua, implement native statusline, debug and fix mapleader keymap invalidation bug

**Ideas Explored**:
- Option C (fzf-lua) over telescope — no plenary, no build step, uses system fzf binary
- LSP picker keymaps (gd/gr/ls/lt) live in fzf-lua.lua under LspAttach — fzf-backed but only active when LSP attached
- vim.fn.exepath('fzf') over hardcoded 'fzf' string — resolves full path regardless of nvim PATH
- vim.v.shell_error check for git detection instead of parsing stdout string

**Problems Solved**:
- Problem: <leader>ff and <leader>bl did nothing; Root: vim.g.mapleader set in options.lua AFTER plugins loaded their keymaps — Neovim silently drops all leader keymaps when mapleader changes post-registration; Solution: moved mapleader assignment to top of init.lua before require('plugins')
- Problem: fzf keymaps not set during init.lua load but worked in isolation; Root: mapleader invalidation (above) masked by silent=true; Diagnosed via headless nvim tracing each init stage

**Work Completed**:
- lua/plugins/fzf-lua.lua created — replaces telescope + plenary + fzf-native
- fzf-lua keymaps: ff (git-aware), fb, fc, fs, fr, fj, bl, vt, vc
- LSP picker keymaps (gd, gr, ls, lt) wired in LspAttach inside fzf-lua.lua
- Dropped keymaps: Gb, Gf, Gl, fz
- init.lua: mapleader set first, before require('plugins')
- options.lua: removed duplicate mapleader assignment, kept Space=Nop
- Stale telescope comment removed from keymaps.lua
- All keymaps verified working after fix

**Decisions Made**:
- mapleader must be set in init.lua before any require() — documented with comment; this is a hard rule for this config
- fzf-lua over telescope: no plenary dep, no build step, system fzf binary, same feature coverage for the gaps that mattered (live grep, file find, buffers, recent files)
- LSP navigation keymaps that use fzf picker belong in fzf-lua.lua, not lua/lsp/ — fzf-lua.lua owns all fzf-backed interactions
- git-aware find_files: check vim.v.shell_error from git rev-parse, not stdout string comparison

**Current State**: Branch: feat/session-2026-04-23-winbar-statusline-gitsigns (open PR #3); fzf-lua working and all keymaps verified; mapleader bug fixed in init.lua

**Next Steps**:
- - [ ] Commit fzf-lua + mapleader fix to current branch or new branch
- - [ ] Confirm gitsigns on_attach keymaps work (hj/hk/hp/hr/hs/hu, GB/GS/GR)
- - [ ] Wire statusline git diff counts via vim.b.gitsigns_status_dict
- - [ ] Terminal plugin — leader-t group
- - [ ] Audit old config for missed keymaps
- - [ ] Start lua/lsp/ — vim.lsp.config + vim.lsp.enable, LspAttach non-picker keymaps
- - [ ] Wire vim.lsp.completion (completeopt popup)

---

## 2026-04-30 - LSP layer: native completion + new servers

**Purpose**: Implement the LSP layer for the Neovim 0.12 config — native completion, keymaps, and additional language servers

**Ideas Explored**:
- vim.lsp.completion.trigger as manual trigger keymap — turned out nil in 0.12, dropped in favor of autotrigger
- CloudFormation support via yamlls schema injection — deferred at user request, user will implement independently
- C-Space for manual completion trigger — conflicts with tmux pane expand, removed as redundant with autotrigger=true

**Problems Solved**:
- Problem: vim.lsp.completion.trigger is nil in 0.12; Root: function does not exist; Solution: removed the keymap, autotrigger=true handles it
- Problem: completeopt had 'preview' instead of 'popup'; Root: placeholder note left in options.lua; Solution: swapped to popup for floating extra-info window

**Work Completed**:
- Enabled native LSP completion via vim.lsp.completion.enable() in LspAttach with autotrigger=true
- Updated completeopt from 'preview' to 'popup' in options.lua
- Added jsonls (vscode-json-language-server) server config and enable
- Added terraformls (terraform-ls) server config and enable
- Added <leader>gi -> fzf.lsp_implementations in fzf-lua LspAttach block
- Annotated all LSP server configs with macOS brew and CentOS install instructions

**Decisions Made**:
- Use autotrigger=true instead of a manual trigger keymap — cleaner, no tmux conflicts
- jsonls via vscode-langservers-extracted (brew installable), not npm global
- terraformls via hashicorp/tap/terraform-ls brew tap
- CloudFormation deferred — user will self-implement yamlls schema injection as a learning exercise
- gj/gk diagnostic cycling already covered by <leader>gj/<leader>gk in which-key.lua via vim.diagnostic.jump — no changes needed

**Current State**: Branch: main. LSP layer complete. Native completion wired. 7 servers configured: lua_ls, pyright, bashls, yamlls, jsonls, marksman, terraformls.

**Next Steps**:
- - [ ] Install terraform-ls binary: brew install hashicorp/tap/terraform-ls
- - [ ] Verify terraformls attaches on a .tf file
- - [ ] Self-implement CloudFormation schema in yamlls settings (user learning exercise)
- - [ ] Register <leader>gi in which-key.lua for discoverability
- - [ ] Full keymap migration from prior config (lua/config/keymaps.lua still incomplete)
- - [ ] Wire gitsigns diff counts into statusline (NOTE in gitsigns.lua)

---

## 2026-04-30 - Plugins: autopairs and toggleterm

**Purpose**: Evaluate and add autopairs and toggleterm plugins to the new Neovim 0.12 config

**Ideas Explored**:
- Native auto-pairing via insert-mode keymaps — rejected due to missing smart skip/backspace/treesitter-context
- Native terminal toggle via custom Lua module (~50-60 lines) — viable but toggleterm chosen for reliability

**Problems Solved**:
- toggleterm vim.pack.add call failed with 'expected list, got table'; Root: version='*' is lazy.nvim syntax, not valid for vim.pack; Fix: removed version pin

**Work Completed**:
- Added lua/plugins/autopairs.lua with treesitter-aware config (no fast-wrap, no cmp integration)
- Added lua/plugins/toggleterm.lua with float/horizontal/vertical directions and zsh shell
- Registered both plugins in lua/plugins/init.lua
- Fixed toggleterm vim.pack.add error by removing invalid version='*' argument

**Decisions Made**:
- autopairs via plugin: smart skip, backspace, and treesitter-context are meaningful daily-use features with no clean native equivalent
- toggleterm via plugin: toggle/persist behavior requires non-trivial Lua; plugin is focused and dependency-free
- border style set to rounded (not curved) to match LSP floats and diagnostics throughout config
- fast wrap (M-e) omitted from toggleterm — not used in prior workflow

**Current State**: Branch: main, both plugins installed and verified working. No open PR for this session.

**Next Steps**:
- - [ ] Install terraform-ls binary: brew install hashicorp/tap/terraform-ls and verify it attaches on a .tf file
- - [ ] Register <leader>gi (lsp_implementations) in which-key.lua for discoverability
- - [ ] Complete full keymap migration from prior config (lua/config/keymaps.lua still partial)
- - [ ] Wire gitsigns diff counts into statusline
- - [ ] CloudFormation schema injection into yamlls settings — user learning exercise, explicitly deferred

---

## 2026-04-30 - Plugins: fugitive, autopairs, toggleterm

**Purpose**: Add vim-fugitive, nvim-autopairs, and toggleterm plugins; update project docs

**Ideas Explored**:
- Native auto-pairing — rejected: missing smart skip/backspace/treesitter-context
- Native terminal toggle (~50-60 lines Lua) — viable but toggleterm chosen for reliability
- Fugitive necessity analysis: staging workflow determines value; user stages from within nvim more often

**Problems Solved**:
- toggleterm vim.pack.add failed with 'expected list, got table'; Root: version='*' is lazy.nvim syntax; Fix: removed version pin

**Work Completed**:
- Added lua/plugins/autopairs.lua with treesitter-aware config
- Added lua/plugins/toggleterm.lua with float/horizontal/vertical directions and zsh shell
- Added lua/plugins/fugitive.lua with keymaps Gs/Gc/Gp/GP matching old config
- Registered all three plugins in lua/plugins/init.lua
- Updated CLAUDE.md: current state, pending items, lsp layer now marked complete

**Decisions Made**:
- autopairs via plugin: smart skip/backspace/treesitter-context have no clean native equivalent
- toggleterm via plugin: toggle/persist behavior is non-trivial Lua; plugin is focused and dependency-free
- fugitive added: user stages from within nvim more than terminal; :Ge: (interactive staging) is the deciding feature
- border style rounded throughout for consistency with LSP floats and diagnostics
- GBrowse skipped: requires rhubarb companion plugin for GitHub URL resolution

**Current State**: main branch, all three plugins installed and verified. CLAUDE.md updated.

**Next Steps**:
- - [ ] Full keymap migration from prior config (lua/config/keymaps.lua still partial)
- - [ ] Wire gitsigns diff counts into statusline
- - [ ] Install terraform-ls: brew install hashicorp/tap/terraform-ls, verify attach on .tf files
- - [ ] Register <leader>gi (lsp_implementations) in which-key.lua for discoverability
- - [ ] CloudFormation schema injection into yamlls — user learning exercise, deferred

