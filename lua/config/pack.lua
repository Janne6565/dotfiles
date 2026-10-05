-- Helpers around the built-in plugin manager. See `:help vim.pack`.
--
-- Plugins are installed on first start and pinned in nvim-pack-lock.json (commit it!).
-- Update with `:lua vim.pack.update()` (or <leader>pu), review, then `:write` to apply.

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local output = (result.stderr ~= '' and result.stderr) or result.stdout or 'no output'
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- Post-install / post-update build steps. Must be registered before `vim.pack.add()`.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('user-pack-build', { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'LuaSnip' and vim.fn.has 'win32' == 0 and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
    elseif name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end
  end,
})

---Shorthand for a GitHub plugin URL
---@param repo string
---@return string
function _G.gh(repo) return 'https://github.com/' .. repo end
