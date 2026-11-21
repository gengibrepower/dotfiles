require("remote_clipboard").setup()

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.colorcolumn = "101"
vim.opt.showtabline = 0
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 4
vim.opt.termguicolors = true

vim.keymap.set("n", "ZR", "<cmd>restart<cr>", { desc = "Reiniciar o Neovim" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr><esc>")

-- teclado alemão: [ e ] precisam de AltGr; ö e ä fazem o papel deles em todos os atalhos ([d, ]q, ]h...)
vim.keymap.set({ "n", "x", "o" }, "ö", "[", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "ä", "]", { remap = true })
