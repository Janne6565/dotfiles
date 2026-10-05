-- General keymaps. Plugin-specific keymaps live next to the plugin in lua/plugins/.
-- Press <Space> and wait for which-key to show everything that is available.
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Better up/down on wrapped lines
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation and resizing
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })
map('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })
map('n', '<leader>w-', '<C-w>s', { desc = 'Split below' })
map('n', '<leader>w|', '<C-w>v', { desc = 'Split right' })
map('n', '<leader>wd', '<C-w>c', { desc = 'Close window' })

-- Buffers
map('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bb', '<cmd>e #<CR>', { desc = 'Switch to other buffer' })

-- Move lines
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<CR>==", { desc = 'Move line down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = 'Move line up' })
map('x', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = 'Move selection down', silent = true })
map('x', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = 'Move selection up', silent = true })

-- Keep selection when indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- Paste over a selection without losing the yanked text
map('x', 'p', '"_dP', { desc = 'Paste without yanking' })

-- Save / quit
map({ 'n', 'i', 'x', 's' }, '<C-s>', '<cmd>write<CR><Esc>', { desc = 'Save file' })
map('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit all' })

-- Diagnostics
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })

-- Toggles
map('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = 'Toggle line wrap' })
map('n', '<leader>td', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, { desc = 'Toggle diagnostics' })
map('n', '<leader>tv', function()
  local cfg = vim.diagnostic.config() or {}
  vim.diagnostic.config { virtual_lines = not cfg.virtual_lines, virtual_text = cfg.virtual_lines and { spacing = 2, prefix = '●' } or false }
end, { desc = 'Toggle diagnostic virtual lines' })

-- Terminal: double <Esc> leaves terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Plugin management
map('n', '<leader>pu', function() vim.pack.update() end, { desc = 'Update plugins' })
map('n', '<leader>pm', '<cmd>Mason<CR>', { desc = 'Mason' })
