---@type vim.lsp.Config
return {
  -- Disable by default for cs since there are race condition when applying workspace/applyEdit
  -- (for example when extracting file to new file)
  filetypes = { "lua", "typescript", "javascript", "xml", "go" },
}
