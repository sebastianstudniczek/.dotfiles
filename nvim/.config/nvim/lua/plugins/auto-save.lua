local included_filetypes = {
  "cs",
}

return {
  "okuuva/auto-save.nvim",
  opts = {
    condition = function(buf)
      if vim.tbl_contains(included_filetypes, vim.fn.getbufvar(buf, "&filetype")) then
        return true
      end

      return false
    end,
  },
  keys = {
    { "<leader>uv", "<cmd>ASToggle<CR>", desc = "Toggle autosave" },
  },
}
