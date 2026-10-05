-- Detect tabstop/shiftwidth from the file contents
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

-- mini.nvim modules (https://github.com/nvim-mini/mini.nvim)
vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- Better text objects: va), yinq (inside next quote), ci' ...
require('mini.ai').setup { n_lines = 500 }

-- Surround: gsaiw) add, gsd' delete, gsr)' replace (`s` is used by flash below)
require('mini.surround').setup {
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
  },
}

-- Auto pairs for brackets and quotes
require('mini.pairs').setup {
  modes = { insert = true, command = false, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { 'string' },
  skip_unbalanced = true,
  markdown = true,
}

-- gS splits/joins arguments, lists and tables over multiple lines
require('mini.splitjoin').setup()

-- Jump anywhere on screen: press s, then type the characters you see
vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup { modes = { search = { enabled = false } } }
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter select' })
