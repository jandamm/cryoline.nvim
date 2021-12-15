local M = {}
local config = { line = '%#WarningMsg#%f %h%w%m%r %=%#Error# Cryoline %#WarningMsg#%=%(%l,%c%V %= %P%)' }

function M.get_statusline()
	return "%!v:lua.require'cryoline'.line()"
end

function M.config(user_config)
	if user_config then
		if type(user_config) == 'function' or type(user_config) == 'string' then
			config.line = user_config
		elseif type(user_config) == 'table' then
			if user_config.force_ft then
				local au = user_config.force_autocmd or {}
				au.Filetype = vim.tbl_extend('keep', au.Filetype or {}, user_config.force_ft)
				user_config.force_autocmd = au
				user_config.force_ft = nil
			end
			config = vim.tbl_extend('keep', user_config, config)
		else
			error('Cryoline setup needs a table, function or string, not ' .. type(user_config) .. '.')
		end
	end

	local line = M.get_statusline()
	vim.opt.statusline = line
	if config.force_autocmd then
		vim.cmd 'augroup cryoline | autocmd! | augroup END'
		for au, pat in pairs(config.force_autocmd) do
			local cmd = au .. ' ' .. table.concat(pat, ',')
			vim.cmd('autocmd cryoline ' .. cmd .. ' lua vim.schedule(function() vim.wo.statusline = "' .. line .. '" end)')
		end
	end
end

function M.line()
	local winid = vim.g.statusline_winid
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
	local context = {
		active = winid == vim.api.nvim_get_current_win(),
		bufnr = bufnr,
		ft = ft,
		winid = winid,
	}
	context.resolved_ft = config.ft and config.resolve_ft and config.resolve_ft(context)
	local line = config.ft and config.ft[context.resolved_ft or ft] or config.line
	if type(line) == 'string' then
		return line
	elseif type(line) == 'function' then
		if config.extend_context then
			config.extend_context(context)
		end
		return line(context) or ''
	end
	return '%#Error#%f%=Cryoline: Not configured correctly. Line type for ' .. context.ft .. ' is ' .. type(line) .. '.'
end

return M
