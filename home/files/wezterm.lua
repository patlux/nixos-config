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
local workspace_names = {
	"patwoz",
	"piparo.tech",
	"ibm",
	"init",
	"fwmfl",
	"enerparc",
	"mueller",
}

local workspace_layouts = {
	["piparo.tech"] = {
		"~/dev/piparo.tech",
	},
	fwmfl = {
		"~/dev/piparo.tech/kicker",
	},
	ibm = {
		"~/dev/ibm/kompass/kompass-frontend-2",
		"~/dev/ibm/kompass/kompass-frontend-2",
		"~/dev/ibm/kompass/kompass-frontend-2",
	},
	init = {
		"~/dev/init/eva",
		"~/dev/init/eva",
		"~/dev/init/eva/apps/etb",
	},
}

local function expand_home(path)
	if type(path) == "string" and path:sub(1, 2) == "~/" then
		return wezterm.home_dir .. path:sub(2)
	end
	return path
end

local function workspace_has_windows(name)
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		if mux_win:get_workspace() == name then
			return true
		end
	end
	return false
end

local function ensure_workspace_layout(name)
	local layout = workspace_layouts[name]
	if not layout or #layout == 0 or workspace_has_windows(name) then
		return
	end

	local _, _, mux_win = wezterm.mux.spawn_window({
		workspace = name,
		cwd = expand_home(layout[1]),
	})

	if mux_win then
		for idx = 2, #layout do
			mux_win:spawn_tab({ cwd = expand_home(layout[idx]) })
		end
	end
end

local function switch_workspace(win, pane, name)
	if not name or name == "" then
		return
	end

	ensure_workspace_layout(name)
	win:perform_action(act.SwitchToWorkspace({ name = name }), pane)
end

local function workspace_choices()
	local choices = {}
	for _, workspace in ipairs(workspace_names) do
		table.insert(choices, { id = workspace, label = workspace })
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
	window:set_left_status(wezterm.format({
		{ Background = { Color = "#2d3149" } },
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
