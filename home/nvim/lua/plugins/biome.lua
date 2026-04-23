local biome_config_names = {
  "biome.json",
  "biome.jsonc",
}

local oxfmt_config_names = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
}

local oxlint_config_names = {
  ".oxlintrc.json",
  "oxlint.config.ts",
}

local formatter_fts = {
  "astro",
  "css",
  "graphql",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
}

local linter_fts = {
  "astro",
  "javascript",
  "javascriptreact",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
}

local function make_lookup(filetypes)
  local lookup = {}

  for _, ft in ipairs(filetypes) do
    lookup[ft] = true
  end

  return lookup
end

local formatter_ft_lookup = make_lookup(formatter_fts)

local function has_upward_file(dirname, file_names)
  return vim.fs.find(file_names, {
    path = dirname,
    upward = true,
  })[1] ~= nil
end

local function has_local_bin(dirname, bin_name)
  local node_modules_dirs = vim.fs.find("node_modules", {
    path = dirname,
    upward = true,
    limit = math.huge,
  })

  for _, node_modules_dir in ipairs(node_modules_dirs) do
    if vim.fn.executable(node_modules_dir .. "/.bin/" .. bin_name) == 1 then
      return true
    end
  end

  return false
end

local function is_formatter_ft(ctx)
  local ft = vim.bo[ctx.buf].filetype
  return formatter_ft_lookup[ft] == true
end

local function is_biome_project(ctx)
  return is_formatter_ft(ctx) and has_upward_file(ctx.dirname, biome_config_names)
end

local function is_oxfmt_project(ctx)
  return is_formatter_ft(ctx) and has_upward_file(ctx.dirname, oxfmt_config_names)
end

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local util = require("conform.util")

      opts.formatters = opts.formatters or {}
      opts.formatters.biome = {
        command = util.find_executable({ "node_modules/.bin/biome" }, "biome"),
        cwd = util.root_file(biome_config_names),
        require_cwd = true,
        condition = function(_, ctx)
          return is_biome_project(ctx) and has_local_bin(ctx.dirname, "biome")
        end,
      }

      opts.formatters.oxfmt = {
        command = util.find_executable({ "node_modules/.bin/oxfmt" }, "oxfmt"),
        cwd = util.root_file(oxfmt_config_names),
        require_cwd = true,
        condition = function(_, ctx)
          return not is_biome_project(ctx)
            and is_oxfmt_project(ctx)
            and has_local_bin(ctx.dirname, "oxfmt")
        end,
      }

      local existing_prettier = opts.formatters.prettier or {}
      local existing_prettier_condition = existing_prettier.condition
      opts.formatters.prettier = vim.tbl_deep_extend("force", existing_prettier, {
        condition = function(self, ctx)
          if is_biome_project(ctx) or is_oxfmt_project(ctx) then
            return false
          end

          if existing_prettier_condition then
            return existing_prettier_condition(self, ctx)
          end

          return true
        end,
      })

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(formatter_fts) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        if not vim.tbl_contains(opts.formatters_by_ft[ft], "biome") then
          table.insert(opts.formatters_by_ft[ft], 1, "biome")
        end
        if not vim.tbl_contains(opts.formatters_by_ft[ft], "oxfmt") then
          table.insert(opts.formatters_by_ft[ft], 2, "oxfmt")
        end
        opts.formatters_by_ft[ft].stop_after_first = true
      end
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters.oxlint = vim.tbl_deep_extend("force", opts.linters.oxlint or {}, {
        condition = function(ctx)
          return has_upward_file(ctx.dirname, oxlint_config_names)
            and has_local_bin(ctx.dirname, "oxlint")
        end,
      })

      opts.linters_by_ft = opts.linters_by_ft or {}
      for _, ft in ipairs(linter_fts) do
        opts.linters_by_ft[ft] = opts.linters_by_ft[ft] or {}
        if not vim.tbl_contains(opts.linters_by_ft[ft], "oxlint") then
          table.insert(opts.linters_by_ft[ft], 1, "oxlint")
        end
      end
    end,
  },
}
