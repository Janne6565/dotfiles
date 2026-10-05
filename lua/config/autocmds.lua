local function augroup(name) return vim.api.nvim_create_augroup('user-' .. name, { clear = true }) end

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = augroup 'highlight-yank',
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore last cursor position',
  group = augroup 'last-position',
  callback = function(ev)
    if vim.tbl_contains({ 'gitcommit', 'gitrebase' }, vim.bo[ev.buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Equalize splits when the terminal is resized',
  group = augroup 'resize-splits',
  command = 'tabdo wincmd =',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close helper windows with q',
  group = augroup 'close-with-q',
  pattern = { 'help', 'qf', 'man', 'lspinfo', 'checkhealth', 'notify', 'dap-float', 'nvim-pack' },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = ev.buf, silent = true, desc = 'Close window' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Wrap and spell-check prose',
  group = augroup 'prose',
  pattern = { 'markdown', 'gitcommit', 'text' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Create missing parent directories on save',
  group = augroup 'auto-mkdir',
  callback = function(ev)
    if ev.match:match '^%w%w+:[\\/][\\/]' then return end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})
