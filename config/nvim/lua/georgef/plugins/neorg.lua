return {
      "nvim-neorg/neorg",
      lazy = false,
      version = "*",
      config = function()
        require("neorg").setup {
          load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {
          icon_preset = "basic"
        },
            ["core.dirman"] = {
              config = {
                workspaces = {
                  notes = "~/notes",
                },
                default_workspace = "notes",
              },
            },
        ["core.integrations.treesitter"] = {
          config = {
            configure_parsers = "true",
            install_parsers = "true",
          }
        },
        ["core.export"] = {
          export_dir = "<export-dir>/<language>-export"
        },
        ["core.export.markdown"] = {
          extension = "md"
        },
          },
        }
  
        vim.wo.foldlevel = 99
        vim.wo.conceallevel = 2
      end,
    }
