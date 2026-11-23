vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/windwp/nvim-autopairs",
})

-- fecha ( [ { " '; não fecha em string/comentário (treesitter); <CR> entre {} abre linha indentada
require("nvim-autopairs").setup({ check_ts = true })

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  completion = { documentation = { auto_show = true } },
  signature = { enabled = true },
  cmdline = {
    keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
    completion = {
      list = { selection = { preselect = false } },
      menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end },
      ghost_text = { enabled = true },
    },
  },
})
