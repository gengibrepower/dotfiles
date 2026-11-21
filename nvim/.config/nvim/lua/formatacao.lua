vim.pack.add({ "https://github.com/stevearc/conform.nvim", "https://github.com/mfussenegger/nvim-lint" })

-- sqlfluff exige dialeto: o .sqlfluff do projeto manda; sem ele, Postgres
local function dialeto_sql(arquivo)
  if vim.fs.find(".sqlfluff", { upward = true, path = vim.fs.dirname(arquivo) })[1] then
    return {}
  end
  return { "--dialect=postgres" }
end

local biome = { "biome" }
require("conform").setup({
  formatters_by_ft = {
    zig = { "zigfmt" },
    javascript = biome,
    typescript = biome,
    svelte = biome,
    json = biome,
    jsonc = biome,
    css = biome,
    go = { "gofmt" },
    rust = { "rustfmt" },
    lua = { "stylua" },
    python = { "ruff_format" },
    toml = { "taplo" },
    sql = { "sqlfluff" },
  },
  formatters = {
    sqlfluff = {
      args = function(_, ctx)
        return vim.list_extend({ "format" }, vim.list_extend(dialeto_sql(ctx.filename), { "--stdin-filename", ctx.filename, "-" }))
      end,
      require_cwd = false,
      -- exit 1 = formatou, mas sobrou violação que o sqlfluff não corrige (ex. linha longa)
      exit_codes = { 0, 1 },
    },
  },
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ lsp_format = "fallback" })
end, { desc = "Formatar" })

local lint = require("lint")
local sqlfluff = require("lint.linters.sqlfluff")
lint.linters.sqlfluff = function()
  local args = vim.list_extend({ "lint", "--format=json" }, dialeto_sql(vim.api.nvim_buf_get_name(0)))
  return vim.tbl_extend("force", sqlfluff, { args = vim.list_extend(args, { "-" }) })
end
lint.linters_by_ft = { sql = { "sqlfluff" } }

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
