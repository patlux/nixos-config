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

      opts.auto_install = false
      if is_git_editor then
        opts.ensure_installed = {}
        return
      end

      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown", "hurl" })
        vim.treesitter.language.register("markdown", "mdx")
      end
    end,
  },
}
