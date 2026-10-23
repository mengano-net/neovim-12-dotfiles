# Security policy

## Reporting a vulnerability

Please **don't open a public issue** for security problems.

Report them privately through GitHub's private vulnerability reporting:
<https://github.com/mengano-net/neovim-12-dotfiles/security/advisories/new>
(or the **Security** tab, then **Report a vulnerability**).

Include what you found, how to reproduce it, and the affected file(s). You'll
get a response as soon as practical; this is a personal project maintained in
spare time.

## Scope

This repo is a Neovim configuration. Relevant reports include:

- Config that runs untrusted code, for example from files being edited,
  modelines, or project-local settings
- Plugin sources or pinned revisions in `nvim-pack-lock.json` that point to
  compromised or malicious code
- Secrets or credentials committed to the repo

Vulnerabilities in Neovim itself or in third-party plugins should be reported
to those projects directly.
