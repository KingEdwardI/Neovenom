local lspconfig = require('lspconfig')
local config = require('lsp.config')
local utils = require('utils')
local ts_utils = require('nvim-lsp-ts-utils')
local null_ls = require('null-ls')

local builtins = null_ls.builtins
local buf_map = utils.buf_map

lspconfig.tsserver.setup({
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false

    -- defaults
    ts_utils.setup({
      debug = false,
      disable_commands = false,
      enable_import_on_completion = true,

      -- import all
      import_all_timeout = 5000, -- ms
      import_all_scan_buffers = 100,
      import_all_select_source = false,

      -- filter diagnostics
      filter_out_diagnostics_by_severity = {},
      filter_out_diagnostics_by_code = { 80001 },

      -- inlay hints
      auto_inlay_hints = true,
      inlay_hints_highlight = 'Comment',

      -- update imports on file move
      update_imports_on_move = true,
      require_confirmation_on_move = false,
      watch_dir = nil,

      -- Enable ESLint diagnostics
      eslint_enable_diagnostics = true,
      eslint_bin = 'eslint_d', -- Also doesn't work with 'eslint'

      -- Enable formatting using eslint_d
      enable_formatting = true,
      formatter = 'eslint_d',
    })

    -- required to fix code action ranges and filter diagnostics
    ts_utils.setup_client(client)

    -- no default maps, so you may want to define some here
    buf_map(bufnr, 'n', '<leader>im', ':TSLspImportCurrent<cr>')
    buf_map(bufnr, 'n', '<leader>ii', ':TSLspImportAll<cr>')

    config.on_attach(client, bufnr)
  end,
  init_options = ts_utils.init_options,
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_dir = require('lspconfig/util').root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git'),
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
})

null_ls.setup({
  sources = {
    -- Javascript
    builtins.diagnostics.eslint_d, -- eslint or eslint_d
    builtins.code_actions.eslint_d, -- eslint or eslint_d
    builtins.formatting.eslint_d, -- prettier, eslint, eslint_d, or prettierd

    -- Lua
    builtins.formatting.stylua,
    builtins.diagnostics.luacheck.with({ extra_args = { '--global vim' } }),
  },
  on_attach = config.on_attach,
})
