return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsgo = {},
        vtsls = { enabled = false },
      },
    },
  },
}
