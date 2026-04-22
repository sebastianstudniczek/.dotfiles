return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.csharpier)

      local import_fix = require("import-missing-namespaces")
      nls.register({
        name = "roslyn_fix_all_imports",
        method = nls.methods.CODE_ACTION,
        filetypes = { "cs" },
        generator = {
          fn = function(params)
            if not import_fix.has_missing_import_diagnostic(params.bufnr) then
              return {}
            end

            return {
              {
                title = "Fix all missing imports",
                action = function()
                  import_fix.run(params.bufnr)
                end,
              },
            }
          end,
        },
      })
    end,
  },
}
