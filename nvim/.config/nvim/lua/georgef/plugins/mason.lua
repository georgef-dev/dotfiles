return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
      },
    })
    
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "cssls",
        "html",
        "tsserver",
        "clangd",
        "ruby_lsp",
        "sorbet",
      },
      automatic_installation = true,
    })
  end,
}
