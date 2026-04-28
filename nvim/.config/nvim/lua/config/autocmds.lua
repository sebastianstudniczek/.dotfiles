-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable autoformat for C# files
-- Set tab width
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "cs" },
  callback = function()
    vim.b.autoformat = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- Don't try to open source generate files on restart
vim.api.nvim_create_autocmd("User", {
  pattern = "PersistenceSavePre",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("roslyn%-source%-generated://") then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end,
})

-- TODO: Implement in neovim core
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if not client:supports_method("workspace/textDocumentContent") then
      return
    end

    local schemes = assert(vim.tbl_get(client.server_capabilities, "workspace", "textDocumentContent", "schemes"))
    vim.notify(vim.inspect(schemes))
    -- Do i need to use au group?
    for _, scheme in ipairs(schemes) do
      vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
        pattern = scheme .. "://*",
        callback = function(args)
          vim.bo[args.buf].modifiable = true
          vim.bo[args.buf].swapfile = false

          local content
          local function handler(err, result)
            assert(not err, vim.inspect(err))
            content = result.text or ""
            if content == vim.NIL then
              content = ""
            end
            local normalized = string.gsub(content, "\r\n", "\n")
            local source_lines = vim.split(normalized, "\n", { plain = true })
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, source_lines)
            vim.bo[args.buf].modifiable = false
            vim.bo[args.buf].modified = false
          end

          ---@type lsp.TextDocumentContentParams
          local params = {
            uri = args.match,
          }

          client:request("workspace/textDocumentContent", params, handler)

          -- Need to block. Otherwise logic could run that sets the cursor to a position
          -- that's still missing.
          vim.wait(1000, function()
            return content ~= nil
          end)
        end,
      })
    end
  end,
})
