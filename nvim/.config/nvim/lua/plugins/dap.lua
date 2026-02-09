return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      opts = {},
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
  },
  keys = {
    {
      "<leader>db",
      function() require("dap").toggle_breakpoint() end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
      desc = "Conditional breakpoint",
    },
    {
      "<leader>dc",
      function() require("dap").continue() end,
      desc = "Continue / Start debugger",
    },
    {
      "<leader>do",
      function() require("dap").step_over() end,
      desc = "Step over",
    },
    {
      "<leader>di",
      function() require("dap").step_into() end,
      desc = "Step into",
    },
    {
      "<leader>dO",
      function() require("dap").step_out() end,
      desc = "Step out",
    },
    {
      "<leader>dr",
      function() require("dap").repl.toggle() end,
      desc = "Toggle REPL",
    },
    {
      "<leader>du",
      function() require("dapui").toggle() end,
      desc = "Toggle DAP UI",
    },
    {
      "<leader>dx",
      function()
        require("dap").terminate()
        require("dapui").close()
      end,
      desc = "Terminate debugger",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Auto-open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Ruby (rdbg) adapter
    dap.adapters.ruby = function(callback, config)
      callback({
        type = "server",
        host = config.server or "127.0.0.1",
        port = config.port or "${port}",
        executable = {
          command = "rdbg",
          args = {
            "-n",
            "--open",
            "--port",
            "${port}",
            "-c",
            "--",
            config.command or "ruby",
            config.script,
          },
        },
      })
    end

    dap.configurations.ruby = {
      {
        type = "ruby",
        name = "Debug current file",
        request = "launch",
        script = "${file}",
      },
      {
        type = "ruby",
        name = "Debug test (current file)",
        request = "launch",
        command = "ruby",
        script = "${file}",
        args = { "-Itest" },
      },
      {
        type = "ruby",
        name = "Attach to rdbg",
        request = "attach",
        localfs = true,
      },
    }

    -- JS/TS adapter (js-debug)
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }

    local js_config = {
      {
        type = "pwa-node",
        name = "Debug current file",
        request = "launch",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        name = "Attach to process",
        request = "attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }

    dap.configurations.javascript = js_config
    dap.configurations.typescript = js_config
  end,
}
