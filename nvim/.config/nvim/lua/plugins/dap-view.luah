local last_code_win = nil
return {
  -- 1. Disable the heavy default DAP UI
  {
    "rcarriga/nvim-dap-ui",
    enabled = false,
  },

  -- 2. Install and configure nvim-dap-view
  {
    "igorlfs/nvim-dap-view",
    opts = {
      -- Optional: You can customize the look here.
      -- By default, it opens on the right side.
      winbar = {
        show = true,
      },
    },
    keys = {
      -- Overrides LazyVim's default UI toggle to use dap-view instead
      {
        "<leader>du",
        function()
          local dapview = require("dap-view")
          local current_win = vim.api.nvim_get_current_win()
          local current_buf = vim.api.nvim_get_current_buf()
          local current_ft = vim.bo[current_buf].filetype

          -- If we're already in the DAP view, closing it will naturally return focus
          if current_ft:match("dap%-view") then
            dapview.toggle()
            return
          end

          -- Otherwise, save the current window and toggle it on
          last_code_win = current_win
          dapview.toggle()

          -- Small delay to let the window render, then jump into it
          vim.defer_fn(function()
            local wins = vim.api.nvim_tabpage_list_wins(0)
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype:match("dap%-view") then
                vim.api.nvim_set_current_win(win)
                return
              end
            end
          end, 50)
        end,
        desc = "Toggle & Focus DAP View",
      },
      {
        "<leader>df",
        function()
          local current_win = vim.api.nvim_get_current_win()
          local current_buf = vim.api.nvim_get_current_buf()
          local current_ft = vim.bo[current_buf].filetype

          -- 1. If we are ALREADY in the DAP view, jump back
          if current_ft:match("dap%-view") then
            if last_code_win and vim.api.nvim_win_is_valid(last_code_win) then
              vim.api.nvim_set_current_win(last_code_win)
            else
              -- Fallback if the last window was closed: jump to the previous window
              vim.cmd("wincmd p")
            end
            return
          end

          -- 2. If we are NOT in DAP view, save the current window and find the DAP view
          last_code_win = current_win
          local wins = vim.api.nvim_tabpage_list_wins(0)
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype:match("dap%-view") then
              vim.api.nvim_set_current_win(win)
              return
            end
          end

          print("DAP View window not found.")
        end,
        desc = "Toggle Focus: Code <-> DAP View",
      },
    },
  },
}
