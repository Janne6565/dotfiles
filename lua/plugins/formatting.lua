-- Formatting with conform.nvim. Falls back to the language server (e.g. jdtls for Java)
-- when no dedicated formatter is configured for a filetype.
-- Format on save is on by default; toggle it with <leader>tf (global) or <leader>tF (buffer).
vim.pack.add { gh 'stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = true,
  formatters_by_ft = {
    lua = { 'stylua' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
  },
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = 1500 }
  end,
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ 'n', 'x' }, '<leader>cf', function() require('conform').format { async = true } end, { desc = 'Format' })

Snacks.toggle
  .new({
    name = 'Format on save (global)',
    get = function() return not vim.g.disable_autoformat end,
    set = function(state) vim.g.disable_autoformat = not state end,
  })
  :map '<leader>tf'
Snacks.toggle
  .new({
    name = 'Format on save (buffer)',
    get = function() return not vim.b.disable_autoformat end,
    set = function(state) vim.b.disable_autoformat = not state end,
  })
  :map '<leader>tF'
