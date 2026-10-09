---

## 2026-10-09 - Fix netrw directory state persistence between file opens

**Purpose**: Restore expanded directory structure and cursor position in netrw when reopening the file browser after viewing a file

**Ideas Explored**:
- Root cause: BufWinEnter autocmd closes netrw window, and default fastbrowse=1 wipes the buffer, losing state
- Solution: Set fastbrowse=2 to keep buffer hidden instead of wiped, preserving tree structure

**Problems Solved**:
- netrw was losing expanded directory state and cursor position on reopen — caused by autocmd closing the buffer with bufhidden=wipe; fixed by setting vim.g.netrw_fastbrowse = 2 to keep buffer hidden instead

**Work Completed**:
- Added vim.g.netrw_fastbrowse = 2 to lua/config/options.lua in the netrw configuration block

**Decisions Made**:
- Set fastbrowse to level 2 (keep buffer hidden) instead of level 1 (wipe on close) — tradeoff: netrw won't auto-refresh directory contents when revisit, but cursor position and expanded state persist

**Current State**: Configuration change applied but not yet tested in a running Neovim instance; awaiting user verification of behavior

**Next Steps**:
- - [ ] Restart Neovim and open netrw with <leader>ee
- - [ ] Expand several directories and open a file
- - [ ] Press <leader>ee again to verify tree structure and cursor position are preserved
- - [ ] If behavior still resets, implement manual buffer reopen logic as fallback

---

## 2026-10-09 - Fix netrw state persistence with custom buffer toggle

**Purpose**: Fix netrw losing expanded directories and cursor position when switching between files

**Ideas Explored**:
- Using vim.g.netrw_fastbrowse = 2 to keep buffer hidden instead of wiped
- Custom toggle that reuses one persistent netrw buffer instead of calling :Lexplore each time
- Testing with headless nvim to verify buffer state preservation

**Problems Solved**:
- netrw_fastbrowse = 2 alone didn't work — discovered :Lexplore hardcodes bufhidden=wipe and rebuilds on each call, overriding the setting
- BufWinEnter autocmd closes the window when opening files, destroying the buffer under default netrw settings — solved by custom toggle that hides instead of closing

**Work Completed**:
- Replaced <leader>ee keymap in lua/config/keymaps.lua with custom toggle that keeps one persistent netrw buffer
- Toggle shows/hides explorer window instead of creating new buffer each time
- Set bufhidden=hide on the persistent buffer so it survives window close events
- Verified fix with headless test: expanded dirs and cursor position intact after close/reopen cycle

**Decisions Made**:
- Custom toggle preferred over :Lexplore — :Lexplore's hardcoded bufhidden=wipe made configuration-only fixes impossible
- First call still uses :Lexplore once for initialization, then switches to hide mode — reuses netrw's own setup logic

**Current State**: netrw now preserves expanded directory tree and cursor position across file opens. The custom toggle at <leader>ee closes the explorer window (keeping the buffer alive) when visible, and reopens the same buffer when hidden. Tested and verified with headless Neovim.

**Next Steps**:
- - [ ] Test in a real Neovim session: expand directories, open a file with <leader>ee, then press <leader>ee again to verify cursor and tree state are preserved
- - [ ] Verify the width (netrw_winsize) is still correct after reopen

---

## 2026-10-09 - Preserve netrw tree state between buffer sessions with custom toggle

**Purpose**: Fix netrw to remember expanded directory structure and cursor position when reopening the file browser after editing files.

**Ideas Explored**:
- Using vim.g.netrw_fastbrowse = 2 to preserve buffer state (attempted, insufficient)
- Custom toggle that keeps netrw buffer alive with bufhidden=hide instead of wipe (implemented)
- Checked netrw help to see if built-in state preservation exists (confirmed none)

**Problems Solved**:
- netrw buffer was destroyed on window close: `:Lexplore` hardcodes `bufhidden=wipe`, erasing expanded tree and cursor position on each close. Solution: Replace `<leader>ee` with custom toggle that keeps buffer alive with `bufhidden=hide` and re-shows it without rebuilding. Tested via headless Neovim to verify cursor position and directory expansion survive the close/reopen cycle.

**Work Completed**:
- Modified lua/config/keymaps.lua: replaced `:Lexplore` call with custom toggle function for `<leader>ee` that manages buffer visibility and restoration
- First call runs `:Lexplore` once, then sets `bufhidden=hide` on the netrw buffer
- Subsequent calls close window (if visible) or reopen the saved buffer (if hidden), preserving tree state
- Verified through headless testing: buffer identity, expanded directories, cursor line (16), line count (26), filetype (netrw), window width (36) all preserved across close/reopen
- Tested full cycle: opened explorer, expanded lua/ and config/, opened options.lua in new window, closed explorer, reopened explorer to confirm state intact

**Decisions Made**:
- Keep custom toggle rather than rely on netrw_fastbrowse — `:Lexplore` hardcodes buffer destruction, so setting fastbrowse level has no effect
- Keep existing BufWinEnter autocmd in autocmds.lua that closes netrw windows — the custom toggle works correctly with this

**Current State**: lua/config/keymaps.lua modified with custom netrw toggle for `<leader>ee`. Tested via headless Neovim; full state preservation confirmed. Ready for real-session testing.

**Next Steps**:
- - [ ] Test in real Neovim session: open explorer, expand directories, open a file, reopen explorer with `<leader>ee`, verify tree and cursor position are preserved

---

## 2026-10-09 - Fix netrw state persistence after opening files

**Purpose**: Restore netrw's expanded directories and cursor position after reopening the file explorer following file opens

**Ideas Explored**:
- vim.g.netrw_fastbrowse = 2 to preserve buffer (didn't work)
- Replace :Lexplore with custom toggle to control bufhidden (partial fix)
- Save/restore netrw window-local variables across reopens (final solution)

**Problems Solved**:
- Problem: netrw reset to root directory each time explorer reopened. Root cause: :Lexplore hardcodes bufhidden=wipe, destroying buffer and all state. Solution: Custom toggle that hides buffer instead of wiping it, keeps state intact.
- Problem: E121 'Undefined variable: w:netrw_treetop' when opening file from restored tree. Root cause: Window-local variables netrw uses for tree state weren't preserved across window close/reopen. Solution: Save variables from current buffer before closing window, restore them into new window on reopen.

**Work Completed**:
- Added custom explorer toggle to lua/config/keymaps.lua that replaces :Lexplore
- Toggle closes explorer window but sets bufhidden=hide to preserve buffer and its contents
- Toggle reopens same buffer on left sidebar at netrw_winsize width
- Implemented window-variable save/restore (netrw_treetop, netrw_treedict, etc.) to fix tree state after reopens

**Decisions Made**:
- Decided against relying on netrw's built-in options; custom toggle needed to achieve expected sidebar behavior
- Chose to save variables on CursorMoved rather than on every keystroke to match natural user workflow

**Current State**: Custom netrw toggle fully implemented with window-variable persistence. Changes staged in lua/config/keymaps.lua and lua/config/options.lua. Ready for real-session testing to confirm the full cycle (expand dirs → open file → reopen explorer) works without error.

**Next Steps**:
- - [ ] Restart Neovim and test the full sequence: expand directories, open a file, reopen explorer (should show same state), then open another file
- - [ ] Verify no E121 errors appear
- - [ ] Confirm sidebar width, tree expansion, and cursor position are all preserved

---

## 2026-10-09 - Fix netrw explorer state preservation across file opens

**Purpose**: Preserve expanded directories and cursor position in netrw when reopening the explorer after opening a file

**Ideas Explored**:
- vim.g.netrw_fastbrowse = 2 to prevent buffer destruction (insufficient alone)
- Custom toggle replacing :Lexplore to manage window visibility
- Saving/restoring window-local variables (netrw_treetop, netrw_treedict) across window close/open cycles

**Problems Solved**:
- netrw state reset on reopen — root cause was :Lexplore hardcoding bufhidden=wipe, destroying the buffer that stored tree state; solution was custom toggle that hides the buffer instead of wiping it
- E121 'Undefined variable: w:netrw_treetop' error when opening files from restored tree — window-local variables weren't preserved across window close/open; solution was to save/restore w:netrw_* variables when explorer is hidden and restore them when reopened

**Work Completed**:
- Added vim.g.netrw_fastbrowse = 2 to lua/config/options.lua in netrw options block
- Rewrote <leader>ee in lua/config/keymaps.lua from :Lexplore call to custom toggle function that manages a single persistent buffer
- Implemented save/restore logic for window-local variables (netrw_treetop, netrw_treedict, netrw_curdir, netrw_liststyle) to preserve tree state across hide/reopen cycles
- Fixed restore logic to use getwinvar(win, '') instead of pairs() for proper variable enumeration

**Decisions Made**:
- Checked netrw help and confirmed no built-in 'auto-hide after opening file, remember state' option exists — custom solution is justified and not duplicating netrw functionality
- Custom toggle is better than :Rexplore because :Rexplore only works in windows netrw has already used
- Chose to not use netrw_fastbrowse = 2 alone because :Lexplore hardcodes its own bufhidden setting, making fastbrowse irrelevant

**Current State**: netrw explorer now preserves expanded directories and cursor position when toggled closed and reopened, including across file opens. Fix is committed and PR is open. User testing confirmed it works.

**Next Steps**:
- - [ ] Merge PR #11 when ready
- - [ ] Update ai-sessions-summary.md with final window-variable fix (initial fastbrowse attempt is incomplete history)

## 2026-09-30 - Diagnose neovim LSP installation failures on WSL Ubuntu

**Purpose**: Identify why bashls, yamlls, and pyright fail to install in Mason on WSL Ubuntu

**Ideas Explored**:
- Checked mason.log for error messages
- Verified which Mason packages were successfully installed vs. failed
- Identified npm as the common dependency for failing servers
- Audited system for other Mason prerequisites (node, unzip, python3)

**Problems Solved**:
- Root cause identified: npm is not installed in WSL; Mason fails with 'Could not find executable "npm" in PATH' for all three npm-based LSP servers

**Work Completed**:
- Diagnosed npm missing as root cause of bashls, yamlls, pyright installation failures
- Documented which Mason packages succeeded (lua_ls, marksman use prebuilt binaries) and which failed (all three are npm packages)
- Identified secondary blockers: unzip missing, python3-pip missing

**Decisions Made**:
- Deferred installation per user request — only investigated, did not install node/npm or attempt server installation

**Current State**: bashls, yamlls, pyright remain uninstalled; root cause documented; system ready for npm install when user decides

**Next Steps**:
- - [ ] Install Node.js and npm (`sudo apt install nodejs npm` or via nvm/fnm for current LTS)
- - [ ] Install unzip (`sudo apt install unzip`)
- - [ ] Optionally install python3-pip and python3-venv
- - [ ] Restart nvim and run `:MasonInstall bash-language-server yaml-language-server pyright`

---

## 2026-09-30 - Node.js/npm installation for Mason language servers (WSL Ubuntu)

**Purpose**: Diagnose why bashls, yamlls, and pyright language servers weren't installing in Mason

**Ideas Explored**:
- Snap vs apt for Node.js installation; snap chosen for newer LTS version (v24 vs v18 EOL) and included npm

**Problems Solved**:
- bashls, yamlls, pyright failing to install in Mason — root cause: missing Node.js/npm. Mason logs showed 'npm failed — Could not find executable "npm" in PATH'. Fixed by installing Node v24 LTS via snap and unzip via apt

**Work Completed**:
- Diagnosed Mason installation failures by reading ~/.local/state/nvim/mason.log
- Identified all three servers are npm packages requiring Node.js and npm
- Audited system dependencies: node (missing), npm (missing), unzip (missing), python3 (v3.12.3, present), curl/wget/git/tar/gzip (present)
- Recommended snap-based installation strategy with v24 LTS Node instead of apt's outdated v18
- Verified snap works on WSL with systemd and /snap/bin already on PATH
- Confirmed all three servers (bashls, yaml-language-server, pyright) installed successfully after user installed Node and unzip

**Decisions Made**:
- Use `sudo snap install node --classic --channel=24/stable` instead of apt: Node v24 LTS is much newer than apt's v18 (EOL), npm is included, and snap is already functional on the WSL setup

**Current State**: bashls, yaml-language-server, and pyright all installed in ~/.local/share/nvim/mason/packages; Node v24.21.0, npm 11.19.0, and unzip available on PATH; mason.log shows 'Installation succeeded' for all three at 20:12

**Next Steps**:
- - [ ] Verify language server attachment by opening .sh, .yaml, and .py files and running `:checkhealth lsp` or `:lua vim.print(vim.lsp.get_clients())`

---

## 2026-09-30 - Resolve Mason Language Server Installations via Snap Node

**Purpose**: Diagnose and fix missing npm-based language server installations in Mason, install Node via snap, and verify all three servers are working

**Ideas Explored**:
- Compared apt nodejs (18.19.1, EOL) vs snap node (24.21.0 LTS) — snap chosen for freshness and built-in npm
- Considered unzip dependency separately (needed by Mason for other packages)

**Problems Solved**:
- Mason failed to install bashls, yamlls, pyright with 'Could not find executable npm in PATH' — root cause was missing node/npm. Resolved by installing Node 24 LTS via snap and unzip via apt.

**Work Completed**:
- Analyzed mason.log and identified npm missing from PATH as the blocker
- Cross-checked available utilities: curl, wget, git, tar, gzip present; node, npm, unzip missing; python3 present but ensurepip unavailable
- Verified WSL systemd availability to confirm snap would work
- Installed Node 24.21.0 LTS with npm 11.19.0 via snap (--classic --channel=24/stable)
- Installed unzip via apt
- Verified all three language servers installed successfully to ~/.local/share/nvim/mason/packages
- Documented findings and installation path in ai-sessions-summary.md

**Decisions Made**:
- Use snap over apt for Node — snap offers Node 24 LTS (vs apt's 18 EOL), includes npm with no extra dependency tree, simpler toolchain for Neovim LSP runtime

**Current State**: All three npm-based language servers (bashls, yamlls, pyright) are installed and verified. PR #10 is open and awaiting review, but the ai-sessions-summary.md file contains incorrect dates (2026-09-30 instead of 2026-09-29) and stale content ('remain uninstalled' instead of 'installed').

**Next Steps**:
- - [ ] Fix dates in ai-sessions-summary.md: change 2026-09-30 to 2026-09-29
- - [ ] Update stale content in summary file: remove 'remain uninstalled', confirm servers are now installed and working
- - [ ] Optionally rename branch to remove doubled 'session-2026-09-29' prefix (cosmetic)
- - [ ] Verify language servers attach by opening .sh/.yaml/.py files and running :checkhealth lsp
- - [ ] Merge PR #10 after corrections

---

## 2026-10-09 - Fix netrw explorer state persistence across file opens

**Purpose**: Preserve netrw's expanded directories and cursor position when returning to the explorer after opening a file.

**Ideas Explored**:
- Configure netrw_fastbrowse=2 (built-in buffer retention option)
- Custom toggle to hide/reopen window while keeping buffer alive
- Window-local variable save/restore to capture tree state before window close

**Problems Solved**:
- netrw_fastbrowse=2 alone ineffective because :Lexplore hardcodes bufhidden=wipe, destroying buffer and state on close
- E121 crash on file open from restored explorer — window-local variables (netrw_treetop, netrw_treedict, etc.) not preserved in reopened window, causing netrw to fail mid-navigation
- Merge conflict in ai-sessions-summary.md when main gained PR #10 which also added the file; resolved by keeping both session entries in chronological order

**Work Completed**:
- Built custom explorer toggle in lua/config/keymaps.lua replacing :Lexplore calls with hide/reopen of persistent buffer
- Implemented window-local variable save/restore mechanism triggered on cursor moves and buffer-leave to preserve tree state across window close/reopen
- Tested full cycle in headless environment: expand directories, open file (explorer auto-closes), reopen explorer with state intact, open second file — all without errors
- Committed changes on branch fix/session-2026-10-09-netrw-explorer-state and pushed to remote; created PR #11
- Resolved add/add conflict in ai-sessions-summary.md by merging both sessions' entries, committed as dd628d8

**Decisions Made**:
- Custom toggle instead of relying on netrw config settings — issue is architectural (:Lexplore destroys buffer), not configurable
- Save window variables on cursor moves and BufLeave events to capture state before netrw clears them during file open
- Kept auto-close behavior from BufWinEnter autocmd rather than replacing it; the toggle handles the hide/reshow without interfering

**Current State**: Fix implemented and tested. Commit 208d0d5 on branch fix/session-2026-10-09-netrw-explorer-state. PR #11 open but out of sync with GitHub (merge commit dd628d8 not pushed). ai-sessions-summary.md contains five entries for today — first describes abandoned fastbrowse-only approach, remainder accurate; should be consolidated into one entry before merge.

**Next Steps**:
- - [ ] Push merge commit to GitHub (`git push` or via git-operations skill) to sync PR #11 state
- - [ ] Consolidate five duplicate ai-sessions-summary.md entries into one accurate entry for today
- - [ ] Review and merge PR #11 to main

