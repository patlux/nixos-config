return {
  "saghen/blink.cmp", -- Ensure the plugin is listed
  opts = {
    signature = { enabled = true },
    completion = {
      keyword = { range = "full" },
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
      ghost_text = { enabled = true },
    },
  },
}
