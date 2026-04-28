-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable ai completions in autosuggestions popup
vim.g.ai_cmp = false
vim.g.copilot_enabled = vim.env.COPILOT_ENABLED == 1

vim.g.roslyn_plugin_enabled = true
vim.g.neotest_vstest_enabled = false
vim.lsp.on_type_formatting.enable()
vim.o.winborder = "rounded"

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>cu", require("undotree").open)

-- Setup pwsh for command line actions
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command "
  vim.opt.shellpipe = '2>&1 | ForEach-Object { "$_" } | Out-File -Encoding UTF8 -FilePath %s; exit $LastExitCode'
  vim.opt.shellredir = '2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath %s; exit $LastExitCode'
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

-- TODO: Implement in neovim core
vim.lsp.handlers["workspace/textDocumentContent/refresh"] = function(_, _, ctx)
  local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local uri = vim.api.nvim_buf_get_name(buf)
    if vim.api.nvim_buf_is_loaded(buf) then
      ---@param result lsp.TextDocumentContentResult
      local function handler(err, result)
        assert(not err, vim.inspect(err))
        local content = result.text or ""
        if content == vim.NIL then
          content = ""
        end
        local normalized = string.gsub(content, "\r\n", "\n")
        local source_lines = vim.split(normalized, "\n", { plain = true })
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, source_lines)
        vim.bo[buf].modifiable = false
        vim.bo[buf].modified = false
      end

      ---@type lsp.TextDocumentContentRefreshParams
      local params = {
        uri = uri,
      }

      client:request("workspace/textDocumentContent", params, handler)
    end
  end

  return vim.NIL
end
