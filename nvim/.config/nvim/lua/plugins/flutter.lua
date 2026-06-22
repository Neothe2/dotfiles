return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    -- Added custom keybindings for the log management
    keys = {
      { "<leader>fl", "<cmd>FlutterLogToggle<cr>", desc = "Toggle Flutter Log (Bottom)" },
      { "<leader>fc", "<cmd>FlutterLogClear<cr>", desc = "Clear Flutter Log" },
      { "<leader>fr", "<cmd>FlutterRun<cr>", desc = "Flutter: Run App" },
      { "<leader>fq", "<cmd>FlutterQuit<cr>", desc = "Flutter: Quit App" },
    },
    opts = {
      ui = {
        border = "rounded",
      },
      -- Key fix: Disable autostart and move log to the bottom
      dev_log = {
        enabled = true,
        autostart = false, -- Won't annoyingly pop up on run
        notify_errors = false, -- Won't pop up on hot-reload errors
        open_cmd = "horizontal 12split", -- Opens at bottom with 12-line height
      },
      decorations = {
        statusline = {
          app_version = true,
          device = true,
        },
      },
      widget_guides = {
        enabled = true,
      },
      closing_labels = {
        enabled = true,
      },
      lsp = {
        color = {
          enabled = true,
        },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
        },
      },
      debugger = {
        enabled = true,
        run_via_dap = true,
        register_configurations = function(paths)
          local dap = require("dap")

          -- 1. The Flutter Debug Adapter Bridge
          dap.adapters.dart = {
            type = "executable",
            command = paths.flutter_bin,
            args = { "debug_adapter" }, -- Ensure this is an underscore
          }

          -- 2. The Flutter DAP Configuration
          dap.configurations.dart = {
            {
              type = "dart",
              request = "launch",
              name = "Launch Flutter App",
              program = "${workspaceFolder}/lib/main.dart",
              cwd = "${workspaceFolder}",

              debugSdkLibraries = false,
              debugExternalPackageLibraries = false,
            },
          }
        end,
      },
      dev_tools = {
        autostart = false,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "dart" })
      end
    end,
  },
}
