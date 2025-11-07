return {
 -- TODO: Try to find a way to make it work with custom wsl clipboard
  {
    "gbprod/yanky.nvim",
    enabled = false,
    opts = {},
  },
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
}
