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

local last_picker

local function remember_picker(kind, path, opts)
  last_picker = {
    kind = kind,
    path = path,
    opts = vim.deepcopy(opts or {}),
  }
end

local function active_picker_query()
  local ok, picker = pcall(require, "fff.picker_ui")
  if not ok or not picker.state or not picker.state.input_buf then
    return nil
  end

  local input_buf = picker.state.input_buf
  if not vim.api.nvim_buf_is_valid(input_buf) then
    return nil
  end

  local line = vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)[1] or ""
  local prompt = picker.state.config and picker.state.config.prompt or ""
  if prompt ~= "" and line:sub(1, #prompt) == prompt then
    line = line:sub(#prompt + 1)
  end

  return trim_query(line)
end

local function track_picker_query()
  local ok, picker = pcall(require, "fff.picker_ui")
  if not ok or not picker.state or not picker.state.input_buf then
    return
  end

  local input_buf = picker.state.input_buf
  if not vim.api.nvim_buf_is_valid(input_buf) then
    return
  end

  local group = vim.api.nvim_create_augroup("PatwozFffResume", { clear = true })
  local function update_query()
    if last_picker then
      last_picker.opts.query = active_picker_query()
    end
  end

  update_query()
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufLeave" }, {
    group = group,
    buffer = input_buf,
    callback = update_query,
  })
end

local function selection_text()
  local mode = vim.fn.visualmode()
  local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = mode })
  return trim_query(table.concat(lines, "\n"))
end

local function find_files(path, opts)
  remember_picker("files", path, opts)
  require("fff").find_files(vim.tbl_extend("force", { cwd = path }, opts or {}))
  track_picker_query()
end

local function live_grep(path, opts)
  remember_picker("grep", path, opts)
  require("fff").live_grep(vim.tbl_extend("force", { cwd = path }, opts or {}))
  track_picker_query()
end

local function resume()
  if not last_picker then
    vim.notify("No fff resume data available", vim.log.levels.INFO)
    return
  end

  if last_picker.kind == "grep" then
    live_grep(last_picker.path, last_picker.opts)
  else
    find_files(last_picker.path, last_picker.opts)
  end
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
    { "<leader>sR", false },
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
      git = {
        status_text_color = true,
      },
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
        "<leader>sR",
        resume,
        desc = "Resume",
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
