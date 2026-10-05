-- See `:help option-list`
local o = vim.o

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true
o.showmode = false -- the statusline shows the mode
o.termguicolors = true
o.winborder = 'rounded' -- borders for floating windows (hover, signature help, ...)
o.pumheight = 12
o.laststatus = 3 -- one global statusline
o.cmdheight = 1
o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars = { eob = ' ', fold = ' ', foldopen = '\u{f107}', foldclose = '\u{f105}', foldsep = ' ' }
o.wrap = false
o.linebreak = true
o.breakindent = true
o.scrolloff = 8
o.sidescrolloff = 8
o.smoothscroll = true

-- Editing
o.mouse = 'a'
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.shiftround = true
o.smartindent = true
o.virtualedit = 'block'
o.confirm = true
o.undofile = true
o.undolevels = 10000
o.swapfile = false
o.completeopt = 'menu,menuone,noselect'

-- Sync with the system clipboard (scheduled because it can slow down startup)
vim.schedule(function() o.clipboard = 'unnamedplus' end)

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = 'split' -- live preview of :substitute
o.grepprg = 'rg --vimgrep'
o.grepformat = '%f:%l:%c:%m'

-- Windows
o.splitright = true
o.splitbelow = true
o.splitkeep = 'screen'

-- Timing
o.updatetime = 250
o.timeoutlen = 300

-- Folding: treesitter based, everything open by default
o.foldlevel = 99
o.foldlevelstart = 99
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldtext = ''

-- Diagnostics
vim.diagnostic.config {
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  float = { source = 'if_many' },
  virtual_text = { spacing = 2, source = 'if_many', prefix = '●' },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  jump = {
    on_jump = function(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false } end,
  },
}
