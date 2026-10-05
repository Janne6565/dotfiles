-- Icons (also provides a nvim-web-devicons shim for plugins that expect it)
vim.pack.add { gh 'nvim-mini/mini.nvim' }
require('mini.icons').setup { style = vim.g.have_nerd_font and 'glyph' or 'ascii' }
MiniIcons.mock_nvim_web_devicons()

-- which-key: shows pending keybinds. Press <Space> and wait.
vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  preset = 'helix',
  delay = 300,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>b', group = 'buffer' },
    { '<leader>c', group = 'code', mode = { 'n', 'x' } },
    { '<leader>d', group = 'debug' },
    { '<leader>f', group = 'find' },
    { '<leader>g', group = 'git', mode = { 'n', 'x' } },
    { '<leader>h', group = 'git hunk', mode = { 'n', 'x' } },
    { '<leader>j', group = 'java', mode = { 'n', 'x' } },
    { '<leader>p', group = 'plugins' },
    { '<leader>q', group = 'quit/session' },
    { '<leader>s', group = 'search', mode = { 'n', 'x' } },
    { '<leader>t', group = 'toggle/terminal' },
    { '<leader>u', group = 'ui' },
    { '<leader>w', group = 'window' },
    { 'gs', group = 'surround', mode = { 'n', 'x' } },
    { '<leader>x', group = 'diagnostics/quickfix' },
    { 'gr', group = 'LSP' },
    { '[', group = 'prev' },
    { ']', group = 'next' },
  },
}
vim.keymap.set('n', '<leader>?', function() require('which-key').show { global = false } end, { desc = 'Buffer keymaps' })

-- Statusline
vim.pack.add { gh 'nvim-lualine/lualine.nvim' }
require('lualine').setup {
  options = {
    theme = 'auto',
    globalstatus = true,
    icons_enabled = vim.g.have_nerd_font,
    component_separators = '',
    section_separators = vim.g.have_nerd_font and { left = '\u{e0b4}', right = '\u{e0b6}' } or '',
    disabled_filetypes = { statusline = { 'snacks_dashboard' } },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
    lualine_c = { 'diagnostics', { 'filename', path = 1 } },
    lualine_x = {
      {
        function()
          return table.concat(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients { bufnr = 0 }), ', ')
        end,
        icon = vim.g.have_nerd_font and '\u{f085} ' or 'LSP:',
      },
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

-- Buffer tabs at the top
vim.pack.add { { src = gh 'akinsho/bufferline.nvim', version = vim.version.range '4.*' } }
require('bufferline').setup {
  highlights = require('catppuccin.special.bufferline').get_theme(),
  options = {
    close_command = function(n) Snacks.bufdelete(n) end,
    diagnostics = 'nvim_lsp',
    always_show_bufferline = false,
    show_buffer_close_icons = false,
    offsets = { { filetype = 'snacks_layout_box' } },
  },
}
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<CR>', { desc = 'Pin buffer' })
vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<CR>', { desc = 'Close unpinned buffers' })

-- Highlight and search TODO/FIXME/NOTE comments
vim.pack.add { gh 'folke/todo-comments.nvim' }
require('todo-comments').setup { signs = false }
vim.keymap.set('n', '<leader>st', function() Snacks.picker.todo_comments() end, { desc = 'TODO comments' })
vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'Next TODO' })
vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'Previous TODO' })

-- Diagnostics / quickfix / references list
vim.pack.add { gh 'folke/trouble.nvim' }
require('trouble').setup {}
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<CR>', { desc = 'Symbols outline (Trouble)' })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix list (Trouble)' })
vim.keymap.set('n', '<leader>xt', '<cmd>Trouble todo toggle<CR>', { desc = 'TODOs (Trouble)' })
