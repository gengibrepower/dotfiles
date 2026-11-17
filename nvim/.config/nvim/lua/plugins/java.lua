-- jdtls roda no java do PATH (25 via mise no trab-poo); projetos com <target>24 precisam de um JDK 24 registrado
return {
  "mfussenegger/nvim-jdtls",
  opts = {
    settings = {
      java = {
        configuration = {
          runtimes = {
            { name = "JavaSE-24", path = vim.fn.expand("~/.local/share/mise/installs/java/temurin-24.0.2+12") },
            { name = "JavaSE-25", path = vim.fn.expand("~/.local/share/mise/installs/java/temurin-25.0.5+8.0.LTS") },
          },
        },
      },
    },
  },
}
