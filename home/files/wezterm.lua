local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Sonokai (Gogh)"
config.font = wezterm.font("MesloLGS Nerd Font")
config.font_size = 20.0

config.tab_bar_at_bottom = true

-- Left Option + n = ~
config.send_composed_key_when_left_alt_is_pressed = true

config.window_padding = {
	left = 0,
	right = 0,
	top = "1%",
	bottom = 0,
}

config.window_decorations = "RESIZE"

function active_tab_idx(mux_win)
	for _, item in ipairs(mux_win:tabs_with_info()) do
		-- wezterm.log_info('idx: ', idx, 'tab:', item)
		if item.is_active then
			return item.index
		end
	end
end

local act = wezterm.action
local workspaces = {
	{ name = "patwoz", status_bg = "#000000" },
	{
		name = "piparo.tech",
		status_bg = "#1b365d",
		tabs = {
			{ cwd = "~/dev/piparo.tech", title = "opencode", command = "opencode" },
			{ cwd = "~/dev/piparo.tech", title = "vim", command = "nvim" },
		},
	},
	{
		name = "ibm",
		status_bg = "#69a500",
		tabs = {
			{ cwd = "~/dev/ibm/kompass/kompass-frontend-2" },
			{ cwd = "~/dev/ibm/kompass/kompass-frontend-2" },
			{ cwd = "~/dev/ibm/kompass/kompass-frontend-2" },
		},
	},
	{
		name = "init",
		status_bg = "#008a7d",
		tabs = {
			{ cwd = "~/dev/init/eva", title = "opencode", command = "opencode" },
			{ cwd = "~/dev/init/eva", title = "vim", command = "nvim" },
		},
	},
	{
		name = "fwmfl",
		status_bg = "#d0281d",
		tabs = {
			{ cwd = "~/dev/piparo.tech/kicker" },
		},
	},
	{
		name = "enerparc",
		status_bg = "#007391",
		tabs = {
			{ cwd = "~/dev/enerparc/frontend", title = "opencode", command = "opencode" },
			{ cwd = "~/dev/enerparc/frontend", title = "vim", command = "nvim" },
			{ cwd = "~/dev/enerparc/frontend" },
		},
	},
	{ name = "mueller", status_bg = "#b75a00" },
}

local workspace_names = {}
local workspace_lookup = {}
local initialized_workspaces = {}
local default_workspace_status_bg = "#2d3149"

for idx, workspace in ipairs(workspaces) do
	workspace_names[idx] = workspace.name
	workspace_lookup[workspace.name] = workspace
end

local function expand_home(path)
	if path == "~" then
		return wezterm.home_dir
	end
	if type(path) == "string" and path:sub(1, 2) == "~/" then
		return wezterm.home_dir .. path:sub(2)
	end
	return path
end

local function shell_quote(path)
	return "'" .. tostring(path):gsub("'", "'\\''") .. "'"
end

local function directory_exists(path)
	local ok, _, code = os.execute("test -d " .. shell_quote(path))
	if ok == true then
		return true
	end
	if type(ok) == "number" then
		return ok == 0
	end
	return code == 0
end

local function tab_spawn_args(tab)
	if type(tab.args) == "table" and #tab.args > 0 then
		return tab.args
	end
	if type(tab.command) == "string" and tab.command ~= "" then
		return { "/bin/zsh", "-lc", tab.command }
	end
	return nil
end

local function notify_path_fallback(win, workspace_name, tab, missing_path)
	local tab_name = tab.title or "tab"
	local message = string.format("%s/%s missing: %s; using ~", workspace_name, tab_name, missing_path)
	wezterm.log_warn(message)
	if win and win.toast_notification then
		win:toast_notification("WezTerm workspace", message, nil, 5000)
	end
end

local function resolve_tab_cwd(win, workspace_name, tab)
	local resolved = expand_home(tab.cwd or "~")
	if directory_exists(resolved) then
		return resolved
	end
	notify_path_fallback(win, workspace_name, tab, resolved)
	return wezterm.home_dir
end

local function set_tab_title(tab, title)
	if tab and title and title ~= "" then
		tab:set_title(title)
	end
end

local function workspace_has_windows(name)
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		if mux_win:get_workspace() == name then
			return true
		end
	end
	return false
end

local function ensure_workspace_layout(name, win)
	if initialized_workspaces[name] then
		return
	end

	local workspace = workspace_lookup[name]
	if not workspace then
		return
	end

	local tabs = workspace.tabs
	if not tabs or #tabs == 0 then
		initialized_workspaces[name] = true
		return
	end

	if workspace_has_windows(name) then
		initialized_workspaces[name] = true
		return
	end

	local first_tab = tabs[1]
	local first_spawn = {
		workspace = name,
		cwd = resolve_tab_cwd(win, name, first_tab),
	}
	local first_args = tab_spawn_args(first_tab)
	if first_args then
		first_spawn.args = first_args
	end

	local created_tab, _, mux_win = wezterm.mux.spawn_window(first_spawn)
	set_tab_title(created_tab, first_tab.title)

	if mux_win then
		for idx = 2, #tabs do
			local tab_spec = tabs[idx]
			local tab_spawn = {
				cwd = resolve_tab_cwd(win, name, tab_spec),
			}
			local tab_args = tab_spawn_args(tab_spec)
			if tab_args then
				tab_spawn.args = tab_args
			end

			local tab = mux_win:spawn_tab(tab_spawn)
			set_tab_title(tab, tab_spec.title)
		end
	end

	initialized_workspaces[name] = true
end

local function switch_workspace(win, pane, name)
	if not name or name == "" then
		return
	end

	ensure_workspace_layout(name, win)
	win:perform_action(act.SwitchToWorkspace({ name = name }), pane)
end

local function workspace_choices()
	local choices = {}
	for _, workspace in ipairs(workspaces) do
		local label = workspace.name
		local first_tab = workspace.tabs and workspace.tabs[1] or nil
		if first_tab and first_tab.cwd and first_tab.cwd ~= "" then
			label = string.format("%s - %s", workspace.name, first_tab.cwd)
		end
		table.insert(choices, { id = workspace.name, label = label })
	end
	return choices
end

local function workspace_index(name)
	for idx, workspace in ipairs(workspace_names) do
		if workspace == name then
			return idx
		end
	end
	return 1
end

local function switch_workspace_relative(win, pane, offset)
	local current = win:active_workspace()
	local idx = workspace_index(current)
	local next_idx = ((idx - 1 + offset) % #workspace_names) + 1

	switch_workspace(win, pane, workspace_names[next_idx])
end

config.default_workspace = workspace_names[1]

config.keys = {
	{ key = ".", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = ",", mods = "CTRL", action = act.ActivateTabRelative(-1) },
	{
		key = "h",
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			switch_workspace_relative(win, pane, -1)
		end),
	},
	{
		key = "l",
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			switch_workspace_relative(win, pane, 1)
		end),
	},
	{ key = ".", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },
	{ key = ",", mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "n", mods = "OPT", action = act({ SendString = "~" }) },
	{
		key = "w",
		mods = "CMD|CTRL",
		action = act.InputSelector({
			title = "Select workspace",
			choices = workspace_choices(),
			fuzzy = true,
			action = wezterm.action_callback(function(win, pane, id)
				switch_workspace(win, pane, id)
			end),
		}),
	},
	{
		key = "w",
		mods = "CMD|SHIFT",
		action = act.PromptInputLine({
			description = "Create or switch to workspace",
			action = wezterm.action_callback(function(win, pane, line)
				switch_workspace(win, pane, line)
			end),
		}),
	},
	-- { key = "l", mods = "CTRL", action = wezterm.action({ EmitEvent = "toggle-dark-mode" }) },
	{
		key = "t",
		mods = "CMD",
		-- https://github.com/wez/wezterm/issues/909
		action = wezterm.action_callback(function(win, pane)
			local mux_win = win:mux_window()
			local idx = active_tab_idx(mux_win)
			-- wezterm.log_info('active_tab_idx: ', idx)
			local tab = mux_win:spawn_tab({})
			-- wezterm.log_info('movetab: ', idx)
			win:perform_action(wezterm.action.MoveTab(idx + 1), pane)
		end),
	},
}

for idx, workspace in ipairs(workspace_names) do
	table.insert(config.keys, {
		key = tostring(idx),
		mods = "CMD|ALT",
		action = wezterm.action_callback(function(win, pane)
			switch_workspace(win, pane, workspace)
		end),
	})
end

wezterm.on("update-right-status", function(window, pane)
	local workspace = window:active_workspace()
	local workspace_config = workspace_lookup[workspace] or {}
	local workspace_status_bg = workspace_config.status_bg or default_workspace_status_bg
	window:set_left_status(wezterm.format({
		{ Background = { Color = workspace_status_bg } },
		{ Foreground = { Color = "#f9f5d7" } },
		{ Text = "  " .. workspace .. "  " },
	}))
end)

-- toggle light/dark scheme with CTRL+l
wezterm.on("toggle-dark-mode", function(window, pane)
	-- local light_scheme = "Summerfruit Light (base16)"
	local light_scheme = "Alabaster"
	local dark_scheme = "Sonokai (Gogh)"
	local overrides = window:get_config_overrides() or {}
	wezterm.log_info("Current color scheme is: ", overrides.color_scheme)
	if overrides.color_scheme == light_scheme then
		wezterm.log_info("Setting to Dark Scheme: ", overrides.color_scheme)
		overrides.color_scheme = dark_scheme
	else
		wezterm.log_info("Setting to Light ", overrides.color_scheme)
		overrides.color_scheme = light_scheme
	end
	window:set_config_overrides(overrides)
end)

return config
