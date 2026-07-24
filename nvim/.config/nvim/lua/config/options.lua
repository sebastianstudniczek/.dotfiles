-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable ai completions in autosuggestions popup
vim.g.ai_cmp = false
vim.g.copilot_enabled = vim.env.COPILOT_ENABLED == "1"
vim.g.snacks_animate = false

vim.o.winborder = "rounded"

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>cu", require("undotree").open)

-- Setup pwsh for command line actions
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command "
  vim.opt.shellpipe = '2>&1 | ForEach-Object { "$_" } | Out-File -Encoding UTF8 -FilePath %s; exit $LastExitCode'
  vim.opt.shellredir = '2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath %s; exit $LastExitCode'
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

-- Store server address in .nvim.server file in the root of the git repository
-- This allows other tools to connect to the same Neovim instance using the server address.
-- Need to do this here since `autocmd.lua` runs after VimEnter
local function write_server_file()
  local server = vim.v.servername

  if server == "" then
    return
  end

  local root = vim.fs.root(0, ".git")
  if not root then
    return
  end

  vim.fn.writefile({ server }, root .. "/.nvim.server")
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = write_server_file,
})
