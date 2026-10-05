-- Snippets
vim.pack.add {
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
  gh 'rafamadriz/friendly-snippets', -- community snippets for many languages (incl. Java)
}
require('luasnip').setup {}
require('luasnip.loaders.from_vscode').lazy_load()

-- Completion: blink.cmp (https://cmp.saghen.dev)
-- Keys: <Tab>/<S-Tab> or <C-n>/<C-p> to navigate, <CR> to accept, <C-Space> to open, <C-e> to close,
--       <C-k> toggles signature help.
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
  },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    list = { selection = { preselect = false, auto_insert = false } },
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
    menu = { draw = { treesitter = { 'lsp' } } },
  },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  snippets = { preset = 'luasnip' },
  -- Downloads a prebuilt Rust fuzzy matcher for the tagged release; falls back to Lua if that fails
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
  cmdline = { completion = { menu = { auto_show = true } } },
}
