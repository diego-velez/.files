---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action

local leader = "CTRL|SHIFT"

---@type Key[]
local keys = {
	{
		key = "t",
		mods = leader,
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = leader,
		action = act.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "n",
		mods = leader,
		action = act.ActivateTabRelative(1),
	},
	{
		key = "p",
		mods = leader,
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "c",
		mods = leader,
		action = act.CopyTo("Clipboard"),
	},
	{
		key = "v",
		mods = leader,
		action = act.PasteFrom("Clipboard"),
	},
	{ -- [I]ncrease font size
		key = "F11",
		action = act.IncreaseFontSize,
	},
	{ -- [D]ecrease font size
		key = "F12",
		action = act.DecreaseFontSize,
	},
	{ -- [R]eset font size
		key = "F10",
		action = act.ResetFontSize,
	},
	-- NOTE: This is useful when you need to debug
	-- {
	-- 	key = "l",
	-- 	mods = "CTRL",
	-- 	action = act.ShowDebugOverlay,
	-- },
	{
		key = "o", -- Close [O]ther tabs
		mods = leader,
		action = wezterm.action_callback(function(win, _)
			local mux_window = win:mux_window()
			local current_tab = mux_window:active_tab()

			local tabs_to_close = #mux_window:tabs() - 1

			-- End early if there are no other tabs
			if tabs_to_close == 0 then
				return
			end

			for _, tab in ipairs(mux_window:tabs()) do
				if tab:tab_id() ~= current_tab:tab_id() then
					tab:activate()
					win:perform_action(act.CloseCurrentTab({ confirm = false }), win:active_pane())
				end
			end

			win:toast_notification(
				"Closed Other Tabs",
				"Closed " .. tabs_to_close .. " tabs in the current Wezterm session",
				nil,
				4000
			)
		end),
	},
	{
		key = "u",
		mods = leader,
		action = act.ScrollByPage(-0.5),
	},
	{
		key = "d",
		mods = leader,
		action = act.ScrollByPage(0.5),
	},
	{
		key = "e",
		mods = leader,
		action = act.ScrollByLine(1),
	},
	{
		key = "y",
		mods = leader,
		action = act.ScrollByLine(-1),
	},
	{
		key = "Home",
		mods = leader,
		action = act.ScrollToTop,
	},
	{
		key = "End",
		mods = leader,
		action = act.ScrollToBottom,
	},
	{ -- Enter copy [m]ode
		key = "m",
		mods = leader,
		action = act.ActivateCopyMode,
	},
	{
		key = "f",
		mods = leader,
		action = act.Search({ CaseInSensitiveString = "" }),
	},
	{
		key = "s",
		mods = leader,
		action = act.QuickSelect,
	},
}

-- Bind moving to tab index by Alt+1 to 9
for i = 1, 9 do
	table.insert(keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end

return keys
