vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. ":" .. vim.env.PATH

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- gr/gd fzf-lua key bindings
    "ibhagwan/fzf-lua",
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
          -- "ruby-lsp",
          -- "rubocop",
          -- "sorbet",

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
          -- b.formatting.prettier,
          -- b.formatting.prettier.with {
          --   filetypes = { "html", "markdown", "css" },
          -- }, -- so prettier works only on these filetypes
          -- b.formatting.rubocop,

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
    { "K", vim.lsp.buf.hover },
    { "<leader>rn", vim.lsp.buf.rename },
    { "<leader>ca", vim.lsp.buf.code_action },
    { "<leader>cl", vim.lsp.codelens.run },
    { "gd", vim.lsp.buf.definition },
    {
      "gr",
      function()
        require("fzf-lua").lsp_references()
      end,
    },
  },
  config = function()
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
    local servers = { "html", "ts_ls", "clangd", "rubocop", "sorbet" }

    for _, lsp in ipairs(servers) do
      vim.lsp.config(lsp, {
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end

    vim.lsp.config("lua_ls", {
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
    })

    vim.lsp.config("cssls", {
      settings = {
        css = {
          validate = true,
          lint = {
            unknownAtRules = "ignore",
          },
        },
      },
    })

    vim.lsp.config("sorbet", {
      cmd = { "srb", "tc", "--lsp", "--dir", vim.fn.getcwd(), "--disable-watchman" },
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = require("lspconfig.util").root_pattern("sorbet/config"),
    })

    vim.lsp.enable(servers)
    vim.lsp.enable "lua_ls"
    vim.lsp.enable "cssls"
    vim.lsp.enable "sorbet"
  end,
}
