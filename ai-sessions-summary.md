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

