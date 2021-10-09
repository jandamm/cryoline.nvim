local M = {}
local config = { line = "%#WarningMsg#%f %h%w%m%r %=%#Error# Cryoline %#WarningMsg#%=%(%l,%c%V %= %P%)" }

function M.config(user_config)
	if user_config then
		if type(user_config) == "function" or type(user_config) == "string" then
			config.line = user_config
		elseif type(user_config) == "table" then
			config = vim.tbl_extend("keep", user_config, config)
		else
			error("Cryoline setup needs a table, function or string, not " .. type(user_config) .. ".")
		end
	end

	local line = "%!v:lua.require'cryoline'.line()"
	vim.opt.statusline = line
	if config.force_ft then
		vim.cmd("augroup cryoline | autocmd! | augroup END")
		for _, ft in pairs(config.force_ft) do
			vim.cmd("autocmd cryoline Filetype " .. ft .. " setlocal statusline=" .. line)
		end
	end
end

function M.line()
	local winid = vim.g.statusline_winid
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local context = {
		active = winid == vim.api.nvim_get_current_win(),
		bufnr = bufnr,
		ft = vim.api.nvim_buf_get_option(bufnr, "filetype"),
		winid = winid,
	}
	context.resolved_ft = config.ft and config.resolve_ft and config.resolve_ft(vim.deepcopy(context))
	local line = config.ft and config.ft[context.resolved_ft or context.ft] or config.line
	if type(line) == "string" then
		return line
	elseif type(line) == "function" then
		return line(context)
	end
	return "%#Error#%f%=Cryoline: Not configured correctly. Line type for " .. context.ft .. " is " .. type(line) .. "."
end

return M
