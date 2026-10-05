-- Catppuccin (https://github.com/catppuccin/nvim)
-- Flavours: latte (light), frappe, macchiato, mocha (darkest).
-- Try others live with <leader>uC; install alternatives (e.g. folke/tokyonight.nvim) the same way.
vim.pack.add { { src = gh 'catppuccin/nvim', name = 'catppuccin' } }

require('catppuccin').setup {
  flavour = 'mocha',
  transparent_background = false,
  term_colors = true,
  styles = { comments = { 'italic' }, conditionals = {} },
  auto_integrations = true, -- detect installed plugins and theme them
}

vim.cmd.colorscheme 'catppuccin'
