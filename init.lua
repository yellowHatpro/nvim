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
      { out, "WarningMsg" },
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
	{"rebelot/kanagawa.nvim",priority= 1000},
	-- telescope fuzzy finder
	{ "nvim-telescope/telescope.nvim", tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim"}
	},
}

-- options settings
local opts = {}

require("lazy").setup(plugins, ops)
--end

-- keymaps
local builtin = require("telescope.builtin")
vim.keymap.set('n', "<leader>ff", builtin.find_files, {desc = "Telescope find files"})
vim.keymap.set('n', "<leader>fg", builtin.live_grep, {desc = "Telescope find files"})
vim.keymap.set('n', "<leader>fb", builtin.buffers, {desc = "Telescope buffers"})
vim.keymap.set('n', "<leader>fh", builtin.help_tags, {desc = "Telescope help tags"})

-- kanagawa config.
-- We could have also wrapped this in a function, and passed to config parameter in the kanagawa table in plugins table.
require("kanagawa").setup({
	commentStyle = {italic = true },
	keywordStyle = {bold = true},
	transparent = false,
	dimInactive = false,
	terminalColors = true,
	theme = "wave",
	background = {
		dark = "wave",
		light = "lotus"
		},
})

--apply the colorscheme
-- equivalent to vim.cmd("colorscheme kanagawa")
vim.cmd.colorscheme "kanagawa"
