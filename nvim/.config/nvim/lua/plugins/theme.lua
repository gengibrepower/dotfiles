-- Rice "Mucha": gruvbox claro transparente (escolhido no lugar do
-- colors/mucha.lua, que segue no repo: :colorscheme mucha para testar).
return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      contrast = "soft",
      transparent_mode = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.o.background = "light"
        vim.cmd.colorscheme("gruvbox")
      end,
    },
  },
}
