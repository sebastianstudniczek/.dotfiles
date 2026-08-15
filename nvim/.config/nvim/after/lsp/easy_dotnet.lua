-- HACK: Skip showing references for TUnit since it can produce lot amount of references and cause roslyn to crash
-- TODO: verify if it's possible to mimics roslyn "show references outside solution"
-- try to use _vs_getProjectsContext or check lsp root dir
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("RoslynRequestInterceptor", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Prevent wrapping the client multiple times on buffer re-attaches
    -- TODO: Can `once` option be used for this?
    if not client or client.name ~= "easy_dotnet" or client._request_intercepted then
      return
    end

    client._request_intercepted = true

    local orig_request = client.request
    client.request = function(self, method, params, handler, bufnr)
      if method == "textDocument/references" and type(handler) == "function" then
        local orig_handler = handler
        handler = function(err, result, ctx, config)
          if result then
            -- Filter out source-generated URIs from the response before the picker sees them
            result = vim.tbl_filter(function(item)
              local uri = item.uri or item.targetUri or ""
              local is_tunit_gen = uri:match("TUnit%.Core%.SourceGenerator%.dll$")
              return not is_tunit_gen
            end, result)
          end
          return orig_handler(err, result, ctx, config)
        end
      end

      return orig_request(self, method, params, handler, bufnr)
    end
  end,
})

---@type vim.lsp.Config
return {
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
      dotnet_enable_tests_code_lens = false,
    },
    ["csharp|completion"] = {
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
      dotnet_provide_regex_completions = true,
    },
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "openFiles",
      dotnet_compiler_diagnostics_scope = "openFiles",
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
    ["csharp|formatting"] = {
      dotnet_organize_imports_on_format = true,
    },
    razor = {
      language_server = {
        cohosting_enabled = false,
      },
    },
  },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}
