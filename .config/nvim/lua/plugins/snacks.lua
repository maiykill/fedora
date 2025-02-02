return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fh",
      function()
        Snacks.picker.files({ cwd = "~" })
      end,
      desc = "Find in Home",
    },
  },
  opts = {
    lazygit = {
      win = {
        width = 0.95,
        height = 0.95,
      },
    },
    picker = {
      sources = {
        files = {
          hidden = true,
        },
        buffers = {
          hidden = true,
        },
        explorer = {
          hidden = true,
        },
        grep = {
          hidden = true,
        },
      },
      layout = {
        layout = {
          box = "horizontal",
          width = 0.95,
          min_width = 120,
          height = 0.9,
          {
            box = "vertical",
            border = "rounded",
            title = "{title} {live} {flags}",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
          },
          { win = "preview", title = "{preview}", border = "rounded", width = 0.45 },
        },
      },
    },
  },
}
