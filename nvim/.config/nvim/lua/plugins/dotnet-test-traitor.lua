return {
  {
    "sebastianstudniczek/dotnet-test-traitor.nvim",
    ft = "cs",
    dependencies = {
      "folke/snacks.nvim",
      "folke/trouble.nvim",
      "seblj/roslyn.nvim",
    },
    --- @type dotnet-test-traitor.Configuration
    opts = {
      filters = {
        {
          name = "Unit Tests",
          value = "Category!=Manual&Category!=E2E&Category!=Integration&Category!=Performance&Category!=Service|Type=Service-InMemory",
        },
        { name = "Integration", value = "Category=Integration" },
        { name = "E2E Tests", value = "Category=E2E" },
      },
    },
    keys = {
      { "<leader>tc", "<Plug>(DotnetTestTraitorRun)", mode = "n", desc = "Run Test Category (Dotnet)" },
    },
  },
}
