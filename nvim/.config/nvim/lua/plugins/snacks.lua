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
              -- Overide default behvaior so that deleted files are moved to trash instead of deleted permanently
              explorer_del = function(picker) --[[Override]]
                local actions = require("snacks.explorer.actions")
                local Tree = require("snacks.explorer.tree")
                local paths = vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
                if #paths == 0 then
                  return
                end
                local what = #paths == 1 and vim.fn.fnamemodify(paths[1], ":p:~:.") or #paths .. " files"
                actions.confirm("Put to the trash " .. what .. "?", function()
                  for _, path in ipairs(paths) do
                    local cmd
                    local is_windows = vim.fn.has("win32") == 1

                    if is_windows then
                      local function_name
                      if vim.loop.fs_stat(path).type == "directory" then
                        function_name = "DeleteDirectory"
                      else
                        function_name = "DeleteFile"
                      end

                      cmd = {
                        "powershell.exe",
                        "-Command",
                        string.format(
                          "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::%s('%s', 'OnlyErrorDialogs', 'SendToRecycleBin')",
                          function_name,
                          path
                        ),
                      }
                    else
                      if vim.fn.executable("trash") == 1 then
                        cmd = { "trash", path }
                      else
                        Snacks.notify.error("Missing `trash` CLI on this system")
                        return
                      end
                    end

                    local ok, result = pcall(function()
                      return vim.system(cmd, { text = true })
                    end)

                    if ok then
                      Snacks.bufdelete({ file = path, force = true })
                    else
                      Snacks.notify.error("Failed to delete `" .. path .. "`:\n- " .. result)
                    end
                    Tree:refresh(vim.fs.dirname(path))
                  end
                  picker.list:set_selected()
                  actions.update(picker)
                end)
              end,
            },
          },
        },
      },
    },
  },
}
