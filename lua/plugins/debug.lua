-- Debugging with nvim-dap + nvim-dap-view.
-- Java debugging is wired up automatically by nvim-jdtls (see java.lua).
vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'igorlfs/nvim-dap-view',
  gh 'theHamsta/nvim-dap-virtual-text',
}

local dap = require 'dap'
local dv = require 'dap-view'

dv.setup { auto_toggle = true } -- open the view when a session starts, close it when it ends
require('nvim-dap-virtual-text').setup {}

if vim.g.have_nerd_font then
  for name, icon in pairs {
    Breakpoint = '\u{f111}',
    BreakpointCondition = '\u{f059}',
    BreakpointRejected = '\u{f05e}',
    LogPoint = '\u{f075}',
    Stopped = '\u{f061}',
  } do
    local hl = name == 'Stopped' and 'DiagnosticWarn' or 'DiagnosticError'
    vim.fn.sign_define('Dap' .. name, { text = icon, texthl = hl, numhl = hl })
  end
end

local map = vim.keymap.set
map('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
map('n', '<F10>', dap.step_over, { desc = 'Debug: Step over' })
map('n', '<F11>', dap.step_into, { desc = 'Debug: Step into' })
map('n', '<F12>', dap.step_out, { desc = 'Debug: Step out' })
map('n', '<leader>dc', dap.continue, { desc = 'Start/Continue' })
map('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
map('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Conditional breakpoint' })
map('n', '<leader>dl', dap.run_last, { desc = 'Run last' })
map('n', '<leader>dr', dap.restart, { desc = 'Restart' })
map('n', '<leader>dt', dap.terminate, { desc = 'Terminate' })
map('n', '<leader>du', dv.toggle, { desc = 'Toggle debug view' })
map({ 'n', 'x' }, '<leader>de', function() require('dap.ui.widgets').hover() end, { desc = 'Evaluate expression' })
