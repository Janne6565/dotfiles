-- Language servers.
-- Server configs come from nvim-lspconfig and are enabled with the native `vim.lsp.enable()`.
-- Binaries are installed by Mason (:Mason). Java is special and set up in java.lua.
vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  gh 'b0o/SchemaStore.nvim', -- JSON/YAML schemas (package.json, GitHub workflows, docker-compose, ...)
  gh 'j-hui/fidget.nvim', -- LSP progress in the corner
}

require('mason').setup { ui = { border = 'rounded' } }
require('fidget').setup {}

-- Add a server: put its lspconfig name here (see `:help lspconfig-all`) and its Mason package below.
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        format = { enable = false }, -- stylua formats Lua
        hint = { enable = true },
      },
    },
    on_init = function(client)
      -- When editing the Neovim config, teach lua_ls about the Neovim runtime
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
      })
    end,
  },
  jsonls = {
    before_init = function(_, config) config.settings.json.schemas = require('schemastore').json.schemas() end,
    settings = { json = { validate = { enable = true } } },
  },
  yamlls = {
    before_init = function(_, config) config.settings.yaml.schemas = require('schemastore').yaml.schemas() end,
    settings = { yaml = { schemaStore = { enable = false, url = '' } } },
  },
  lemminx = {}, -- XML (pom.xml)
  bashls = {},
}

-- Everything Mason should install (Mason package names, see :Mason)
require('mason-tool-installer').setup {
  ensure_installed = {
    -- language servers
    'lua-language-server',
    'json-lsp',
    'yaml-language-server',
    'lemminx',
    'bash-language-server',
    -- java (see java.lua)
    'jdtls',
    'java-debug-adapter',
    'java-test',
    -- formatters
    'stylua',
    'shfmt',
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

-- Keymaps, set when a server attaches to a buffer.
-- Neovim already provides: K hover, grn rename, gra code action, grr references,
-- gri implementation, grt type definition, gO document symbols.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(ev)
    local function map(keys, fn, desc, mode) vim.keymap.set(mode or 'n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc }) end
    local P = Snacks.picker

    map('gd', P.lsp_definitions, 'Goto definition')
    map('gD', P.lsp_declarations, 'Goto declaration')
    map('grr', P.lsp_references, 'References')
    map('gri', P.lsp_implementations, 'Goto implementation')
    map('grt', P.lsp_type_definitions, 'Goto type definition')
    map('gO', P.lsp_symbols, 'Document symbols')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    map('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>cl', function() Snacks.picker.lsp_config() end, 'LSP info')
    map('<leader>ci', P.lsp_incoming_calls, 'Incoming calls')
    map('<leader>co', P.lsp_outgoing_calls, 'Outgoing calls')

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/inlayHint', ev.buf) then vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf }) end
    if client and client:supports_method('textDocument/codeLens', ev.buf) then
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
      map('<leader>cc', vim.lsp.codelens.run, 'Run codelens')
    end
  end,
})
