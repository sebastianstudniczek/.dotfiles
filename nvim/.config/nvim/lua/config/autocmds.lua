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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client_id = ev.data.client_id
    local client = assert(vim.lsp.get_client_by_id(client_id))

    -- Currently disabling for lua due to weird indenatation problems
    if client.name ~= "lua_ls" then
      vim.lsp.on_type_formatting.enable(true, { client_id = client_id })
    end
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

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd("edit " .. vim.lsp.log.get_filename())
end, {})
