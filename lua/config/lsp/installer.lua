local lsp_installer_servers = require("nvim-lsp-installer.servers")
local utils = require("utils")

local vim = vim

local M = {}

function M.setup(servers, options)
	for server_name, _ in pairs(servers) do
		local server_available, server = lsp_installer_servers.get_server(server_name)
		require("lspconfig")[server_name].setup({
			on_attach = function(client, bufnr)
				require("lsp_signature").on_attach() -- Note: add in lsp client on-attach
			end,
		})

		if server_available then
			server:on_ready(function()
				local opts = vim.tbl_deep_extend("force", options, servers[server.name] or {})

				-- For coq.nvim
				local coq = require("coq")
				server:setup(coq.lsp_ensure_capabilities(opts))
			end)

			if not server:is_installed() then
				utils.info("Installing " .. server.name)
				server:install()
			end

			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
						-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
						-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
						vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
					end,
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "vsnip" }, -- For vsnip users.
					-- { name = 'luasnip' }, -- For luasnip users.
					{ name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = "buffer" },
				}),
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
				}, {
					{ name = "buffer" },
				}),
			})

			-- Setup lspconfig.
			local capabilities = require("cmp_nvim_lsp").update_capabilities(
				vim.lsp.protocol.make_client_capabilities()
			)
			-- Replace <> with each lsp server you've enabled.
			require("lspconfig")[server_name].setup({
				capabilities = capabilities,
			})
		else
			utils.error(server)
		end
	end
end

return M
