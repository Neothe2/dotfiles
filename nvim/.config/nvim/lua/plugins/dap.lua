return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    -- 1. The Adapter (The Bridge)
    -- This tells Neovim how to communicate with the Dart runtime.
    -- We don't need Mason for this; the Dart SDK natively includes a debug adapter.
    dap.adapters.dart = {
      type = "executable",
      command = "dart",
      args = { "debug_adapter" },
    }

    -- 2. The Configuration (The Execution)
    -- This tells DAP what to do when you hit 'run'.
    -- We are telling it to launch the current file in the current working directory.
    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart Program",
        program = "${file}", -- Runs the currently active buffer
        cwd = "${workspaceFolder}",
        debugSdkLibraries = false,
        debugExternalPackageLibraries = false,
      },
    }

    -- The VS Code Emulator (Exception Interceptor)
    -- This hooks into the raw DAP event stream
    dap.listeners.after.event_stopped["flutter_exception_filter"] = function(session, body)
      -- 1. Only trigger if the execution halted because of an exception
      if body.reason == "exception" then
        -- 2. Ask the adapter for the current stack trace to see WHERE it crashed
        session:request("stackTrace", { threadId = body.threadId }, function(err, response)
          if err then
            return
          end

          if response and response.stackFrames and response.stackFrames[1] then
            local frame = response.stackFrames[1]
            local path = frame.source and (frame.source.path or frame.source.name) or ""

            -- 3. THE FIREWALL LOGIC
            -- If the crash is in the auto-generated web bootstrap or the Flutter SDK...
            if
              path:match("web_entrypoint.dart")
              or path:match("flutter/bin/cache")
              or path:match("flutter/packages")
            then
              -- 4. Silently force the thread to continue executing in the background
              session:request("continue", { threadId = body.threadId })
            end
          end
        end)
      end
    end
    -- The Synthetic Step Forcer
    -- Forces Neovim to yank the cursor back when Dart drops focus after skipping SDK code
    dap.listeners.after.event_stopped["flutter_synthetic_step_fix"] = function(session, body)
      if body.reason == "pause" then
        session:request("stackTrace", { threadId = body.threadId }, function(err, response)
          if err or not response or not response.stackFrames or #response.stackFrames == 0 then
            return
          end
          -- Manually override the Neovim state machine to attach the cursor
          session:set_current_frame(response.stackFrames[1])
        end)
      end
    end
    -- 3. The Core Keymaps (The Controls)
    -- Map these locally here so you know exactly where your debug controls live.
    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
    vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<S-F5>", dap.terminate, { desc = "Debug: Stop/Terminate" })

    -- 4. The Mnemonic Controls (<leader>d prefix)
    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Continue/Start" })
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })
    vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
  end,
}
