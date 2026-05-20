local get_windows_del_cmd = function(path)
  local function_name
  if vim.loop.fs_stat(path).type == "directory" then
    function_name = "DeleteDirectory"
  else
    function_name = "DeleteFile"
  end

  return {
    "powershell.exe",
    "-NoProfile",
    "-NonInteractive",
    "-Command",
    string.format(
      [[Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::%s('%s', 'OnlyErrorDialogs', 'SendToRecycleBin')]],
      function_name,
      path
    ),
  }
end

local get_unix_del_cmd = function(path)
  if vim.fn.executable("trash") == 1 then
    return { "trash", path }
  else
    Snacks.notify.error("Missing `trash` CLI on this system")
    return nil
  end
end

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
          lsp_references = {
            transform = function(item, ctx)
              if not item.file:match("^roslyn%-source%-generated://") or item.buf then
                return item
              end

              -- TODO: Fix in snacks.picker
              -- https://github.com/folke/snacks.nvim/commit/cd5eddb1dea0ab69a451702395104cf716678b36
              -- Force loading buffer that will trigger BufReadCmd and load source gen content
              -- TODO: How to change path in result window?
              local client = assert(vim.lsp.get_clients({ name = "roslyn" })[1])
              client:request("workspace/textDocumentContent", { uri = item.file }, function(err, result)
                assert(not err, vim.inspect(err))
                local buf = vim.api.nvim_create_buf(false, true) -- scratch + unlisted
                vim.bo[buf].filetype = "cs"
                local normalized = string.gsub(result.text, "\r\n", "\n")
                local source_lines = vim.split(normalized, "\n", { plain = true })
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, source_lines)
                item.buf = buf
                item.preview_title = item.file:match(".*/([^/?]+)")
              end)

              return item
            end,
          },
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
                local easydotnet = require("easy-dotnet")

                easydotnet.create_new_item(dir, function(item_path)
                  local tree = require("snacks.explorer.tree")
                  local actions = require("snacks.explorer.actions")
                  tree:open(dir)
                  tree:refresh(dir)
                  actions.update(picker, { target = item_path })
                  picker:focus()
                end)
              end,
              -- Overide default behvaior so that deleted files are moved to trash instead of deleted permanently
              explorer_del = function(picker) --[[Override]]
                local actions = require("snacks.explorer.actions")
                local tree = require("snacks.explorer.tree")
                local paths = vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
                if #paths == 0 then
                  return
                end

                -- :p → make it a full (absolute) path.
                -- :~ → replace the home directory with ~.
                -- :. → make it relative to the current directory if possible.
                local what = #paths == 1 and vim.fn.fnamemodify(paths[1], ":p:~:.") or #paths .. " files"
                Snacks.picker.util.confirm("Put to the trash " .. what .. "?", function()
                  for _, path in ipairs(paths) do
                    local cmd
                    local is_windows = vim.fn.has("win32") == 1

                    if is_windows then
                      cmd = get_windows_del_cmd(path)
                    else
                      cmd = get_unix_del_cmd(path)
                    end

                    if not cmd then
                      return
                    end

                    vim.system(cmd, { text = true }, function(result)
                      vim.schedule(function()
                        if result.code == 0 then
                          Snacks.bufdelete({ file = path, force = true })
                        else
                          Snacks.notify.error("Failed to delete `" .. path .. "`:\n- " .. result.stderr)
                        end
                        tree:refresh(vim.fs.dirname(path))
                      end)
                    end)
                  end
                  picker.list:set_selected() -- clear selection
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
