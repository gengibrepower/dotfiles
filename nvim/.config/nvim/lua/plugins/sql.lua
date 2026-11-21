-- sqlfluff exige um dialeto. O extra lang.sql do LazyVim força `--dialect=ansi`
-- no formatter (quebra com sintaxe Postgres, ex. o operador `~`) e não passa
-- dialeto nenhum no linter (erro "No dialect was specified" em todo arquivo).
-- Se o projeto tiver um .sqlfluff, ele manda; senão, assume Postgres.

local function dialect_args(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr or 0)
  local cfg = vim.fs.find(".sqlfluff", { upward = true, path = vim.fs.dirname(fname) })[1]
  if cfg then
    return {}
  end
  return { "--dialect=postgres" }
end

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function()
      local lint = require("lint")
      local base = require("lint.linters.sqlfluff")
      lint.linters.sqlfluff = function()
        return vim.tbl_extend("force", base, {
          args = vim.list_extend({ "lint", "--format=json" }, vim.list_extend(dialect_args(), { "-" })),
        })
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = {
        args = function(_, ctx)
          return vim.list_extend(
            { "format" },
            vim.list_extend(dialect_args(ctx.buf), { "--stdin-filename", ctx.filename, "-" })
          )
        end,
        require_cwd = false,
        -- exit 1 = formatou, mas sobrou violação não corrigível (ex. linha longa)
        exit_codes = { 0, 1 },
      }
    end,
  },
}
