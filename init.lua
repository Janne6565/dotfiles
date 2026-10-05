-- Neovim configuration
--
-- Requires Neovim 0.12+ (uses the built-in plugin manager `vim.pack`, see `:help vim.pack`).
--
-- Layout:
--   lua/config/   core editor settings (options, keymaps, autocmds, plugin manager helpers)
--   lua/plugins/  one file per plugin area, loaded in the order listed below
--
-- Useful commands:
--   :lua vim.pack.update()   update all plugins (review the diff, then `:write` to confirm)
--   :Mason                   manage language servers, formatters and debuggers
--   :checkhealth             diagnose problems

if vim.fn.has 'nvim-0.12' == 0 then
  vim.api.nvim_echo({ { 'This config requires Neovim 0.12 or newer', 'ErrorMsg' } }, true, {})
  return
end

vim.loader.enable()

-- Leader must be set before any plugin or keymap is defined
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to false if your terminal does not use a Nerd Font (https://www.nerdfonts.com)
vim.g.have_nerd_font = true

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.pack'

-- Order matters: the colorscheme comes first so every later plugin picks up its highlights
require 'plugins.colorscheme'
require 'plugins.snacks' -- picker, floating terminal, explorer, lazygit, notifications, dashboard
require 'plugins.ui'
require 'plugins.editor'
require 'plugins.git'
require 'plugins.treesitter'
require 'plugins.completion'
require 'plugins.lsp'
require 'plugins.formatting'
require 'plugins.debug'
require 'plugins.java'

-- Drop machine-local tweaks in lua/local.lua (git-ignored)
pcall(require, 'local')
