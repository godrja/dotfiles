vim.cmd.set("number")
vim.cmd.set("relativenumber")
vim.cmd.set("tabstop=4")
vim.cmd.set("shiftwidth=0")

-- Initalizing Lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- Done initializing Lazy

vim.g.mapleader = " "
require('lazy').setup({
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd [[colorscheme nightfly]]
		end
	},
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require "nvim-treesitter.configs".setup {
				ensure_installed = { "vim", "vimdoc", "lua", "rust", "typescript" },

				-- Make sure the previous command is executed async
				sync_install = false,

				-- Install new languages automatically (not sure if it is a good idea yet)
				auto_install = true,

				ignore_install = { "javascript" },

				highlight = {
					enabled = true,

					disable = {},

					additional_vim_regex_highlighting = false,
				},
				modules = {},
			}
		end,
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"folke/twilight.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require('mason').setup({})
		end
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "williamboman/mason.nvim" },
		},
		config = function()
			require "mason-lspconfig".setup({
				ensure_installed = { "lua_ls", "rust_analyzer", "tsserver" },
			})
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		config = function()
			vim.keymap.set({ "n", "x", "o" }, 's', function() require("flash").jump() end, { desc = "Flash" })
			vim.keymap.set({ "n", "x", "o" }, 'S', function() require("flash").treesitter() end,
				{ desc = "Flash Treesitter" })
			vim.keymap.set({ "x", "o" }, 'R', function() require("flash").treesitter_search() end,
				{ desc = "Treesitter Search" })
			-- vim.keymap.set({           "c" }, '<c-s>', function() require("flash").toggle() end, { desc = "Cancel Flash" })
			-- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
		end
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require('cmp_nvim_lsp').default_capabilities();
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
							version = 'LuaJIT',
						},
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { 'vim' },
						},
						workspace = {
							-- Make the server aware of Neovim runtime files
							library = vim.api.nvim_get_runtime_file("lua/", true) or {
								vim.fn.expand('$VIMRUNTIME/lua'),
								vim.fn.expand('$VIMRUNTIME/lua/vim/lsp'),
							}
						},
						-- Do not send telemetry data containing a randomized but unique identifier
						telemetry = {
							enable = true,
						},
					},
				},
			})
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities
			})
			lspconfig.tsserver.setup({
				capabilities = capabilities
			})
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client.server_capabilities.hoverProvider then
						vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
					end
					if client.server_capabilities.renameProvider then
						vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { buffer = args.buf })
					end
					if client.server_capabilities.codeActionProvider then
						vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { buffer = args.buf })
					end
					if client.server_capabilities.definitionProvider then
						vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf })
					end
					if client.server_capabilities.referencesProvider then
						vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = args.buf })
					end
					if client.server_capabilities.signatureHelpProvider then
						vim.keymap.set('n', '<C-K>', vim.lsp.buf.signature_help, { desc = "Signature Help" })
					end
					if client.server_capabilities.documentFormattingProvider then
						vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = "Format Buffer" })
					end
				end,
			})
		end
	},
	{
		"kyazdani42/nvim-tree.lua",
		config = function()
			require('nvim-tree').setup {}
			vim.keymap.set('n', '<leader>e', "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
		end,
	},
	-- {
	-- 	"nvim-neo-tree/neo-tree.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	-- 		"MunifTanjim/nui.nvim",
	-- 	},
	-- 	config = function()
	-- 		require('neo-tree').setup({
	-- 			sources = {
	-- 				"filesystem",
	-- 				"buffers",
	-- 				"git_status",
	-- 				"document_symbols",
	-- 			},
	-- 		})
	-- 	end,
	-- },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "neovim/nvim-lspconfig" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "L3MON4D3/LuaSnip" },
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources(
					{ { name = 'nvim_lsp' } },
					{ { name = 'buffer' } }
				),
			})

			local lspconfig = require('lspconfig')
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
		end
	},
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
		lazy = false,
	},
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			local builtin = require('telescope.builtin')
			local utils = require('telescope.utils')

			vim.keymap.set('n', '<leader>ff', function() builtin.find_files { cwd = utils.buffer_dir() } end, {})
			vim.keymap.set('n', '<leader>fg', function() builtin.live_grep { cwd = utils.buffer_dir() } end, {})
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'List Buffers' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
			vim.keymap.set('n', '<leader><Leader>', builtin.oldfiles, { desc = "Show Recent Files" })

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client.server_capabilities.documentSymbolProvider then
						vim.keymap.set('n', '<leader>ls', builtin.lsp_document_symbols, {})
						vim.keymap.set('n', '<leader>lDs', builtin.lsp_document_symbols, {})
					end
					if client.server_capabilities.workspaceSymbolProvider then
						vim.keymap.set('n', '<leader>lws', builtin.lsp_workspace_symbols, {})
					end
					vim.keymap.set('n', '<leader>ld', builtin.diagnostics, {})
				end
			})
		end
	},
	{
		"ahmedkhalf/project.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("project_nvim").setup {}
			require('telescope').load_extension('projects')
			vim.keymap.set('n', '<leader>p', function() require('telescope').extensions.projects.projects {} end,
				{ desc = "Show Projects" })
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = "Delete Current Buffer" })
			require "which-key".register(
				{
					b = { name = "Buffers" },
					t = { name = "Tabs" },
					f = {
						name = "Find",
						f = "Find Files",
						g = "Live Grep",
						h = "Help Tags",
					},
					l = {
						name = "LSP",
						a = "Code Actions",
						r = "Rename",
						s = "Document Symbols",
						d = "Document Diagnostics",
						D = {
							name = "Document",
							s = "Symbols",
						},
						w = {
							name = "Workspace",
							s = "Symbols",
						},
					},
				},
				{ prefix = "<leader>" }
			)
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{ "rafcamlet/nvim-luapad" },
	{ "tpope/vim-abolish" },
	{
		"nvim-neorg/neorg",
		dependecies = {
			{ "nvim-lua/plenary.nvim", },
		},
		build = ":Neorg sync-parsers",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("neorg").setup {
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.concealer"] = {}, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								notes = "~/notes",
							},
						},
					},
				},
			}
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require('gitsigns').setup()
		end,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"nvim-telescope/telescope.nvim", -- optional
			"sindrets/diffview.nvim", -- optional
		},
		config = true
	},
})
