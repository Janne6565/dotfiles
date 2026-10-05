-- snacks.nvim (https://github.com/folke/snacks.nvim)
-- One plugin providing: fuzzy picker, floating terminal, file explorer, lazygit integration,
-- notifications, dashboard, indent guides, nicer vim.ui.input and more.
vim.pack.add { gh 'folke/snacks.nvim' }

local Snacks = require 'snacks'

-- Directories hidden from file search and grep, even when they are not in .gitignore.
-- Matched by name at any depth inside the current project. The explorer (<leader>e) still shows them.
local excluded_dirs = { 'build', 'target', 'out', 'dist', 'node_modules', '.gradle' }

---Picker filter: false for files inside one of `excluded_dirs` in the current project
---@param item snacks.picker.finder.Item
local function outside_excluded_dirs(item)
  -- Runs in a fast (async) context, so only vim.uv/vim.fs calls, no vim.fn
  local rel = item.file and vim.fs.relpath(vim.uv.cwd(), vim.fs.abspath(item.file))
  if not rel then return true end -- files outside the project are never filtered
  for part in vim.gsplit(rel, '/', { plain = true }) do
    if vim.list_contains(excluded_dirs, part) then return false end
  end
  return true
end

Snacks.setup {
  bigfile = { enabled = true }, -- disable heavy features on huge files
  quickfile = { enabled = true }, -- render the file before plugins finish loading
  dashboard = {
    enabled = true,
    preset = {
      header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      keys = {
        { icon = '\u{f002} ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = '\u{f15b} ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = '\u{f0c5} ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = '\u{f1da} ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = '\u{f013} ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = '󰏗 ', key = 'u', desc = 'Update Plugins', action = ':lua vim.pack.update()' },
        { icon = '\u{f426} ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { icon = '\u{f1da} ', title = 'Recent Files', section = 'recent_files', cwd = true, indent = 2, padding = 1 },
    },
  },
  explorer = { enabled = true, replace_netrw = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  picker = {
    enabled = true,
    ui_select = true, -- use the picker for vim.ui.select (code actions etc.)
    sources = {
      files = { hidden = true, exclude = excluded_dirs },
      grep = { hidden = true, exclude = excluded_dirs },
      recent = { filter = { filter = outside_excluded_dirs } },
      explorer = { hidden = true },
    },
  },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  terminal = {
    win = { style = 'float', border = 'rounded', width = 0.85, height = 0.85 },
  },
  words = { enabled = true }, -- highlight references of the word under the cursor (LSP)
  lazygit = { enabled = true },
  styles = { notification = { wo = { wrap = true } } },
}

local map = vim.keymap.set
local P = Snacks.picker

-- Find
map('n', '<leader><space>', function() P.smart() end, { desc = 'Smart find files' })
map('n', '<leader>ff', function() P.files() end, { desc = 'Find files' })
map('n', '<leader>fg', function() P.git_files() end, { desc = 'Find git files' })
map('n', '<leader>fr', function() P.recent() end, { desc = 'Recent files' })
map('n', '<leader>fb', function() P.buffers() end, { desc = 'Buffers' })
map('n', '<leader>fp', function() P.projects() end, { desc = 'Projects' })
map('n', '<leader>fc', function() P.files { cwd = vim.fn.stdpath 'config' } end, { desc = 'Find config file' })
map('n', '<leader>,', function() P.buffers() end, { desc = 'Buffers' })
map('n', '<leader>e', function() Snacks.explorer() end, { desc = 'File explorer' })

-- Search
map('n', '<leader>/', function() P.grep() end, { desc = 'Grep (project)' })
map('n', '<leader>sg', function() P.grep() end, { desc = 'Grep' })
map({ 'n', 'x' }, '<leader>sw', function() P.grep_word() end, { desc = 'Grep word / selection' })
map('n', '<leader>sb', function() P.lines() end, { desc = 'Buffer lines' })
map('n', '<leader>sB', function() P.grep_buffers() end, { desc = 'Grep open buffers' })
map('n', '<leader>sh', function() P.help() end, { desc = 'Help pages' })
map('n', '<leader>sk', function() P.keymaps() end, { desc = 'Keymaps' })
map('n', '<leader>sc', function() P.commands() end, { desc = 'Commands' })
map('n', '<leader>s:', function() P.command_history() end, { desc = 'Command history' })
map('n', '<leader>sd', function() P.diagnostics() end, { desc = 'Diagnostics' })
map('n', '<leader>sD', function() P.diagnostics_buffer() end, { desc = 'Buffer diagnostics' })
map('n', '<leader>sr', function() P.resume() end, { desc = 'Resume last search' })
map('n', '<leader>sq', function() P.qflist() end, { desc = 'Quickfix list' })
map('n', '<leader>sm', function() P.marks() end, { desc = 'Marks' })
map('n', '<leader>sj', function() P.jumps() end, { desc = 'Jumps' })
map('n', '<leader>su', function() P.undo() end, { desc = 'Undo history' })
map('n', '<leader>sn', function() Snacks.notifier.show_history() end, { desc = 'Notification history' })
map('n', '<leader>ss', function() P.lsp_symbols() end, { desc = 'LSP symbols' })
map('n', '<leader>sS', function() P.lsp_workspace_symbols() end, { desc = 'LSP workspace symbols' })
map('n', '<leader>sp', function() P.pickers() end, { desc = 'All pickers' })
map('n', '<leader>uC', function() P.colorschemes() end, { desc = 'Colorschemes' })

-- Git
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })
map('n', '<leader>gl', function() P.git_log() end, { desc = 'Git log' })
map('n', '<leader>gf', function() P.git_log_file() end, { desc = 'Git log (file)' })
map('n', '<leader>gs', function() P.git_status() end, { desc = 'Git status' })
map('n', '<leader>gb', function() P.git_branches() end, { desc = 'Git branches' })
map({ 'n', 'x' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Open in browser' })

-- Floating terminal (the modern replacement for vim-floaterm).
-- <C-/> toggles it from normal and terminal mode; most terminals send <C-_> for <C-/>.
local function term() Snacks.terminal.toggle() end
map({ 'n', 't' }, '<C-/>', term, { desc = 'Toggle terminal' })
map({ 'n', 't' }, '<C-_>', term, { desc = 'which_key_ignore' })
map('n', '<leader>tt', term, { desc = 'Toggle terminal' })
map('n', '<leader>tb', function() Snacks.terminal.toggle(nil, { win = { position = 'bottom', height = 0.3 } }) end, { desc = 'Terminal (bottom split)' })

-- Buffers / misc
map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete buffer' })
map('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Delete other buffers' })
map('n', '<leader>cR', function() Snacks.rename.rename_file() end, { desc = 'Rename file' })
map('n', '<leader>z', function() Snacks.zen() end, { desc = 'Zen mode' })
map('n', '<leader>.', function() Snacks.scratch() end, { desc = 'Scratch buffer' })
map({ 'n', 't' }, ']]', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next reference' })
map({ 'n', 't' }, '[[', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Previous reference' })

-- Toggles that show their state in which-key
Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>ts'
Snacks.toggle.option('relativenumber', { name = 'Relative number' }):map '<leader>tL'
Snacks.toggle.inlay_hints():map '<leader>th'
Snacks.toggle.indent():map '<leader>tg'
Snacks.toggle.dim():map '<leader>tD'
