local uv = vim.uv or vim.loop

local function cwd()
  return uv.cwd()
end

local function root()
  return LazyVim.root()
end

local function trim_query(query)
  if not query then
    return nil
  end

  query = vim.trim(query)
  return query ~= "" and query or nil
end

local function current_word()
  return trim_query(vim.fn.expand("<cword>"))
end

local function selection_text()
  local mode = vim.fn.visualmode()
  local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = mode })
  return trim_query(table.concat(lines, "\n"))
end

local function find_files(path, opts)
  require("fff").find_files(vim.tbl_extend("force", { cwd = path }, opts or {}))
end

local function live_grep(path, opts)
  require("fff").live_grep(vim.tbl_extend("force", { cwd = path }, opts or {}))
end

local function disabled_search_keys()
  return {
    { "<leader>/", false },
    { "<leader><space>", false },
    { "<leader>fc", false },
    { "<leader>ff", false },
    { "<leader>fF", false },
    { "<leader>fg", false },
    { "<leader>fr", false },
    { "<leader>fR", false },
    { "<leader>sg", false },
    { "<leader>sG", false },
    { "<leader>sw", false, mode = { "n", "x" } },
    { "<leader>sW", false, mode = { "n", "x" } },
  }
end

return {
  {
    "folke/snacks.nvim",
    keys = disabled_search_keys(),
  },
  {
    "ibhagwan/fzf-lua",
    optional = true,
    keys = disabled_search_keys(),
  },
  {
    "dmtrKovalenko/fff.nvim",
    lazy = false,
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    opts = {
      lazy_sync = true,
    },
    keys = {
      {
        "<leader><space>",
        function()
          find_files(root(), { title = "Find Files (Root Dir)" })
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader>/",
        function()
          live_grep(root(), { title = "Grep (Root Dir)" })
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>fc",
        function()
          find_files(vim.fn.stdpath("config"), { title = "Find Config File" })
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          find_files(root(), { title = "Find Files (Root Dir)" })
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader>fF",
        function()
          find_files(cwd(), { title = "Find Files (cwd)" })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>fg",
        function()
          find_files(root(), {
            title = "Find Files (git-files)",
            query = "!git:untracked !git:ignored !git:deleted",
          })
        end,
        desc = "Find Files (git-files)",
      },
      {
        "<leader>fr",
        function()
          find_files(root(), { title = "Recent (Root Dir)" })
        end,
        desc = "Recent (Root Dir)",
      },
      {
        "<leader>fR",
        function()
          find_files(cwd(), { title = "Recent (cwd)" })
        end,
        desc = "Recent (cwd)",
      },
      {
        "<leader>sg",
        function()
          live_grep(root(), { title = "Grep (Root Dir)" })
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>sG",
        function()
          live_grep(cwd(), { title = "Grep (cwd)" })
        end,
        desc = "Grep (cwd)",
      },
      {
        "<leader>sw",
        function()
          live_grep(root(), {
            title = "Word (Root Dir)",
            query = current_word(),
          })
        end,
        mode = "n",
        desc = "Word (Root Dir)",
      },
      {
        "<leader>sW",
        function()
          live_grep(cwd(), {
            title = "Word (cwd)",
            query = current_word(),
          })
        end,
        mode = "n",
        desc = "Word (cwd)",
      },
      {
        "<leader>sw",
        function()
          live_grep(root(), {
            title = "Selection (Root Dir)",
            query = selection_text(),
          })
        end,
        mode = "x",
        desc = "Selection (Root Dir)",
      },
      {
        "<leader>sW",
        function()
          live_grep(cwd(), {
            title = "Selection (cwd)",
            query = selection_text(),
          })
        end,
        mode = "x",
        desc = "Selection (cwd)",
      },
    },
  },
}
