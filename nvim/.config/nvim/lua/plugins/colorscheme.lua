return {
  -- 1. Install and configure the One Dark Pro plugin
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- High priority ensures it loads before UI elements
    config = function()
      require("onedarkpro").setup({
        caching = true, -- Caches the theme for faster Neovim startup times

        -- Match the specific One Dark Pro token formatting
        styles = {
          comments = "italic",
          keywords = "bold,italic",
          functions = "NONE",
          variables = "NONE",
          strings = "NONE",
          numbers = "NONE",
          constants = "NONE",
          types = "NONE",
        },

        options = {
          transparency = false, -- Toggle to true if you use a transparent terminal background
          cursorline = true, -- Highlights the active line
        },
      })
    end,
  },

  -- 2. Tell LazyVim to use the new colorscheme on startup
  {
    "LazyVim/LazyVim",
    opts = {
      -- "onedark_vivid" is the variant that replicates the high-saturation
      -- token colors of One Dark Pro in VS Code.
      colorscheme = "onedark_vivid",
    },
  },
}
