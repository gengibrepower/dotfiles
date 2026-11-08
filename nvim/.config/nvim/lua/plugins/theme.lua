-- Rice "Mucha": terminal creme (#F7F1E3). Gruvbox claro casa com os tons
-- de pergaminho e marrom; o fundo transparente deixa o creme do Ghostty.
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
