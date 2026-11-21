local function comando_de_teste(raiz)
  local tem = function(nome) return vim.uv.fs_stat(raiz .. "/" .. nome) ~= nil end
  if tem("justfile") then return { "just", "test" } end
  if tem("build.zig") then return { "zig", "build", "test" } end
  if tem("go.mod") then return { "go", "test", "./..." } end
  if tem("Cargo.toml") then return { "cargo", "test" } end
end

local function absolutizar(raiz, linha)
  return (linha:gsub("^([^/%s][^:%s]*):(%d+):", function(arquivo, num)
    return raiz .. "/" .. arquivo .. ":" .. num .. ":"
  end))
end

local function rodar_testes()
  local raiz = vim.fs.root(0, { "justfile", "build.zig", "go.mod", "Cargo.toml" })
  local cmd = raiz and comando_de_teste(raiz)
  if not cmd then
    vim.notify("Nenhum comando de teste conhecido para este projeto", vim.log.levels.WARN)
    return
  end
  vim.notify(table.concat(cmd, " ") .. " em " .. vim.fn.fnamemodify(raiz, ":~"))
  vim.system(cmd, { cwd = raiz, text = true }, function(res)
    local linhas = {}
    for linha in ((res.stdout or "") .. (res.stderr or "")):gmatch("[^\n]+") do
      linhas[#linhas + 1] = absolutizar(raiz, linha)
    end
    vim.schedule(function()
      vim.fn.setqflist({}, " ", { title = table.concat(cmd, " "), lines = linhas, efm = "%f:%l:%c: %m,%f:%l: %m" })
      if res.code == 0 then
        vim.notify("Testes passaram")
      else
        vim.cmd("botright copen")
      end
    end)
  end)
end

vim.keymap.set("n", "<leader>tt", rodar_testes, { desc = "Rodar os testes do projeto" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Próximo da quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Anterior da quickfix" })
