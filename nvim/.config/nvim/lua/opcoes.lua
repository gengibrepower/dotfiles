require("remote_clipboard").setup()

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showtabline = 0
vim.opt.clipboard = "unnamedplus"
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
-- cor explícita (grupo Cursor): o cell-foreground do Ghostty deixava a barra do insert invisível
vim.opt.guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor,t:block-blinkon500-blinkoff500-TermCursor"

vim.keymap.set("n", "ZR", "<cmd>restart<cr>", { desc = "Reiniciar o Neovim" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr><esc>")

-- teclado alemão: [ e ] precisam de AltGr; ö e ä fazem o papel deles em todos os atalhos ([d, ]q, ]h...)
vim.keymap.set({ "n", "x", "o" }, "ö", "[", { remap = true })
vim.keymap.set({ "n", "x", "o" }, "ä", "]", { remap = true })
