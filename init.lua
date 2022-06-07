local vim = vim

local o = vim.o
local bo = vim.bo
local wo = vim.wo
local g = vim.g

o.encoding = "UTF-8"
o.wildmenu = true
o.termguicolors = true
o.syntax = "on"
o.ignorecase = true
o.errorbells = false
o.smartcase = true
o.showmode = false
o.scrolloff = 1
bo.swapfile = false
o.backup = false
o.undodir = vim.fn.stdpath("config") .. "/undodir"
o.undofile = true
o.incsearch = true
o.hidden = true
o.completeopt = "menuone,noinsert,noselect"
bo.autoindent = true
bo.smartindent = true
o.tabstop = 2
o.softtabstop = 2
o.so = 15
o.cmdheight = 1
o.shiftwidth = 2
o.expandtab = true
o.laststatus = 2
g.autoread = true
g.autowrite = true
g.auto_save = 1
wo.number = true
wo.cursorline = true
wo.relativenumber = true
wo.signcolumn = "yes"
wo.wrap = false

g.coq_settings = {
	auto_start = true,
}
g.mapleader = " "
g.netrw_banner = 0

local key_mapper = function(mode, key, result)
	vim.api.nvim_set_keymap(mode, key, result, { noremap = true, silent = true })
end

local execute = vim.api.nvim_command
local fn = vim.fn

-- ensure that packer is installed
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
	execute("packadd packer.nvim")
end
vim.cmd("packadd packer.nvim")
local packer = require("packer")
local util = require("packer.util")
packer.init({
	package_root = util.join_paths(vim.fn.stdpath("data"), "site", "pack"),
})
--- startup and add configure plugins
--
packer.startup({
	function()
		local use = use

		use("wbthomason/packer.nvim")

		use("jose-elias-alvarez/null-ls.nvim")
		use({
			"folke/trouble.nvim",
			requires = "kyazdani42/nvim-web-devicons",
			config = function()
				require("trouble").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})

		use({
			"gelguy/wilder.nvim",
			config = function()
				-- config goes here
			end,
		})

		use({
			"folke/which-key.nvim",
			config = function()
				require("which-key").setup({
					-- your configuration comes here
					-- or leave it empty to use the default settings
					-- refer to the configuration section below
				})
			end,
		})

		use("Pocco81/AutoSave.nvim")
		use("sheerun/vim-polyglot")
		use("nvim-lua/popup.nvim")
		use("nvim-lua/plenary.nvim")
		use("nvim-lua/telescope.nvim")
		use("tami5/sqlite.lua")
		use("jremmen/vim-ripgrep")
		use({ "echasnovski/mini.nvim", branch = "stable" })

		use("SirVer/ultisnips")
		use("hrsh7th/vim-vsnip")
		use("hrsh7th/vim-vsnip-integ")
		use("neovim/nvim-lspconfig") -- Collection of configurations for built-in LSP client
		use("hrsh7th/nvim-cmp") -- Autocompletion plugin
		use("hrsh7th/cmp-nvim-lsp") -- LSP source for nvim-cmp
		use("saadparwaiz1/cmp_luasnip") -- Snippets source for nvim-cmp
		use("L3MON4D3/LuaSnip") --

		use({
			"jghauser/mkdir.nvim",
		})
		use("ray-x/lsp_signature.nvim")
		use({
			"williamboman/nvim-lsp-installer",
			"neovim/nvim-lspconfig",
		})
		use("norcalli/nvim-colorizer.lua")
		use("tjdevries/colorbuddy.nvim")
		use("bkegley/gloombuddy")
		use("ellisonleao/gruvbox.nvim")

		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
		})

		use({
			"ms-jpq/coq_nvim",
			config = function()
				require("config.coq").setup()
			end,
			requires = {
				{ "ms-jpq/coq.artifacts", branch = "artifacts" },
				{ "ms-jpq/coq.thirdparty", branch = "3p", module = "coq_3p" },
			},
		})

		use({
			"lewis6991/gitsigns.nvim",
			requires = { "nvim-lua/plenary.nvim" },
			config = function()
				require("gitsigns").setup()
			end,
		})

		use({ "prettier/vim-prettier", run = "yarn install" })
	end,
})

vim.opt.background = "dark"
vim.cmd([[colorscheme gruvbox]])

vim.api.nvim_create_autocmd("BufEnter", {
	command = "if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif",
	nested = true,
})

local wilder = require("wilder")
wilder.setup({ modes = { ":", "/", "?" } })
wilder.set_option("pipeline", {
	wilder.branch(wilder.cmdline_pipeline({
		-- sets the language to use, 'vim' and 'python' are supported
		language = "python",
		-- 0 turns off fuzzy matching
		-- 1 turns on fuzzy matching
		-- 2 partial fuzzy matching (match does not have to begin with the same first letter)
		fuzzy = 2,
	})),
})

require("lsp_signature").setup({})
require("colorizer").setup()

require("mini.trailspace").setup({})

require("mini.pairs").setup({})

require("mini.indentscope").setup({
	draw = {
		delay = 0,
	},
})

require("mini.comment").setup({})

require("mini.surround").setup({})

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = { "javascript", "lua", "go" },
})

local autosave = require("autosave")

autosave.setup({
	enabled = true,
	execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
	events = { "InsertLeave", "TextChanged" },
	conditions = {
		exists = true,
		filename_is_not = {},
		filetype_is_not = {},
		modifiable = true,
	},
	write_all_buffers = false,
	on_off_commands = true,
	clean_command_line_interval = 0,
	debounce_delay = 135,
})

-- setup language servers here
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	callback = function()
		require("mini.trailspace").trim()
	end,
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
require("null-ls").setup({
	sources = {
		require("null-ls").builtins.formatting.stylua,
		require("null-ls").builtins.diagnostics.eslint,
		require("null-ls").builtins.completion.spell,
	},
	-- you can reuse a shared lspconfig on_attach callback here
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					vim.lsp.buf.formatting_sync()
				end,
			})
		end
	end,
})

key_mapper("", "<Leader>q", ":q!<CR>")

key_mapper("n", "<leader>f", ':lua require"telescope.builtin".find_files()<CR>')
key_mapper("n", "<leader>n", ':if &ft ==# "netrw" ""<CR>:Rexplore<CR>else<CR>:Explore<CR>endif<CR><CR>')
key_mapper("n", "<leader>h", ':lua require"telescope.builtin".oldfiles()<CR>')

key_mapper("n", "<leader>v", ":vs<CR>")
