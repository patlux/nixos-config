return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      -- provider = "openai",
      -- auto_suggestions_provider = "openai",
      -- openai = {
      --   endpoint = "http://127.0.0.1:1234/v1",
      --   model = "lmstudio-community/Qwen2.5-Coder-14B-Instruct-MLX-4bit",
      --   api_key_name = "DEEPSEEK_API_KEY",
      --   temperature = 0.0,
      --   max_tokens = 8000,
      -- },
      -- openai = {
      --   endpoint = "https://openrouter.ai/api/v1",
      --   model = "deepseek/deepseek-chat",
      --   api_key_name = "OPENROUTER_API_KEY_AVANTE",
      --   temperature = 0.0,
      --   max_tokens = 8000,
      -- },
      -- openai = {
      --   endpoint = "https://api.groq.com/openai/v1",
      --   model = "deepseek-r1-distill-llama-70b",
      --   api_key_name = "GROQ_API_KEY",
      --   temperature = 0.0,
      --   max_tokens = 8000,
      --   timeout = 30000,
      -- },
      -- openai = {
      --   endpoint = "https://api.deepseek.com/beta",
      --   model = "deepseek-chat",
      --   api_key_name = "DEEPSEEK_API_KEY",
      --   temperature = 0.0,
      --   max_tokens = 8000,
      -- },
      provider = "gemini",
      auto_suggestions_provider = "gemini",
      gemini = {
        -- endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/",
        model = "gemini-2.5-flash-preview-04-17",
        api_key_name = "GOOGLE_AI_API_KEY",
        temperature = 0.0,
      },
    },
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
