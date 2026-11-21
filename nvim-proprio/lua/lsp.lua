vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.config("clangd", { cmd = { "clangd", "--query-driver=**" } })

-- o trab-poo compila com target 24 e roda no 25 do mise; o jdtls precisa conhecer os dois JDKs
local mise_java = vim.fn.expand("~/.local/share/mise/installs/java/")
vim.lsp.config("jdtls", {
  settings = {
    java = {
      configuration = {
        runtimes = {
          { name = "JavaSE-24", path = mise_java .. "temurin-24.0.2+12" },
          { name = "JavaSE-25", path = mise_java .. "temurin-25.0.5+8.0.LTS" },
        },
      },
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } },
})

vim.lsp.enable({
  "zls", "ts_ls", "svelte", "tailwindcss", "biome", "gopls", "rust_analyzer", "clangd", "lua_ls",
  "jdtls", "pyright", "ruff", "marksman", "yamlls", "jsonls", "taplo",
})

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

local map = vim.keymap.set
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Renomear símbolo" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Ações de código" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnóstico da linha" })
map("n", "<leader>cq", vim.diagnostic.setqflist, { desc = "Diagnósticos na quickfix" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Ir para definição" })
