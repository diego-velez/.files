local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.default_prog = { "fish", "-l" }

config.window_close_confirmation = "NeverPrompt"

config.enable_scroll_bar = true
wezterm.on("update-status", function(window, pane)
	local process_name = pane:get_foreground_process_name()
	local c = window:get_config_overrides() or {}
	if string.find(process_name, "fish") then
		c.enable_scroll_bar = true
	else
		c.enable_scroll_bar = false
	end
	window:set_config_overrides(c)
	wezterm:reload_configuration()
	return true
end)

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 12.5

local dracula = {
	foreground = "#F8F8F2",
	background = "#282A36",
	normal = {
		black = "#21222C",
		red = "#FF5555",
		green = "#50FA7B",
		yellow = "#F1FA8C",
		blue = "#BD93F9",
		magenta = "#FF79C6",
		cyan = "#8BE9FD",
		white = "#F8F8F2",
	},
	bright = {
		black = "#6272A4",
		red = "#FF6E6E",
		green = "#69FF94",
		yellow = "#FFFFA5",
		blue = "#D6ACFF",
		magenta = "#FF92DF",
		cyan = "#A4FFFF",
		white = "#FFFFFF",
	},
}

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.colors = {
	foreground = dracula.foreground,
	background = dracula.background,

	cursor_bg = dracula.foreground,
	cursor_fg = dracula.background,
	cursor_border = dracula.foreground,

	selection_bg = dracula.foreground,
	selection_fg = dracula.background,

	scrollbar_thumb = dracula.normal.blue,

	split = dracula.normal.blue,

	ansi = {
		dracula.normal.black,
		dracula.normal.red,
		dracula.normal.green,
		dracula.normal.yellow,
		dracula.normal.blue,
		dracula.normal.magenta,
		dracula.normal.cyan,
		dracula.normal.white,
	},
	brights = {
		dracula.bright.black,
		dracula.bright.red,
		dracula.bright.green,
		dracula.bright.yellow,
		dracula.bright.blue,
		dracula.bright.magenta,
		dracula.bright.cyan,
		dracula.bright.white,
	},
	tab_bar = {
		background = "rgba(40, 42, 54, 85%)",

		active_tab = {
			bg_color = dracula.background,
			fg_color = dracula.foreground,

			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = "rgba(40, 42, 54, 85%)",
			fg_color = dracula.foreground,

			intensity = "Half",
		},

		inactive_tab_hover = {
			bg_color = "rgba(40, 42, 54, 85%)",
			fg_color = dracula.foreground,

			intensity = "Half",
			italic = true,
			underline = "Single",
		},

		new_tab = {
			bg_color = "rgba(40, 42, 54, 85%)",
			fg_color = dracula.foreground,
		},

		new_tab_hover = {
			bg_color = "rgba(40, 42, 54, 85%)",
			fg_color = dracula.foreground,
			intensity = "Bold",
		},
	},
}
config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 0.8,
}
config.window_background_opacity = 0.85

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

--- Set a keymap for an action that only works when in Fish shell, otherwise send the keymap to
--- whatever program is running.
--- See https://wezfurlong.org/wezterm/config/keys.html
--- @param key string Key for activating the action.
--- @param mods string Modifiers required for activating the action.
--- @param action any Action to activate.
--- @return table
local function setKeymap(key, mods, action)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			local process_name = pane:get_foreground_process_name()
			if string.find(process_name, "fish") then
				win:perform_action(action, pane)
			else
				win:perform_action(act.SendKey({ key = key, mods = mods }), pane)
			end
		end),
	}
end

config.disable_default_key_bindings = true
config.keys = {
	{
		key = "t",
		mods = "ALT",
		action = act.ActivateKeyTable({
			name = "tab_shit",
		}),
	},
	{
		key = "w",
		mods = "ALT",
		action = act.ActivateKeyTable({
			name = "window_shit",
		}),
	},
	{
		key = "c",
		mods = "SHIFT|CTRL",
		action = act.CopyTo("Clipboard"),
	},
	{
		key = "v",
		mods = "SHIFT|CTRL",
		action = act.PasteFrom("Clipboard"),
	},
	setKeymap("u", "CTRL", act.ScrollByPage(-0.5)),
	setKeymap("d", "CTRL", act.ScrollByPage(0.5)),
	setKeymap("e", "CTRL", act.ScrollByLine(1)),
	setKeymap("y", "CTRL", act.ScrollByLine(-1)),
	setKeymap("Home", "", act.ScrollToTop),
	setKeymap("End", "", act.ScrollToBottom),
}

-- Bind moving to tab index by ALT+1 to 5
for i = 1, 5 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end

config.key_tables = {
	tab_shit = {
		{
			key = "Enter",
			mods = "",
			action = act.SpawnTab("CurrentPaneDomain"),
		},
		{
			key = "w",
			mods = "",
			action = act.CloseCurrentTab({ confirm = false }),
		},
		{
			key = "n",
			mods = "",
			action = act.ActivateTabRelative(1),
		},
		{
			key = "p",
			mods = "",
			action = act.ActivateTabRelative(-1),
		},
	},
	window_shit = {
		{
			key = "Enter",
			mods = "",
			action = act.SplitPane({
				direction = "Right",
				-- top_level = true,
			}),
		},
		{
			key = "w",
			mods = "",
			action = act.CloseCurrentPane({ confirm = false }),
		},
		{
			key = "n",
			mods = "",
			action = act.ActivatePaneDirection("Next"),
		},
		{
			key = "p",
			mods = "",
			action = act.ActivatePaneDirection("Prev"),
		},
	},
}

config.default_cursor_style = "SteadyBar"

return config
