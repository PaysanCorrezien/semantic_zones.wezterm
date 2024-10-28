# 🔌 WezTerm Semantic Zones Plugin (Experimental)

An experimental plugin for WezTerm that provides enhanced semantic zone navigation and manipulation capabilities. This plugin serves as a testing ground for WezTerm's semantic features and shell integration.

## 📖 Overview

This plugin extends WezTerm's functionality by providing utilities to work with semantic zones, including command outputs, zone navigation, and text extraction. It's designed to demonstrate and test WezTerm's semantic features capabilities.

## ⭐ Features

- 🔍 Parse and analyze semantic zones in terminal panes
- 📜 Extract last command output
- ⚡ Navigate between output zones (previous/next)
- 🐛 Configurable debug logging
- 🎯 Copy mode integration for zone selection

## 🚀 Installation

Add the plugin to your WezTerm configuration:

```lua
local wez = require('wezterm')
local semantic_zones = wez.plugin.require("https://github.com/PaysanCorrezien/semantic_zones.wezterm")
```

## 💡 Usage

### Keybinding Configuration

Add these to your WezTerm key_maps configuration:

```lua
local config = {
  keys = {
    -- Copy last command output to clipboard
    {
      key = "o",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        local output = semantic_zones.get_last_command_output(pane)
        if output then
          window:copy_to_clipboard(output)
          window:toast_notification("WezTerm", "Last command output copied to clipboard", nil, 2000)
        else
          window:toast_notification("WezTerm", "No command output found", nil, 4000)
        end
      end),
    },
    -- Navigate to previous output zone
    {
      key = ",",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        return semantic_zones.select_output_zone(window, pane, "previous")
      end),
    },
    -- Navigate to next output zone
    {
      key = ".",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        return semantic_zones.select_output_zone(window, pane, "next")
      end),
    },
  }
}
```

### Enjoy the new keybindings :

`CTRL: + SHIFT + o` to yank the last command output to the clipboard
`CTRL + ,` to navigate to the previous output zone
`CTRL + .` to navigate to the next output zone

## 📚 Important Documentation

Before using this plugin, it's essential to understand WezTerm's shell integration and semantic features:

- [Shell Integration Documentation](https://wezfurlong.org/wezterm/shell-integration.html)
- [get_semantic_zone_at](https://wezfurlong.org/wezterm/config/lua/pane/get_semantic_zone_at.html)
- [get_text_from_semantic_zone](https://wezfurlong.org/wezterm/config/lua/pane/get_text_from_semantic_zone.html)
- [get_semantic_zones](https://wezfurlong.org/wezterm/config/lua/pane/get_semantic_zones.html)
- [ScrollToPrompt](https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html?h=semantic)

## ⚠️ Experimental Status

This plugin is experimental and meant for testing WezTerm's semantic features. It may not be suitable for production use and could change significantly as WezTerm evolves.

## 🤝 Contributing

Contributions are welcome! Please note:

- This project is maintained as time permits
- Focus on meaningful improvements that don't add unnecessary complexity

## 📄 License

This project follows the MIT License conventions. Feel free to use, modify, and distribute as per MIT License terms.
