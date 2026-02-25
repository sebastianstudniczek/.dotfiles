-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--- Allman style braces for C#
local function allman_brace()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".") - 1
  local before = line:sub(1, col)

  local should_expand = before:match("%)%s*$") or before:match("%{%s*$")
  if not should_expand then
    return "{"
  end

  return "<CR>{<CR>}<Esc>O"
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs" },
  callback = function()
    vim.keymap.set("i", "{", allman_brace, { expr = true, buffer = true })
  end,
})
