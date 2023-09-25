-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.font = wezterm.font 'Terminus'
config.color_scheme = 'Tango (base16)'
config.colors = {
  -- The default text color
  foreground = 'white',
  -- The default background color
  background = 'black',
}

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}


config.enable_kitty_keyboard = true

local act = wezterm.action

config.keys = {
  { key = 'Z', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'X', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(1) },
}


-- and finally, return the configuration to wezterm
return config

