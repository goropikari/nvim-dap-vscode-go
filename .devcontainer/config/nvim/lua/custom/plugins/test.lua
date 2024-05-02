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

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
dapui.setup()

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
-- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- Install golang specific config
dap.adapters.vscode_go = function(callback, config)
  callback({
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath("data") .. "/vscode-go/extension/dist/debugAdapter.js" },
    enrich_config = function(cfg, on_config)
      local final_config = vim.deepcopy(cfg)
      final_config.dlvToolPath = vim.fn.exepath("dlv")
      if cfg.mode == "test" then
        final_config.args = cfg.args or {}
        table.insert(final_config.args, "-test.run")
        table.insert(final_config.args, "^" .. require("dap-go-ts").closest_test().name .. "$")
      end
      on_config(final_config)
    end,
  })
end

dap.configurations.go = dap.configurations.go or {}
table.insert(dap.configurations.go, {
  name = "vscode go",
  type = "vscode_go",
  request = "launch",
  program = "${file}",
})

table.insert(dap.configurations.go, {
  name = "vscode go debug test",
  type = "vscode_go",
  request = "launch",
  mode = "test",
  program = "${file}",
})

table.insert(dap.configurations.go, {
  name = "remote debug vscode go",
  type = "vscode_go",
  request = "attach",
  debugAdapter = "dlv-dap",
  mode = "remote",
  port = 4040,
  host = "127.0.0.1",
  apiVersion = 1,
  -- (remotePath, cmd) を設定するか substitute-path を設定する
  -- remotePath = "/app",
  -- cwd = "/workspaces/nvim-dap-sample/go",
  substitutePath = {
    {
      from = "/workspaces/nvim-dap-sample/go",
      to = "/app",
    },
  },
})
