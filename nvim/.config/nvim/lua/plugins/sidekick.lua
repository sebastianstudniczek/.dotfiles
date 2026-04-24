return {
  "folke/sidekick.nvim",
  opts = {
    nes = {
      enabled = vim.g.copilot_enabled,
    },
    copilot = {
      status = {
        level = not vim.g.copilot_enabled and vim.log.levels.OFF or vim.log.levels.WARN,
      },
    },
  },
  keys = {
    {
      "<leader>ao",
      function()
        require("sidekick.cli").toggle({ name = "opencode", focus = true })
      end,
      desc = "Sidekick OpenCode",
    },
  },
}
