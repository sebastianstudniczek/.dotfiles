return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        sections = {
          { section = "header" },
          { section = "keys", indent = 1, padding = 1 },
          { section = "projects", icon = " ", title = "Projects", indent = 2, padding = 1 },
          { section = "recent_files", icon = " ", title = "Recent Files", indent = 3, padding = 2 },
          { section = "startup" },
        },
      },
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["A"] = "explorer_add_dotnet",
                },
              },
            },
            actions = {
              explorer_add_dotnet = function(picker)
                local dir = picker:dir()
                local tree = require("snacks.explorer.tree")
                local actions = require("snacks.explorer.actions")
                local easydotnet = require("easy-dotnet")

                easydotnet.create_new_item(dir, function(item_path)
                  tree:open(dir)
                  tree:refresh(dir)
                  actions.update(picker, { target = item_path })
                end)
              end,
            },
          },
        },
      },
    },
  },
}
