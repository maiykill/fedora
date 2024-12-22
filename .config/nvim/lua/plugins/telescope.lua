if true then
  return {}
end

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fh",
      function()
        require("telescope.builtin").find_files({ cwd = "~" })
      end,
      desc = "Find Home File",
    },
  },
  -- change some options
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      sorting_strategy = "descending",
      winblend = 0,
      layout_config = {
        horizontal = {
          prompt_position = "bottom",
          width = 0.95,
          preview_width = 0.40,
        },
      },
    },
  },
}
