if true then
  return {}
end

return {
  "ibhagwan/fzf-lua",
  keys = {
    {
      "<leader>fh",
      LazyVim.pick("files", { cwd = "~" }),
      desc = "Find in Home",
    },
  },
  opts = {
    winopts = {
      height = 0.85,
      width = 0.95,
      preview = {
        horizontal = "right:50%",
        layout = "horizontal",
      },
    },
  },
}
