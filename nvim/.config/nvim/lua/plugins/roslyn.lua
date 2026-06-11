return {
  -- 1. Disable OmniSharp completely
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
      },
    },
  },

  -- 2. Add the custom Mason registry for the Roslyn server binary
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or {}
      table.insert(opts.registries, "github:Crashdummyy/mason-registry")
    end,
  },

  -- 3. Install and run Roslyn directly with zero complex configuration
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    opts = {},
  },
}
