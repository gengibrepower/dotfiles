vim.pack.add({ "https://github.com/folke/snacks.nvim" })

local Snacks = require("snacks")
Snacks.setup({
  picker = {
    sources = {
      projects = {
        projects = { "~/Projects/BairdWire", "~/Projects/dotfiles", "~/Faculdade/AMPS", "~/Faculdade/Merlian" },
      },
    },
  },
  notifier = { enabled = true },
  lazygit = { enabled = true },
})

local map = vim.keymap.set
map("n", "<leader><space>", function() Snacks.picker.files() end, { desc = "Arquivos" })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "Símbolos do arquivo" })
map("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Símbolos do projeto" })
map("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnósticos" })
map("n", "<leader>sr", function() Snacks.picker.lsp_references() end, { desc = "Referências" })
map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projetos" })
map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recentes" })
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "lazygit" })
map("n", "<leader>sn", function() Snacks.notifier.show_history() end, { desc = "Notificações" })
