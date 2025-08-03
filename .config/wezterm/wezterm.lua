local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.term = "wezterm"
config.default_prog = { "fish", "-l" }

config.window_close_confirmation = "NeverPrompt"

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 11

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = "Dracula"
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
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "ALT",
		action = act.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "f", -- [F]orward
		mods = "ALT",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "b", -- [B]ackward
		mods = "ALT",
		action = act.ActivateTabRelative(-1),
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
	{ -- [I]ncrease font size
		key = "i",
		mods = "SHIFT|CTRL|ALT",
		action = act.IncreaseFontSize,
	},
	{ -- [D]ecrease font size
		key = "d",
		mods = "SHIFT|CTRL|ALT",
		action = act.DecreaseFontSize,
	},
	{ -- [R]eset font size
		key = "r",
		mods = "SHIFT|CTRL|ALT",
		action = act.ResetFontSize,
	},
	setKeymap("u", "CTRL", act.ScrollByPage(-0.5)),
	setKeymap("d", "CTRL", act.ScrollByPage(0.5)),
	setKeymap("e", "CTRL", act.ScrollByLine(1)),
	setKeymap("y", "CTRL", act.ScrollByLine(-1)),
	setKeymap("Home", "CTRL", act.ScrollToTop),
	setKeymap("End", "CTRL", act.ScrollToBottom),
	-- Enter copy [m]ode
	setKeymap("m", "CTRL", act.ActivateCopyMode),
	-- [O]pen project
	setKeymap("o", "CTRL", act.SendString("~/.config/wezterm/open_project\n")),
}

-- Bind moving to tab index by ALT+1 to 9
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end

config.default_cursor_style = "SteadyBar"

return config
