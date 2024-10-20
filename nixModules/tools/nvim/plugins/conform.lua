require("conform").setup({
	formatters_by_ft = {
		rust = { "rustfmt" },
		lua = { "stylua" },
		nix = { "alejandra" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		glsl = { "clang_format" },
		vert = { "clang_format" },
		frag = { "clang_format" },
		csharp = { "dotnet-csharpier" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		css = { "prettierd" },
		scss = { "prettierd" },
		html = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		asm = { "asmfmt" },
		zig = { "zig fmt" },
		sh = { "shfmt" },
		cs = { "csharpier" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.g.zig_fmt_parse_errors = 0
