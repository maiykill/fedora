return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = true,
      exclude = { "python" },
    },
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "off",
              autoImportCompletions = true,
            },
          },
        },
      },
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              rope_completion = { enabled = true },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
              jedi_completion = { enabled = false },
              jedi_definition = { enabled = false },
              jedi_hover = { enabled = false },
              jedi_references = { enabled = false },
              jedi_signature_help = { enabled = false },
              jedi_symbols = { enabled = false },
              pylint = { enabled = false },
              pyflakes = { enabled = false },
              pydocstyle = { enabled = false },
              flake8 = { enabled = false },
              pycodestyle = { enabled = false },
              mccabe = { enabled = false },
            },
          },
        },
      },
    },
  },
}
