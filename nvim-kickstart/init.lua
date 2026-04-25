vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require 'options'
require 'keymaps'
-- require 'colorscheme'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  vim.diagnostic.config { jump = { on_jump = vim.diagnostic.open_float } },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_user_command('LspLog', function() vim.cmd('edit ' .. vim.lsp.log.get_filename()) end, {})

local init_handles = {}
vim.api.nvim_create_autocmd('User', {
  pattern = 'RoslynOnInit',
  callback = function(ev)
    local message = ev.data.type == 'solution' and string.format('Initializing Roslyn for %s', ev.data.target) or 'Initializing Roslyn for project'

    init_handles[ev.data.client_id] = vim.api.nvim_echo({ { message } }, false, {
      id = 'roslyn.' .. ev.data.client_id,
      kind = 'progress',
      source = 'roslyn',
      title = 'Initializing Roslyn for project',
      status = 'running',
      percent = 10,
    })
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'RoslynInitialized',
  callback = function(ev)
    local handle = init_handles[ev.data.client_id]
    init_handles[ev.data.client_id] = nil

    if handle then
      vim.api.nvim_echo({ { 'Roslyn initialized' } }, false, {
        id = handle,
        kind = 'progress',
        source = 'roslyn',
        title = 'Initializing Roslyn for project',
        status = 'running',
        percent = 100,
      })
    end
  end,
})

require 'lazy-bootstrap'
-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
--
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cs' },
  callback = function()
    vim.b.autoformat = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- TODO: Experimental
-- vim.o.cmdheight = 0
-- require('vim._core.ui2').enable {
--   enable = true, -- Whether to enable or disable the UI.
--   msg = { -- Options related to the message module.
--     ---@type 'cmd'|'msg' Default message target, either in the
--     ---cmdline or in a separate ephemeral message window.
--     ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
--     ---or table mapping |ui-messages| kinds and triggers to a target.
--     targets = 'cmd',
--     cmd = { -- Options related to messages in the cmdline window.
--       height = 0.5, -- Maximum height while expanded for messages beyond 'cmdheight'.
--     },
--     dialog = { -- Options related to dialog window.
--       height = 0.5, -- Maximum height.
--     },
--     msg = { -- Options related to msg window.
--       height = 0.5, -- Maximum height.
--       timeout = 4000, -- Time a message is visible in the message window.
--     },
--     pager = { -- Options related to message window.
--       height = 1, -- Maximum height.
--     },
--   },
-- }

require('lazy').setup(
  {
    -- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
    { 'NMAC427/guess-indent.nvim', opts = {} },
    --
    -- See `:help gitsigns` to understand what the configuration keys do
    -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
    --
    -- This is often very useful to both group configuration, as well as handle
    -- lazy loading plugins that don't need to be loaded immediately at startup.
    --
    -- For example, in the following configuration, we use:
    --  event = 'VimEnter'
    --
    -- which loads which-key before all the UI elements are loaded. Events can be
    -- normal autocommands events (`:help autocmd-events`).
    --
    -- Then, because we use the `opts` key (recommended), the configuration runs
    -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

    { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter',
      ---@module 'which-key'
      ---@type wk.Opts
      ---@diagnostic disable-next-line: missing-fields
      opts = {
        preset = 'helix',
        -- delay between pressing a key and opening which-key (milliseconds)
        delay = 0,
        icons = { mappings = vim.g.have_nerd_font },

        -- Document existing key chains
        spec = {
          { '<leader>s', group = '+[S]earch', mode = { 'n', 'v' } },
          -- { '<leader>t', group = '[T]oggle' },
          { '<leader>g', group = '+[G]it', mode = { 'n', 'v' } },
          { '<leader>gh', group = '+[G]it [H]unk', mode = { 'n', 'v' } },
          { '<leader>c', group = '+[C]ode', mode = { 'n' } },
          { 'gr', group = 'LSP Actions', mode = { 'n' } },
        },
      },
    },
    -- NOTE: Plugins can specify dependencies.
    --
    -- The dependencies are proper plugin specifications as well - anything
    -- you do for a plugin at the top level, you can do for a dependency.
    --
    -- Use the `dependencies` key to specify the dependencies of a particular plugin

    -- LSP Plugins
    {
      -- Main LSP Configuration
      'neovim/nvim-lspconfig',
      dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        -- Mason must be loaded before its dependents so we need to set it up here.
        -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
        {
          'mason-org/mason.nvim',
          ---@module 'mason.settings'
          ---@type MasonSettings
          ---@diagnostic disable-next-line: missing-fields
          opts = {
            registries = {
              'github:mason-org/mason-registry',
              'github:Crashdummyy/mason-registry',
            },
          },
        },
        -- Maps LSP server names between nvim-lspconfig and Mason package names.
        'mason-org/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP.
        { 'j-hui/fidget.nvim', enabled = false, opts = {} },
      },
      config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
          callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            map('<leader>cr', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client:supports_method('textDocument/documentHighlight', event.buf) then
              local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })

              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                end,
              })
            end

            -- The following code creates a keymap to toggle inlay hints in your
            -- code, if the language server you are using supports them
            --
            -- This may be unwanted, since they displace some of your code
            if client and client:supports_method('textDocument/inlayHint', event.buf) then
              map('<leader>uh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
            end

            vim.api.nvim_create_autocmd('LspProgress', {
              buffer = event.buf,
              callback = function(ev)
                local value = ev.data.params.value
                vim.api.nvim_echo({ { value.message or 'done' } }, false, {
                  id = 'lsp.' .. ev.data.params.token,
                  kind = 'progress',
                  source = 'vim.lsp',
                  title = value.title,
                  status = value.kind ~= 'end' and 'running' or 'success',
                  percent = value.percentage,
                })
              end,
            })
          end,
        })

        ---@type table<string, vim.lsp.Config>
        local servers = {
          -- TODO: Is this better than on LspAttach?
          -- ['*'] = {
              -- stylua: ignore
              -- keys = {
                -- { "gd",         function() Snacks.picker.lsp_definitions() end,                                              desc = "Goto Definition",       has = "definition" },
                -- { "gr",         function() Snacks.picker.lsp_references() end,                                               nowait = true,                  desc = "References" },
                -- { "gI",         function() Snacks.picker.lsp_implementations() end,                                          desc = "Goto Implementation" },
                -- { "gy",         function() Snacks.picker.lsp_type_definitions() end,                                         desc = "Goto T[y]pe Definition" },
                -- { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter }) end,           desc = "LSP Symbols",           has = "documentSymbol" },
                -- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
                -- { "gai",        function() Snacks.picker.lsp_incoming_calls() end,                                           desc = "C[a]lls Incoming",      has = "callHierarchy/incomingCalls" },
                -- { "gao",        function() Snacks.picker.lsp_outgoing_calls() end,                                           desc = "C[a]lls Outgoing",      has = "callHierarchy/outgoingCalls" },
          --     },
          -- },

          powershell_es = {
            bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services"
          },
          stylua = {}, -- Used to format Lua code

          -- Special Lua Config, as recommended by neovim help docs
          lua_ls = {
            on_init = function(client)
              client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
              end

              client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                  version = 'LuaJIT',
                  path = { 'lua/?.lua', 'lua/?/init.lua' },
                },
                workspace = {
                  checkThirdParty = false,
                  -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                  --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                  library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                    '${3rd}/luv/library',
                    '${3rd}/busted/library',
                    'snacks.nvim',
                  }),
                },
              })
            end,
            ---@type lspconfig.settings.lua_ls
            settings = {
              Lua = {
                format = { enable = false }, -- Disable formatting (formatting is done by stylua)
              },
            },
          },
        }

        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
          -- You can add other tools here that you want Mason to install
        })

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        for name, server in pairs(servers) do
          vim.lsp.config(name, server)
          vim.lsp.enable(name)
        end
      end,
    },

    {
      'seblyng/roslyn.nvim',
      ---@module 'roslyn.config'
      ---@type RoslynNvimConfig
      opts = {
        silent = true,
        -- filewatching = 'roslyn',
        extensions = {
          ---@diagnostic disable-next-line: missing-fields
          razor = {
            enabled = false,
          },
        },
        -- your configuration comes here; leave empty for default settings
      },
    },
    { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      cmd = { 'ConformInfo' },
      keys = {
        {
          '<leader>f',
          function() require('conform').format { async = true } end,
          mode = '',
          desc = '[F]ormat buffer',
        },
      },
      ---@module 'conform'
      ---@type conform.setupOpts
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- You can specify filetypes to autoformat on save here:
          local enabled_filetypes = {
            lua = true,
            -- python = true,
          }
          if enabled_filetypes[vim.bo[bufnr].filetype] then
            return { timeout_ms = 500 }
          else
            return nil
          end
        end,
        default_format_opts = {
          lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
        },
        -- You can also specify external formatters in here.
        formatters_by_ft = {
          -- rust = { 'rustfmt' },
          -- Conform can also run multiple formatters sequentially
          -- python = { "isort", "black" },
          --
          -- You can use 'stop_after_first' to run the first available formatter from the list
          -- javascript = { "prettierd", "prettier", stop_after_first = true },
        },
      },
    },

    { -- Autocompletion
      'saghen/blink.cmp',
      event = 'VimEnter',
      version = '1.*',
      dependencies = {
        -- Snippet Engine
        {
          'L3MON4D3/LuaSnip',
          version = '2.*',
          build = (function()
            -- Build Step is needed for regex support in snippets.
            -- This step is not supported in many windows environments.
            -- Remove the below condition to re-enable on windows.
            if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
            return 'make install_jsregexp'
          end)(),
          dependencies = {
            -- `friendly-snippets` contains a variety of premade snippets.
            --    See the README about individual language/framework/plugin snippets:
            --    https://github.com/rafamadriz/friendly-snippets
            {
              'rafamadriz/friendly-snippets',
              config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
            },
          },
          opts = {},
        },
      },
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = {
          -- 'default' (recommended) for mappings similar to built-in completions
          --   <c-y> to accept ([y]es) the completion.
          --    This will auto-import if your LSP supports it.
          --    This will expand snippets if the LSP sent a snippet.
          -- 'super-tab' for tab to accept
          -- 'enter' for enter to accept
          -- 'none' for no mappings
          --
          -- For an understanding of why the 'default' preset is recommended,
          -- you will need to read `:help ins-completion`
          --
          -- No, but seriously. Please read `:help ins-completion`, it is really good!
          --
          -- All presets have the following mappings:
          -- <tab>/<s-tab>: move to right/left of your snippet expansion
          -- <c-space>: Open menu or open docs if already open
          -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
          -- <c-e>: Hide menu
          -- <c-k>: Toggle signature help
          --
          -- See :h blink-cmp-config-keymap for defining your own keymap
          preset = 'enter',

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },

        appearance = {
          -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono',
        },

        completion = {
          -- By default, you may press `<c-space>` to show the documentation.
          -- Optionally, set `auto_show = true` to show the documentation after a delay.
          documentation = { auto_show = false, auto_show_delay_ms = 500 },
        },

        sources = {
          default = { 'lsp', 'path', 'snippets' },
        },

        snippets = { preset = 'luasnip' },

        -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
        -- which automatically downloads a prebuilt binary when enabled.
        --
        -- By default, we use the Lua implementation instead, but you may enable
        -- the rust implementation via `'prefer_rust_with_warning'`
        --
        -- See :h blink-cmp-config-fuzzy for more information
        fuzzy = { implementation = 'prefer_rust_with_warning' },

        -- Shows a signature help window while you type arguments for a function
        signature = { enabled = true },
      },
    },

    -- Highlight todo, notes, etc in comments
    {
      'folke/todo-comments.nvim',
      event = 'VimEnter',
      dependencies = { 'nvim-lua/plenary.nvim' },
      ---@module 'todo-comments'
      ---@type TodoOptions
      ---@diagnostic disable-next-line: missing-fields
      opts = { signs = false },
    },

    { -- Collection of various small independent plugins/modules
      'nvim-mini/mini.nvim',
      config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup {
          -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
          mappings = {
            around_next = 'aa',
            inside_next = 'ii',
          },
          n_lines = 500,
        }

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        local statusline = require 'mini.statusline'
        -- set use_icons to true if you have a Nerd Font
        statusline.setup { use_icons = vim.g.have_nerd_font }

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function() return '%2l:%-2v' end

        -- ... and there is more!
        --  Check out: https://github.com/nvim-mini/mini.nvim
      end,
    },

    { -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      branch = 'main',
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
      config = function()
        -- ensure basic parser are installed
        local parsers = { 'regex', 'bash', 'c', 'c_sharp', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
        require('nvim-treesitter').install(parsers)

        ---@param buf integer
        ---@param language string
        local function treesitter_try_attach(buf, language)
          -- check if parser exists and load it
          if not vim.treesitter.language.add(language) then return end
          -- enables syntax highlighting and other treesitter features
          vim.treesitter.start(buf, language)

          -- enables treesitter based folds
          -- for more info on folds see `:help folds`
          -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- vim.wo.foldmethod = 'expr'

          -- check if an treesitter 'indents' query exists, since not all languages supports it
          -- this looks for indents.scm query path
          local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

          -- in case there is no indents query for a language, neovim will fallback into vim's built in one
          if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
        end

        local available_parsers = require('nvim-treesitter').get_available()
        vim.api.nvim_create_autocmd('FileType', {
          callback = function(args)
            local buf, filetype = args.buf, args.match

            local language = vim.treesitter.language.get_lang(filetype)
            if not language then return end

            local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

            if vim.tbl_contains(installed_parsers, language) then
              -- enable the parser if it is installed
              treesitter_try_attach(buf, language)
            elseif vim.tbl_contains(available_parsers, language) then
              -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
              require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
            else
              -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
              treesitter_try_attach(buf, language)
            end
          end,
        })
      end,
    },

    -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- place them in the correct locations.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
    require 'kickstart.plugins.autopairs',
    -- require 'kickstart.plugins.neo-tree',
    require 'kickstart.plugins.gitsigns', -- adds gitsigns recommended keymaps
      -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
      --    This is the easiest way to modularize your config.
      --
      --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
      { import = 'custom.plugins' },
  },
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
  { ---@diagnostic disable-line: missing-fields
    ui = {
      -- If you are using a Nerd Font: set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
      border = vim.o.winborder,
    },
  }
)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
