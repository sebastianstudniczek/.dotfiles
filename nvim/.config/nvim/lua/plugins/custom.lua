return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        yaml = { "cfn_lint" },
      },
    },
  },
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
      },
    },
  },
  {
    "fei6409/log-highlight.nvim",
    opts = {},
  },
}
