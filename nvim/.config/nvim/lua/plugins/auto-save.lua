local included_filetypes = {
  "cs",
}

local included_extensions = {
  "csproj",
}

return {
  "okuuva/auto-save.nvim",
  lazy = false,
  opts = {
    condition = function(buf)
      if
        vim.tbl_contains(included_filetypes, vim.fn.getbufvar(buf, "&filetype"))
        or vim.tbl_contains(included_extensions, vim.fn.expand("%:e"))
      then
        return true
      end

      return false
    end,
  },
  keys = {
    { "<leader>uv", "<cmd>ASToggle<CR>", desc = "Toggle autosave" },
  },
}
