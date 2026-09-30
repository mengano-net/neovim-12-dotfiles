---

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

