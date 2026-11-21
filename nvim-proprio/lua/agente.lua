local function caminho_relativo()
  local arquivo = vim.api.nvim_buf_get_name(0)
  local raiz = vim.fs.root(0, ".git") or vim.fn.getcwd()
  return vim.fs.relpath(raiz, arquivo) or arquivo
end

local function copiar(texto)
  vim.fn.setreg("+", texto)
  vim.notify("Copiado: " .. texto:match("^[^\n]*"))
end

vim.keymap.set("n", "<leader>yf", function()
  copiar(caminho_relativo() .. ":" .. vim.fn.line("."))
end, { desc = "Copiar caminho:linha (relativo)" })

vim.keymap.set("n", "<leader>yp", function()
  copiar(vim.api.nvim_buf_get_name(0) .. ":" .. vim.fn.line("."))
end, { desc = "Copiar caminho:linha (absoluto)" })

vim.keymap.set("x", "<leader>cc", function()
  local inicio, fim = vim.fn.line("v"), vim.fn.line(".")
  if inicio > fim then inicio, fim = fim, inicio end
  local linhas = vim.api.nvim_buf_get_lines(0, inicio - 1, fim, false)
  local cabecalho = ("```%s %s:%d-%d"):format(vim.bo.filetype, caminho_relativo(), inicio, fim)
  copiar(table.concat({ cabecalho, table.concat(linhas, "\n"), "```" }, "\n"))
  vim.api.nvim_feedkeys(vim.keycode("<esc>"), "n", false)
end, { desc = "Copiar seleção como bloco markdown" })
