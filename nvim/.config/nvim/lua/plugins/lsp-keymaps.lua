return {
	"neovim/nvim-lspconfig",
	keys = {
		-- LSP management commands
		{
			"<leader>li",
			"<cmd>LspInfo<cr>",
			desc = "LSP Info",
		},
		{
			"<leader>lr",
			"<cmd>LspRestart<cr>",
			desc = "LSP Restart",
		},
		{
			"<leader>ls",
			"<cmd>LspStart<cr>",
			desc = "LSP Start",
		},
		{
			"<leader>lt",
			"<cmd>LspStop<cr>",
			desc = "LSP Stop",
		},
		{
			"<leader>ll",
			"<cmd>LspLog<cr>",
			desc = "LSP Log",
		},
	},
	config = function()
		-- Style LSP floating windows to match catppuccin theme
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "NONE" }) -- Catppuccin blue

		-- Set up LSP keymaps when LSP attaches
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				local opts = { buffer = ev.buf, noremap = true, silent = true }

				-- Navigation
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
				vim.keymap.set("n", "gr", function()
					require("fzf-lua").lsp_references()
				end, vim.tbl_extend("force", opts, { desc = "Go to References" }))
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))

				-- Hover documentation
				vim.keymap.set("n", "K", function()
					vim.lsp.buf.hover({ border = "rounded" })
				end, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))

				-- Code actions
				vim.keymap.set(
					{ "n", "v" },
					"<leader>ca",
					vim.lsp.buf.code_action,
					vim.tbl_extend("force", opts, { desc = "Code Action" })
				)

				-- Diagnostics
				vim.keymap.set(
					"n",
					"<leader>cd",
					vim.diagnostic.open_float,
					vim.tbl_extend("force", opts, { desc = "Show Diagnostics" })
				)
				vim.keymap.set(
					"n",
					"[d",
					vim.diagnostic.goto_prev,
					vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" })
				)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
				vim.keymap.set(
					"n",
					"<leader>cl",
					vim.diagnostic.setloclist,
					vim.tbl_extend("force", opts, { desc = "Diagnostics to Location List" })
				)

				-- Signature help
				vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Help" }))

				-- Rename
				vim.keymap.set("n", "<leader>cR", function()
					Snacks.rename()
				end, vim.tbl_extend("force", opts, { desc = "Rename (LSP)" }))
			end,
		})

	end,
}
