
-- initialize lazy plugin manager.

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

local plugins = {
	-- kanagawa color theme
	{"rebelot/kanagawa.nvim",priority= 1000},
	}
local opts = {}

require("lazy").setup(plugins, ops)

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
