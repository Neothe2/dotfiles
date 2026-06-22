return {
  "igorlfs/nvim-dap-view",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    require("dap-view").setup()
    -- Map this so you can instantly summon/dismiss the view without losing focus
    vim.keymap.set("n", "<leader>dv", require("dap-view").toggle, { desc = "Debug: Toggle DAP View" })
  end,
}
