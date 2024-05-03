local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      return message
    end,
  },
}, neotest_ns)

require("neotest").setup({
  status = { virtual_text = true },
  output = { open_on_run = true },
  -- your neotest config here
  adapters = {
    require("neotest-go")({
      args = { "--shuffle=on" },
    }),
  },
})

-- [[ Configuration DAP ]]
local dap = require("dap")
local dapui = require("dapui")
require("nvim-dap-virtual-text").setup({})
require("telescope").load_extension("dap")
require('dap-vscode-go').setup()

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
dapui.setup()

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
-- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close
