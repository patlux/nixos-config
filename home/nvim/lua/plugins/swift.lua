return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local is_git_editor = vim.env.GIT_INDEX_FILE ~= nil or vim.env.GIT_DIR ~= nil
      if not is_git_editor then
        for _, arg in ipairs(vim.fn.argv()) do
          if arg:match("git%-rebase%-todo$")
            or arg:match("COMMIT_EDITMSG$")
            or arg:match("MERGE_MSG$")
            or arg:match("TAG_EDITMSG$")
            or arg:match("%.git[/\\]")
          then
            is_git_editor = true
            break
          end
        end
      end

      if is_git_editor then
        return
      end

      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "swift" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("buildServer.json")(filename)
              or util.root_pattern("*.xcodeproj", "*.xcworkspace")(filename)
              or util.find_git_ancestor(filename)
              or util.root_pattern("Package.swift")(filename)
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },
}
