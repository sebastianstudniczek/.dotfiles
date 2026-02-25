-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable ai completions in autosuggestions popup
vim.g.ai_cmp = false
-- https://github.com/nvim-neotest/neotest/pull/521
-- Not playing well right now, check on nvim 12, mainly set cause of neotest floating window
-- vim.o.winborder = "rounded"

-- Setup pwsh for command line actions
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command "
  vim.opt.shellpipe = '2>&1 | ForEach-Object { "$_" } | Out-File -Encoding UTF8 -FilePath %s; exit $LastExitCode'
  vim.opt.shellredir = '2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath %s; exit $LastExitCode'
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end
