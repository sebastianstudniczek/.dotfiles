return {
  "folke/sidekick.nvim",
  keys = {
    { "<leader>aa", false }, -- Use for copilot chat
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "copilot", focus = true })
      end,
      desc = "Sidekick Copilot Toggle",
    },
    {
      "<leader>ag",
      function()
        require("sidekick.cli").toggle({ name = "gemini", focus = true })
      end,
      desc = "Sidekick Gemini Toggle",
    },
  },
}
