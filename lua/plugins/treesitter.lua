-- Treesitter: syntax highlighting, indentation and folding.
-- Uses the `main` branch of nvim-treesitter, which requires the `tree-sitter` CLI and a C compiler.
-- Parsers for other languages are installed automatically the first time you open such a file.
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

local ts = require 'nvim-treesitter'

ts.install {
  'bash',
  'css',
  'diff',
  'dockerfile',
  'git_config',
  'gitcommit',
  'gitignore',
  'groovy', -- build.gradle
  'html',
  'java',
  'javascript',
  'json',
  'kotlin', -- build.gradle.kts
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'properties',
  'python',
  'query',
  'regex',
  'sql',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'xml', -- pom.xml
  'yaml',
}

local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(lang) then return end
  vim.treesitter.start(buf, lang)
  if vim.treesitter.query.get(lang, 'indents') then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available = ts.get_available()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then return end
    if vim.tbl_contains(ts.get_installed 'parsers', lang) or not vim.tbl_contains(available, lang) then
      attach(ev.buf, lang)
    else
      ts.install(lang):await(function() attach(ev.buf, lang) end)
    end
  end,
})

-- Shows the current function/class at the top of the window while scrolling
vim.pack.add { gh 'nvim-treesitter/nvim-treesitter-context' }
require('treesitter-context').setup { max_lines = 3 }
vim.keymap.set('n', '<leader>tc', '<cmd>TSContext toggle<CR>', { desc = 'Toggle treesitter context' })
