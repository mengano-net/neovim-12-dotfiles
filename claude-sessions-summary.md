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

