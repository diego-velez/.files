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

return config
