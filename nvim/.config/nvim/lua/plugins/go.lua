-- O extra lang.go já liga o golangcilint no nvim-lint, mas instala o binário
-- pelo Mason, que fica na frente do PATH. Tira daqui pra usar o do mise.
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(name)
        return name ~= "golangci-lint"
      end, opts.ensure_installed or {})
    end,
  },
}
