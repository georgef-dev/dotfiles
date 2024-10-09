vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. ":" .. vim.env.PATH

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- format & linting
    {
      "williamboman/mason.nvim",
      cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
      opts = {
        PATH = "skip",
        ui = {
          border = "rounded",
        },
        ensure_installed = {
          -- lua stuff
          "lua-language-server",
          "stylua",

          -- web dev stuff
          "css-lsp",
          "html-lsp",
          "typescript-language-server",
          "prettier",

          -- ruby stuff
          "ruby-lsp",
          "rubocop",
          "sorbet",

          -- c/cpp stuff
          "clangd",
          "clang-format",
        },
        automatic_installation = true,
      },
      config = function(_, opts)
        require("mason").setup(opts)

        vim.api.nvim_create_user_command("MasonInstallAll", function()
          vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
        end, {})

        vim.g.mason_binaries_list = opts.ensure_installed
      end,
    },
    {
      "nvimtools/none-ls.nvim",
      config = function()
        local null_ls = require "null-ls"

        local b = null_ls.builtins

        local sources = {

          -- webdev stuff
          b.formatting.prettier.with {
            filetypes = { "html", "markdown", "css" },
          }, -- so prettier works only on these filetypes
          b.formatting.rubocop,

          -- Lua
          b.formatting.stylua,

          -- cpp
          b.formatting.clang_format,
        }

        -- Autoformatting
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

        null_ls.setup {
          debug = false,
          sources = sources,
          on_attach = function(client, bufnr)
            if client.supports_method "textDocument/formatting" then
              vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format { async = false }
                end,
              })
            end
          end,
        }
      end,
    },
  },
  keys = {
    { "<space>e", vim.diagnostic.open_float },
    { "[d", vim.diagnostic.goto_prev },
    { "]d", vim.diagnostic.goto_next },
    { "<space>q", vim.diagnostic.setloclist },
    { "gd", vim.lsp.buf.definition },
    { "K", vim.lsp.buf.hover },
    { "<leader>rn", vim.lsp.buf.rename },
    { "<leader>ca", vim.lsp.buf.code_action },
    { "gr", vim.lsp.buf.references },
    { "<leader>cl", vim.lsp.codelens.run },
  },
  config = function()
    local lspconfig = require "lspconfig"

    local on_attach = function(client, _)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      if client.supports_method "textDocument/semanticTokens" then
        client.server_capabilities.semanticTokensProvider = nil
      end
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities.textDocument.completion.completionItem = {
      documentationFormat = { "markdown", "plaintext" },
      snippetSupport = true,
      preselectSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      deprecatedSupport = true,
      commitCharactersSupport = true,
      tagSupport = { valueSet = { 1 } },
      resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        },
      },
    }

    -- if you just want default config for the servers then put them in a table
    local servers = { "html", "tsserver", "clangd", "rubocop", "sorbet" }

    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }
    end

    lspconfig.lua_ls.setup {
      on_attach = on_attach,
      capabilities = capabilities,

      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand "$VIMRUNTIME/lua"] = true,
              [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
              [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
            },
            maxPreload = 100000,
            preloadFileSize = 10000,
          },
        },
      },
    }

    lspconfig.cssls.setup {
      settings = {
        css = {
          validate = true,
          lint = {
            unknownAtRules = "ignore",
          },
        },
      },
    }

    -- textDocument/diagnostic support until 0.10.0 is released
    local _timers = {}
    local function setup_diagnostics(client, buffer)
      if require("vim.lsp.diagnostic")._enable then
        return
      end

      local diagnostic_handler = function()
        local params = vim.lsp.util.make_text_document_params(buffer)
        client.request(
          "textDocument/diagnostic",
          { textDocument = params },
          function(err, result)
            if err then
              local err_msg =
                string.format("diagnostics error - %s", vim.inspect(err))
              vim.lsp.log.error(err_msg)
            end
            local diagnostic_items = {}
            if result then
              diagnostic_items = result.items
            end
            vim.lsp.diagnostic.on_publish_diagnostics(
              nil,
              vim.tbl_extend("keep", params, { diagnostics = diagnostic_items }),
              { client_id = client.id }
            )
          end
        )
      end

      diagnostic_handler() -- to request diagnostics on buffer when first attaching

      vim.api.nvim_buf_attach(buffer, false, {
        on_lines = function()
          if _timers[buffer] then
            vim.fn.timer_stop(_timers[buffer])
          end
          _timers[buffer] = vim.fn.timer_start(200, diagnostic_handler)
        end,
        on_detach = function()
          if _timers[buffer] then
            vim.fn.timer_stop(_timers[buffer])
          end
        end,
      })
    end

    -- adds ShowRubyDeps command to show dependencies in the quickfix list.
    -- add the `all` argument to show indirect dependencies as well
    local function add_ruby_deps_command(client, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
        local params = vim.lsp.util.make_text_document_params()

        local showAll = opts.args == "all"

        client.request(
          "rubyLsp/workspace/dependencies",
          params,
          function(error, result)
            if error then
              print("Error showing deps: " .. error)
              return
            end

            local qf_list = {}
            for _, item in ipairs(result) do
              if showAll or item.dependency then
                table.insert(qf_list, {
                  text = string.format(
                    "%s (%s) - %s",
                    item.name,
                    item.version,
                    item.dependency
                  ),

                  filename = item.path,
                })
              end
            end

            vim.fn.setqflist(qf_list)
            vim.cmd "copen"
          end,
          bufnr
        )
      end, {
        nargs = "?",
        complete = function()
          return { "all" }
        end,
      })
    end

    lspconfig.ruby_ls.setup {
      on_attach = function(client, buffer)
        setup_diagnostics(client, buffer)
        add_ruby_deps_command(client, buffer)
      end,
    }
  end,
}
