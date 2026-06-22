return {
  "theHamsta/nvim-dap-virtual-text",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    require("nvim-dap-virtual-text").setup({
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false, -- Set to true if you want values to look like comments
    })
  end,
}
