return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          -- Action 1: Copy Absolute Path (<leader>fah)
          copy_abspath = function(_, item)
            if not item then
              return
            end

            local path = item.file or item.dir
            if path then
              local full_path = vim.fn.fnamemodify(path, ":p")
              vim.fn.setreg("+", full_path)
              vim.fn.setreg('"', full_path)
              vim.notify("Copied: " .. full_path, vim.log.levels.INFO, { title = "Snacks Explorer" })
            end
          end,

          -- Action 2: Create C# API Controller (<leader>cn)
          create_api_controller = function(picker, item)
            if not item then
              return
            end

            local path = item.file or item.dir
            if not path then
              return
            end

            local full_path = vim.fn.fnamemodify(path, ":p")
            local target_dir = vim.fn.isdirectory(full_path) == 1 and full_path or vim.fn.fnamemodify(full_path, ":h")

            local name = vim.fn.input("Controller Name (e.g., Users): ")
            if name == "" then
              return
            end
            if not name:match("Controller$") then
              name = name .. "Controller"
            end

            local cmd = string.format('dotnet new apicontroller -n "%s" -o "%s"', name, target_dir)
            vim.fn.system(cmd)

            local current = target_dir
            local suffix = ""
            local namespace = ""

            for _ = 1, 15 do
              local csproj_files = vim.fn.glob(current .. "/*.csproj", true, true)

              if #csproj_files > 0 then
                local proj_name = vim.fn.fnamemodify(csproj_files[1], ":t:r")
                namespace = suffix == "" and proj_name or proj_name .. "." .. suffix
                break
              end

              local parent = vim.fn.fnamemodify(current, ":h")
              if parent == current then
                break
              end

              local folder_name = vim.fn.fnamemodify(current, ":t")
              suffix = suffix == "" and folder_name or folder_name .. "." .. suffix
              current = parent
            end

            if namespace == "" then
              namespace = "MyApp"
            end

            local filepath = target_dir .. "/" .. name .. ".cs"
            if vim.fn.filereadable(filepath) == 1 then
              local lines = vim.fn.readfile(filepath)
              local is_block = false

              -- Step A: Inject the correct namespace and check formatting
              for i, line in ipairs(lines) do
                if line:match("^namespace%s") then
                  -- If the CLI didn't append a semicolon, it's a block-scoped namespace
                  if not line:match(";%s*$") then
                    is_block = true
                  end
                  lines[i] = "namespace " .. namespace .. ";"
                  break
                end
              end

              -- Step B: Convert Block-Scoped to File-Scoped
              if is_block then
                local new_lines = {}
                local skipped_open = false
                local past_ns = false

                for _, line in ipairs(lines) do
                  if line:match("^namespace%s") then
                    table.insert(new_lines, line)
                    past_ns = true
                  elseif past_ns and not skipped_open and line:match("^%s*{%s*$") then
                    -- Drop the opening bracket
                    skipped_open = true
                  else
                    if skipped_open then
                      -- Un-indent the class body by exactly 4 spaces
                      line = line:gsub("^    ", "")
                    end
                    table.insert(new_lines, line)
                  end
                end

                -- Drop the final closing bracket at the end of the file
                for i = #new_lines, 1, -1 do
                  if new_lines[i]:match("^%s*}%s*$") then
                    table.remove(new_lines, i)
                    break
                  end
                end
                lines = new_lines
              end

              vim.fn.writefile(lines, filepath)

              picker:close()

              vim.cmd("edit " .. vim.fn.fnameescape(filepath))
              vim.notify("Generated " .. name .. " in " .. namespace, vim.log.levels.INFO)
            else
              vim.notify("Critical Error: Controller not found at " .. filepath, vim.log.levels.ERROR)
            end
          end,
        },
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["<leader>fah"] = "copy_abspath",
                  ["<leader>cn"] = "create_api_controller",
                },
              },
            },
          },
        },
      },
    },
  },
}
