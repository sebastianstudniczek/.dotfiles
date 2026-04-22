local M = {}

local required_diagnostics = {
  "CS0246",
  "CS0234",
  "CS0103",
  "CS0161",
}

local function get_roslyn_client(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name:lower():match("roslyn") then
      return client
    end
  end
end

local function get_target_diagnostics(bufnr)
  local result = {}

  for _, d in ipairs(vim.diagnostic.get(bufnr)) do
    local code = tostring(d.code)

    if vim.tbl_contains(required_diagnostics, code) then
      table.insert(result, d)
    end
  end

  return result
end

local function get_existing_using_block(lines)
  local items = {}
  local start_line = nil
  local end_line = nil

  for i, line in ipairs(lines) do
    if line:match("^using%s+[%w%.]+;$") then
      start_line = start_line or (i - 1)
      end_line = i
      table.insert(items, vim.trim(line))
    elseif start_line then
      break
    end
  end

  return items, start_line, end_line
end

local function merge_usings(existing, added)
  local seen = {}
  local merged = {}

  local function add(items)
    for _, line in ipairs(items) do
      line = vim.trim(line)

      if line ~= "" and not seen[line] then
        seen[line] = true
        table.insert(merged, line)
      end
    end
  end

  add(existing)
  add(added)

  table.sort(merged, function(a, b)
    return a < b
  end)

  return merged
end

local function apply_using_block(bufnr, new_usings)
  local uri = vim.uri_from_bufnr(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local existing, start_line, end_line = get_existing_using_block(lines)
  local merged = merge_usings(existing, new_usings)

  if not start_line then
    start_line = 0
    end_line = 0
  end

  local edit = {
    changes = {
      [uri] = {
        {
          range = {
            start = { line = start_line, character = 0 },
            ["end"] = { line = end_line, character = 0 },
          },
          newText = table.concat(merged, "\n") .. "\n\n",
        },
      },
    },
  }

  vim.lsp.util.apply_workspace_edit(edit, "utf-8")
end

local function request_actions_for_diag(bufnr, client, diag, cb)
  ---@type lsp.CodeActionParams
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)

  params.range = {
    start = {
      line = diag.lnum,
      character = diag.col,
    },
    ["end"] = {
      line = diag.end_lnum or diag.lnum,
      character = diag.end_col or (diag.col + 1),
    },
  }

  params.context = {
    diagnostics = { diag },
    kind = { "quickfix" },
    trigger = 1,
  }

  client.request("textDocument/codeAction", params, function(err, actions)
    if err or not actions then
      cb({})
      return
    end

    local result = {}

    for _, action in ipairs(actions) do
      local title = action.title
      if title and title:match("^using%s+[%w%.]+;$") then
        table.insert(result, title)
      end
    end

    cb(result)
  end, bufnr)
end

function M.has_missing_import_diagnostic(bufnr)
  for _, d in ipairs(vim.diagnostic.get(bufnr)) do
    local code = tostring(d.code)

    if vim.tbl_contains(required_diagnostics, code) then
      return true
    end
  end

  return false
end

function M.run(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local client = get_roslyn_client(bufnr)
  if not client then
    vim.notify("Roslyn client not found")
    return
  end

  local diagnostics = get_target_diagnostics(bufnr)

  if #diagnostics == 0 then
    vim.notify("No missing imports found")
    return
  end

  local pending = #diagnostics
  local collected = {}

  local function finish()
    pending = pending - 1

    if pending == 0 then
      apply_using_block(bufnr, collected)
    end
  end

  for _, diag in ipairs(diagnostics) do
    request_actions_for_diag(bufnr, client, diag, function(lines)
      for _, line in ipairs(lines) do
        table.insert(collected, line)
      end

      finish()
    end)
  end
end

return M
