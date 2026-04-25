local M = {}

local function check_env(name, required, on_success)
  local val = vim.env[name]

  if val and val ~= "" then
    vim.health.ok(name .. " = " .. val)
    on_success()
  elseif required then
    vim.health.error(name .. " env variable is missing")
  else
    vim.health.warn(name .. " env variable not set")
  end
end

local function check_extra(name)
  if LazyVim.has_extra(name) then
    vim.health.ok(name .. " extra is enabled")
  else
    vim.health.warn(name .. "extra is disabled")
  end
end

M.check = function()
  vim.health.start("Config")
  vim.health.ok("Config loaded")

  vim.health.start("AI")
  check_env("COPILOT_ENABLED", false, function()
    check_extra("ai.copilot-native")
  end)

  vim.health.start("Roslyn")
  if vim.g.roslyn_plugin_enabled then
    vim.health.ok("Using `roslyn.nvim` plugin for roslyn lsp")
  else
    vim.health.ok("Using `easy-dotnet.nvim` plugin for roslyn lsp")
  end
end

return M
