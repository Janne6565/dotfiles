-- Git signs in the gutter, hunk actions and blame. Lazygit lives in snacks.lua (<leader>gg).
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }

local gitsigns = require 'gitsigns'
gitsigns.setup {
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '\u{f0da}' },
    topdelete = { text = '\u{f0da}' },
    changedelete = { text = '▎' },
    untracked = { text = '▎' },
  },
  on_attach = function(bufnr)
    local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end

    map('n', ']h', function()
      if vim.wo.diff then return vim.cmd.normal { ']c', bang = true } end
      gitsigns.nav_hunk 'next'
    end, 'Next git hunk')
    map('n', '[h', function()
      if vim.wo.diff then return vim.cmd.normal { '[c', bang = true } end
      gitsigns.nav_hunk 'prev'
    end, 'Previous git hunk')

    map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Reset hunk')
    map('x', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Stage selection')
    map('x', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Reset selection')
    map('n', '<leader>hS', gitsigns.stage_buffer, 'Stage buffer')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'Reset buffer')
    map('n', '<leader>hp', gitsigns.preview_hunk_inline, 'Preview hunk')
    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, 'Blame line')
    map('n', '<leader>hB', gitsigns.blame, 'Blame buffer')
    map('n', '<leader>hd', gitsigns.diffthis, 'Diff against index')
    map('n', '<leader>hD', function() gitsigns.diffthis '~' end, 'Diff against last commit')
    map('n', '<leader>tB', gitsigns.toggle_current_line_blame, 'Toggle inline blame')
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Inside hunk')
  end,
}
