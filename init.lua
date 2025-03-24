-- vim global variables
vim.g.mapleader = " "

-- initialize lazy plugin manager.

--start
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- plugins
local plugins = {
	-- kanagawa color theme
	{ "rebelot/kanagawa.nvim",           priority = 1000 },
	-- telescope fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
	-- treesitter syntax highlighting
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	-- neotree file explorer tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
	},
	-- lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	-- LSP plugins (mason, mason-lspconfig, nvim-lspconfig)
	-- mason
	{ "williamboman/mason.nvim" },
	--mason-lspconfig (bridges mason with nvim-lspconfig)
	{ "williamboman/mason-lspconfig.nvim" },
	-- nvim-lspconfig
	{ "neovim/nvim-lspconfig" },
}

-- options settings
local opts = {}

require("lazy").setup(plugins, opts)
--end

-- keymaps
local builtin = require("telescope.builtin")
vim.keymap.set('n', "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set('n', "<leader>fg", builtin.live_grep, { desc = "Telescope find files" })
vim.keymap.set('n', "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set('n', "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
-- neotree keymap
vim.keymap.set('n', "<leader>e", "<Cmd>Neotree toggle<CR>", {})

vim.keymap.set('n', "<C-s>", "<Cmd> w <CR>", { desc = "Save file" })

-- configs

-- kanagawa config.
-- We could have also wrapped this in a function, and passed to config parameter in the kanagawa table in plugins table.
require("kanagawa").setup({
	commentStyle = { italic = true },
	keywordStyle = { bold = true },
	transparent = false,
	dimInactive = false,
	terminalColors = true,
	theme = "wave",
	background = {
		dark = "wave",
		light = "lotus"
	},
})

-- treesitter config.
local configs = require("nvim-treesitter.configs")
configs.setup({
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "rust", "cpp", "javascript", "html" },
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
})

-- lualine config.
require("lualine").setup({
	options = {
		theme = "dracula"
	}
})

-- LSP configs.

-- mason
require("mason").setup()

--mason-lspconfig
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "clangd" } -- contains lsp server names for different languags
})

-- lspconfig
local lspconfig = require("lspconfig")

-- setup for lua
lspconfig.lua_ls.setup({})

-- setup for clangd
lspconfig.clangd.setup({
	cmd = { "clangd" },
	filetypes = { "c", "cpp" },
	root_pattern = {
		".clangd",
		".git"
	},
	single_file_support = true
})

--apply the colorscheme
-- equivalent to vim.cmd("colorscheme kanagawa")
vim.cmd.colorscheme "kanagawa"
vim.cmd([[autocmd BufWritePre * lua vim.lsp.buf.format()]]) -- Format before saving the file
