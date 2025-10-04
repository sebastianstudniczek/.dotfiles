return {
  {
    "folke/noice.nvim",
    opts = {
      -- TODO: Disabling LSP proegress until this is fixed for roslyn.nvim https://github.com/seblyng/roslyn.nvim/issues/236
      routes = {
        filter = {
          event = "lsp",
          kind = "progress",
          cond = function(message)
            local client = vim.tbl_get(message.opts, "progress", "client")
            return client == "roslyn"
          end,
        },
        opts = { skip = true },
      },
      presets = {
        lsp_doc_border = true,
      },
      notify = {
        view = "mini",
      },
    },
  },
}
