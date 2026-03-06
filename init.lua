-- vim global variables
vim.g.mapleader = " "

-- vim opts
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.number = true
vim.clipboard = 'unnamedplus'
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
  {
    "rebelot/kanagawa.nvim",
    priority = 1000
  },
  -- telescope fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  { "nvim-telescope/telescope-ui-select.nvim" },
  -- treesitter syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
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

  -- Autocompletions and Snippets
  -- cmp nvim lsp
  { "hrsh7th/cmp-nvim-lsp" },
  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets"
    }
  },
  -- nvim-cmp
  { 'hrsh7th/nvim-cmp' },

  -- autoclose brackets
  { "m4xshen/autoclose.nvim" },

  -- folke which-key
  { "folke/which-key.nvim" },

  -- akinsho/toggleterm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },
  -- git signs
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
  },
  -- trouble diagnostics UI
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
  }
}

-- options settings
local opts = {}

require("lazy").setup(plugins, opts)
--end



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


-- telescope ui select config.
require("telescope").setup({
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
})

require("telescope").load_extension("ui-select")

-- lualine config.
require("lualine").setup({
  options = {
    theme = "dracula"
  }
})

-- trouble config
require("trouble").setup({})

-- gitsigns config

require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  current_line_blame = true,
})

-- toggleterm config
require("toggleterm").setup {
  direction = "float",
  open_mapping = [[<c-\]],
  shade_terminals = true
}

--codex terminal config
local Terminal = require("toggleterm.terminal").Terminal

local codex = Terminal:new({
  cmd = "codex",
  direction = "float",
  hidden = true,
  close_on_exit = false
})

function CodexToggle()
  codex:toggle()
end

-- autoclose bracket comfigs.
require("autoclose").setup()

-- LSP configs.

-- mason
require("mason").setup()

--mason-lspconfig
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "clangd", "basedpyright", "neocmake", "ts_ls" } -- contains lsp server names for different languags
})


-- Autocompletions configs.
require("luasnip.loaders.from_vscode").lazy_load()
local luasnip = require("luasnip")
local cmp = require("cmp")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<Tab>'] = cmp.mapping(function(fallback)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and
            vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") ==
            nil
      end
      if cmp.visible() then
        cmp.select_next_item()
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
        -- this way you will only jump inside the snippet region
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  completion = {
    completeopt = "menu,menuone,noinsert,noselect,preview",
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
})

-- setup for lua
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      }
    }
  }
})

-- setup for basedpyright
vim.lsp.config("basedpyright", {
  capabilities = capabilities
})

-- setup for clangd
vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd" },
  filetypes = { "c", "cpp" },
  root_pattern = {
    ".clangd",
    ".git"
  },
  single_file_support = true
})

--setup for tsserver
vim.lsp.config("ts_ls", {
  capabilities = capabilities
})

-- keymaps
local builtin = require("telescope.builtin")
vim.keymap.set('n', "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set('n', "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set('n', "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set('n', "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.keymap.set('n', "<leader>e", "<Cmd>Neotree toggle<CR>", {})

vim.keymap.set('n', "<C-s>", "<Cmd> w <CR>", { desc = "Save file" })

-- LSP keymaps
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
vim.keymap.set({ 'n', 'v' }, '<leader>ch', vim.diagnostic.open_float, {})
vim.keymap.set({ 'n', 't' }, '<leader>ai', function()
  if vim.bo.buftype == "terminal" then
    vim.cmd("stopinsert")
  end
  codex:toggle()
end, { desc = "Toggle Codex" })


-- gitsigns keymaps

vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle blame" })
vim.keymap.set("n", "]h", ":Gitsigns next_hunk<CR>", { desc = "Next hunk" })
vim.keymap.set("n", "[h", ":Gitsigns prev_hunk<CR>", { desc = "Prev hunk" })


-- trouble keymaps
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix" })
vim.keymap.set("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", { desc = "References" })
vim.keymap.set("n", "<leader>xd", "<cmd>Trouble lsp_definitions toggle<cr>", { desc = "Definitions" })

--apply the colorscheme
-- equivalent to vim.cmd("colorscheme kanagawa")
vim.cmd.colorscheme "kanagawa"

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    vim.lsp.buf.format({ bufnr = args.buf })
  end,
})
