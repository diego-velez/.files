---@type Wezterm
local wezterm = require("wezterm")
---@type Config
local config = wezterm.config_builder()

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

config.enable_scroll_bar = true
config.window_padding = {
	left = "2px",
	right = "2px",
	top = "1px",
	bottom = "1px",
}

config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 10000
config.use_dead_keys = false

config.disable_default_key_bindings = true
config.keys = require("keymaps")

config.default_cursor_style = "SteadyBar"
config.quick_select_alphabet = "tnseriaohdlpufywqcxmgjbz"

-- Enabled zen.nvim integration with Wezterm
-- See https://github.com/folke/zen-mode.nvim?tab=readme-ov-file#wezterm
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
