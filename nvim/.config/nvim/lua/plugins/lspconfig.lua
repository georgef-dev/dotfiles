-- Append Mason to PATH (lower priority than nix/shadowenv LSPs)
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not string.find(vim.env.PATH, mason_bin, 1, true) then
  vim.env.PATH = vim.env.PATH .. ":" .. mason_bin
end

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
          "js-debug-adapter",

          -- ruby: ruby-lsp + rubocop come from each project's Gemfile, not Mason

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
          b.formatting.prettier,
          b.formatting.prettier.with {
             filetypes = { "html", "markdown", "css" },
          }, -- so prettier works only on these filetypes

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
            if client:supports_method "textDocument/formatting" then
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
    { "<space>e", vim.diagnostic.open_float, desc = "Show Diagnostics Float" },
    { "[d", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
    { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
    { "<space>q", vim.diagnostic.setloclist, desc = "Diagnostics to Loclist" },
    { "K", vim.lsp.buf.hover, desc = "Hover Docs" },
    { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
    { "<leader>cl", vim.lsp.codelens.run, desc = "Run Codelens" },
    { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
    { "gr", function() require("fzf-lua").lsp_references() end, desc = "Go to References" },

    -- LSP management
    { "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP Info" },
    { "<leader>lr", "<cmd>LspRestart<cr>", desc = "LSP Restart" },
    { "<leader>ls", "<cmd>LspStart<cr>", desc = "LSP Start" },
    { "<leader>lt", "<cmd>LspStop<cr>", desc = "LSP Stop" },
    { "<leader>ll", "<cmd>LspLog<cr>", desc = "LSP Log" },

    -- Additional navigation
    { "gD", vim.lsp.buf.declaration, desc = "Go to Declaration" },
    { "gi", vim.lsp.buf.implementation, desc = "Go to Implementation" },
    { "<C-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },

    -- Rename with Snacks
    { "<leader>cR", vim.lsp.buf.rename, desc = "Rename Symbol (LSP)" },
  },
  config = function()
    -- Style LSP floating windows to match catppuccin theme
    vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "NONE" })

    -- Set up LSP attach callback
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false

          if client:supports_method "textDocument/semanticTokens" then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end
      end,
    })

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

    -- Simple servers with default config
    -- Note: rubocop removed - Shopify's custom cops require Rails/ActiveSupport context
    local servers = { "html", "ts_ls", "clangd" }
    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end

    -- lua_ls with custom settings
    vim.lsp.config("lua_ls", {
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
    vim.lsp.enable("lua_ls")

    -- ruby_lsp must run under the project's OWN toolchain, not whatever is on
    -- Nvim's PATH. Two traps, both hit in practice:
    --   1. cmd as a plain list inherits Nvim's cwd, so `bundle exec` resolves
    --      whichever Gemfile sits above wherever Nvim started.
    --   2. Even with the right Gemfile, gems in vendor/bundle have native
    --      extensions linked to an absolute nix-store libruby. Running them
    --      under Homebrew's same-version Ruby fails with "linked to
    --      incompatible ... libruby". So re-enter the project env via direnv.
    vim.lsp.config("ruby_lsp", {
      cmd = function(dispatchers, config)
        local root = (config and (config.cmd_cwd or config.root_dir)) or vim.fn.getcwd()
        local argv = { "bundle", "exec", "ruby-lsp" }
        local env = { DIRENV_LOG_FORMAT = "" }

        if vim.fn.filereadable(root .. "/.envrc") == 1 and vim.fn.executable("direnv") == 1 then
          argv = { "direnv", "exec", root, "bundle", "exec", "ruby-lsp" }
          -- nix-direnv shells out to `nix`; if Nvim was launched from a GUI its
          -- PATH may not include the nix profile, and direnv then silently
          -- falls back to the ambient (wrong) Ruby.
          local nix_bin = "/nix/var/nix/profiles/default/bin"
          if vim.fn.isdirectory(nix_bin) == 1 then
            env.PATH = nix_bin .. ":" .. (vim.env.PATH or "")
          end
        end

        local gemfile = root .. "/Gemfile"
        if vim.fn.filereadable(gemfile) == 1 then
          env.BUNDLE_GEMFILE = gemfile
        end

        return vim.lsp.rpc.start(argv, dispatchers, { cwd = root, env = env })
      end,
      init_options = {
        formatter = "none", -- conform.nvim owns Ruby formatting
        linters = { "rubocop" },
      },
    })
    vim.lsp.enable("ruby_lsp")

    -- sorbet only in repos that actually have it configured
    if vim.fn.filereadable(vim.fn.getcwd() .. "/sorbet/config") == 1 then
      vim.lsp.enable("sorbet")
    end

    -- cssls with custom settings (only if executable exists)
    if vim.fn.executable("vscode-css-language-server") == 1 then
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
      vim.lsp.enable("cssls")
    end
  end,
}
