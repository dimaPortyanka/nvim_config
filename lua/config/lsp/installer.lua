local lsp_installer_servers = require("nvim-lsp-installer.servers")
local utils = require("utils")

local vim = vim

local M = {}

function M.setup(servers, options)
	for server_name, _ in pairs(servers) do
		local server_available, server = lsp_installer_servers.get_server(server_name)
		require("lspconfig")[server_name].setup({
			on_attach = function()
				require("lsp_signature").on_attach() -- Note: add in lsp client on-attach
			end,
		})

		if server_available then
			server:on_ready(function()
				local opts = vim.tbl_deep_extend("force", options, servers[server.name] or {})

				-- For coq.nvim

				vim.g.coq_settings = { auto_start = true, clients = { tabnine = { enabled = true } } }
				local coq = require("coq")
				server:setup(coq.lsp_ensure_capabilities(opts))
			end)

			if not server:is_installed() then
				utils.info("Installing " .. server.name)
				server:install()
			end

			-- Replace <> with each lsp server you've enabled.
			require("lspconfig")[server_name].setup({
				capabilities = capabilities,
			})
		else
			utils.error(server)
		end
	end

	local sumneko_root_path = os.getenv("HOME") .. "/tools/lua-language-server"
	local sumneko_binary_path = sumneko_root_path .. "/bin/lua-language-server"

	local runtime_path = vim.split(package.path, ";")
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")

	require("lspconfig").sumneko_lua.setup({
		cmd = { sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" },
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
					-- Setup your lua path
					path = runtime_path,
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = vim.api.nvim_get_runtime_file("", true),
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		},
	})
end

return M
