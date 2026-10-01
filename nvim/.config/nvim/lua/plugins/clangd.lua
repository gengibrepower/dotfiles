return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        clangd = function(_, opts)
          opts.cmd = opts.cmd or { "clangd" }
          vim.list_extend(opts.cmd, { "--query-driver=**" })
        end,
      },
    },
  },
}
