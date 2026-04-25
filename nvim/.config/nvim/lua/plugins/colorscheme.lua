return {
  {
    "rose-pine/neovim",
    enabled = true,
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        styles = {
          transparency = true,
          italic = false,
        },
        highlight_groups = {
          NormalFloat = { bg = "NONE" },
          BlinkCmpDoc = { bg = "NONE" },
          BlinkCmpLabel = { fg = "foam" },
        },
      })
      vim.cmd("colorscheme rose-pine-moon")
    end,
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
        keywords = {
          italic = false,
        },
      },
    },
  },
}
