return {
  "folke/sidekick.nvim",
  enabled = false,
  keys = {
    { "<leader>aa", false }, -- Use for copilot chat
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "copilot", focus = true })
      end,
      desc = "Sidekick Copilot Toggle",
    },
  },
}
