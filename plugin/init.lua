local wezterm = require("wezterm")
--NOTE: mandatory read :
-- https://wezfurlong.org/wezterm/shell-integration.html
--NOTE: related methods :
-- get_semantic_zone_at    https://wezfurlong.org/wezterm/config/lua/pane/get_semantic_zone_at.html
-- get_text_from_semantic_zone https://wezfurlong.org/wezterm/config/lua/pane/get_text_from_semantic_zone.html
-- get_semantic_zones    https://wezfurlong.org/wezterm/config/lua/pane/get_semantic_zones.html
-- ScrollToPrompt https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html?h=semantic
--
local wezterm = require("wezterm")
local M = {}

-- Plugin configuration
M.config = {
	debug = false,
	namespace = "plugins.semantic_zones",
}

-- Initialize the plugin state
local function init_plugin_state()
	wezterm.GLOBAL.plugins = wezterm.GLOBAL.plugins or {}

	local plugin_state = wezterm.GLOBAL.plugins[M.config.namespace] or {
		initialized = false,
	}

	wezterm.GLOBAL.plugins[M.config.namespace] = plugin_state
	return plugin_state
end

-- Helper function for logging
local function log(message, force)
	if M.config.debug or force then
		wezterm.log_info(string.format("[%s] %s", M.config.namespace, message))
	end
end

-- Enable/disable debug logging
function M.set_debug(enabled)
	M.config.debug = enabled
	log(string.format("Debug logging %s", enabled and "enabled" or "disabled"), true)
end

-- Parse semantic zones from a pane
function M.parse_semantic_zones(pane)
	local zones = pane:get_semantic_zones()
	local parsed_zones = {}

	for id, zone in ipairs(zones) do
		local text = pane:get_text_from_semantic_zone(zone)
		table.insert(parsed_zones, {
			id = id,
			start_x = zone.start_x,
			start_y = zone.start_y,
			end_x = zone.end_x,
			end_y = zone.end_y,
			semantic_type = zone.semantic_type,
			text = text,
		})
	end

	return parsed_zones
end

-- Get the last command output
function M.get_last_command_output(pane)
	local zones = M.parse_semantic_zones(pane)
	for i = #zones, 1, -1 do
		local zone = zones[i]
		if zone.semantic_type == "Output" then
			log(string.format("Last Command Output: %s", zone.text))
			return zone.text
		end
	end
	log("No Command Output Found")
	return nil
end

-- Select the previous or next output zone
function M.select_output_zone(window, pane, direction)
	log(string.format("Selecting %s output zone", direction))

	-- Execute actions
	window:perform_action(wezterm.action.ActivateCopyMode, pane)
	window:perform_action(wezterm.action.CopyMode("ClearSelectionMode"), pane)

	local move_action
	if direction == "previous" then
		move_action = wezterm.action.CopyMode({ MoveBackwardZoneOfType = "Output" })
	elseif direction == "next" then
		move_action = wezterm.action.CopyMode({ MoveForwardZoneOfType = "Output" })
	end

	window:perform_action(move_action, pane)
	window:perform_action(wezterm.action.CopyMode({ SetSelectionMode = "SemanticZone" }), pane)

	log("Zone selection completed")
end

-- Initialize the plugin
local function initialize()
	local state = init_plugin_state()

	if not state.initialized then
		state.initialized = true
		log("Plugin initialized", true)
	end
end

-- Setup the plugin when the module is loaded
initialize()

return M
