return {
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
      -- TODO: Disabling LSP proegress until this is fixed for roslyn.nvim https://github.com/seblyng/roslyn.nvim/issues/236
      lsp = {
        progress = {
          enabled = false,
        },
      },
    },
  },
}
