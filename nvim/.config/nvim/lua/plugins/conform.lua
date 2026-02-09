return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      ruby = { "rubocop" },
      lua = { "stylua" },
      cpp = { "clang_format" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
    },
    formatters = {
      rubocop = {
        command = vim.fn.expand("~/.config/nvim/rubocop-formatter-wrapper.sh"),
        args = { "--auto-correct-all", "--format", "quiet", "--stderr", "--stdin", "$FILENAME" },
        stdin = true,
        cwd = function(self, ctx)
          local root_file = require("conform.util").root_file({ "dev.yml", ".shadowenv.d", ".rubocop.yml", "Gemfile" })
          return root_file(self, ctx)
        end,
      },
    },
  },
}
