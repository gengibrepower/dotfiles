vim.pack.add({ "https://github.com/obsidian-nvim/obsidian.nvim" })

require("obsidian").setup({
  legacy_commands = false,
  workspaces = { { name = "notas", path = "~/Notas" } },
  templates = { folder = "Modelos", date_format = "%Y-%m-%d" },
  picker = { name = "snacks.picker" },
  completion = { blink = true },
  note_id_func = require("obsidian.builtin").title_id,
  frontmatter = { enabled = false },
})

local map = vim.keymap.set
map("n", "<leader>ns", "<cmd>Obsidian search<cr>", { desc = "Notas: buscar" })
map("n", "<leader>nf", "<cmd>Obsidian quick_switch<cr>", { desc = "Notas: abrir pelo nome" })
map("n", "<leader>nn", "<cmd>Obsidian new_from_template<cr>", { desc = "Notas: nova a partir de modelo" })
map("n", "<leader>nl", "<cmd>Obsidian follow_link<cr>", { desc = "Notas: seguir link" })
map("n", "<leader>nb", "<cmd>Obsidian backlinks<cr>", { desc = "Notas: quem aponta para esta" })
map("n", "<leader>no", "<cmd>Obsidian open<cr>", { desc = "Notas: abrir no app do Obsidian" })
