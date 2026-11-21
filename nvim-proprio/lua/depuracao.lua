vim.pack.add({ "https://github.com/mfussenegger/nvim-dap", "https://github.com/igorlfs/nvim-dap-view" })

local dap = require("dap")

dap.adapters.lldb = { type = "executable", command = "lldb-dap", name = "lldb" }
local lldb = {
  {
    name = "Executável",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input("Executável: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}
dap.configurations.zig = lldb
dap.configurations.c = lldb
dap.configurations.cpp = lldb

dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}
dap.configurations.go = {
  { name = "Arquivo", type = "delve", request = "launch", program = "${file}" },
  { name = "Teste do pacote", type = "delve", request = "launch", mode = "test", program = "${fileDirname}" },
}

require("dap-view").setup({ auto_toggle = true })

local map = vim.keymap.set
map("n", "<F5>", dap.continue, { desc = "Depurar: continuar" })
map("n", "<F9>", dap.toggle_breakpoint, { desc = "Breakpoint" })
map("n", "<F10>", dap.step_over, { desc = "Depurar: próxima linha" })
map("n", "<F11>", dap.step_into, { desc = "Depurar: entrar" })
map("n", "<S-F11>", dap.step_out, { desc = "Depurar: sair" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Depurar: continuar" })
map("n", "<leader>dt", dap.terminate, { desc = "Depurar: encerrar" })
map("n", "<leader>du", "<cmd>DapViewToggle<cr>", { desc = "Interface do depurador" })
