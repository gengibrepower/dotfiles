-- Editor escuro dentro do rice claro: gruvbox dark com fundo opaco (o Ghostty
-- só aplica a translucidez ao fundo padrão; o fundo pintado pelo tema fica
-- sólido). colors/mucha.lua segue no repo: :colorscheme mucha para testar.
return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      contrast = "", -- "hard" | "soft" | "" (médio)
      transparent_mode = false,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme("gruvbox")
      end,
    },
  },
}
