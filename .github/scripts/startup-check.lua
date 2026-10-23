-- Headless startup smoke test. Loaded with --cmd so it runs BEFORE init.lua.
--
--   SMOKE_MODE=bootstrap  first start: vim.pack installs plugins from the lockfile; never fails
--   SMOKE_MODE=check      open SMOKE_FILES, fail on any WARN/ERROR notification,
--                         error message, or error raised while opening a file
--
-- Mason servers are not installed: mason-lspconfig skips ensure_installed when headless.
--
-- Exit code: 0 = clean, 1 = problems found (listed on stdout).

local mode  = vim.env.SMOKE_MODE or "check"
local files = vim.split(vim.env.SMOKE_FILES or "", ",", { trimempty = true })

local problems = {}
local function problem(kind, msg) table.insert(problems, kind .. ": " .. vim.trim(tostring(msg))) end

-- Capture warnings/errors from vim.notify (plugins report setup failures this way)
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
    if level and level >= vim.log.levels.WARN then problem("notify", msg) end
    return orig_notify(msg, level, opts)
end

local function out(line) io.stdout:write(line .. "\n") end

local function finish()
    for _, line in ipairs(vim.split(vim.fn.execute("messages"), "\n", { trimempty = true })) do
        if line:match("E%d+:") or line:match("[Ee]rror") then problem("message", line) end
    end

    if mode == "bootstrap" then
        out("bootstrap done; plugins: " .. #vim.pack.get())
        vim.cmd("qall!")
        return
    end

    if #problems == 0 then
        out("OK: clean startup, opened " .. #files .. " file(s)")
        vim.cmd("qall!")
    else
        out("FAILED: " .. #problems .. " problem(s)")
        for _, p in ipairs(problems) do out("  " .. p) end
        vim.cmd("cquit 1")
    end
end

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.schedule(function()
            if mode == "bootstrap" then return finish() end
            for _, f in ipairs(files) do
                local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(f))
                if not ok then problem("edit " .. f, err) end
            end
            -- Give async work (LSP attach, linters, treesitter) time to report
            vim.defer_fn(finish, 3000)
        end)
    end,
})
