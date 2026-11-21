vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim", "https://github.com/sindrets/diffview.nvim" })

require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function map(modo, tecla, acao, desc)
      vim.keymap.set(modo, tecla, acao, { buffer = buf, desc = desc })
    end
    map("n", "]h", function() gs.nav_hunk("next") end, "Próximo trecho")
    map("n", "[h", function() gs.nav_hunk("prev") end, "Trecho anterior")
    map({ "n", "x" }, "<leader>hs", ":Gitsigns stage_hunk<cr>", "Stage do trecho")
    map({ "n", "x" }, "<leader>hr", ":Gitsigns reset_hunk<cr>", "Reset do trecho")
    map("n", "<leader>hp", gs.preview_hunk_inline, "Ver trecho")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame da linha")
    map("n", "<leader>hB", gs.blame, "Blame do arquivo")
  end,
})

require("diffview").setup({})

local function branch_principal()
  local remota = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })[1]
  if vim.v.shell_error == 0 and remota then
    return remota
  end
  vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", "main" })
  return vim.v.shell_error == 0 and "main" or "master"
end

vim.keymap.set("n", "<leader>gd", function()
  vim.cmd("DiffviewOpen " .. branch_principal() .. "...HEAD")
end, { desc = "Diff da branch contra a principal (main ou master)" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Fechar diff" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Histórico do arquivo" })
