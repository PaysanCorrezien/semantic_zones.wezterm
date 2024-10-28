local wezterm = require "wezterm"
--NOTE: mandatory read :
-- https://wezfurlong.org/wezterm/shell-integration.html
--NOTE: related methods :
-- get_semantic_zone_at    https://wezfurlong.org/wezterm/config/lua/pane/get_semantic_zone_at.html
-- get_text_from_semantic_zone https://wezfurlong.org/wezterm/config/lua/pane/get_text_from_semantic_zone.html
-- get_semantic_zones    https://wezfurlong.org/wezterm/config/lua/pane/get_semantic_zones.html
-- ScrollToPrompt https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html?h=semantic
--
local M = {}

--- Parse semantic zones from a pane and return JSON string
--- @param pane Pane
---  The pane to parse semantic zones from
--- @return string
---  A JSON string representing the parsed semantic zones
function M.parse_semantic_zones(window, pane)
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
  local parsed_json = wezterm.json_encode(parsed_zones)
  wezterm.log_info("Parsed Semantic Zones: " .. parsed_json)
  return parsed_json
end

--TODO: save in memory via wezterm.global in .plugins.magik_history.data
-- save more infos in this like the pane window pane id ect maybe so we can do more magic ??
--
--- Save JSON data to a file
--- @param data string
---  The JSON string to save
--- @param filename string
---  The file path to save the JSON data to
function M.save_json_to_file(data, filename)
  local file = io.open(wezterm.home_dir .. filename, "w")
  if file then
    file:write(data)
    file:close()
    wezterm.log_info("JSON data saved to " .. filename)
  else
    wezterm.log_error("Failed to open file " .. filename .. " for writing")
  end
end

--- Load JSON data from a file
--- @param filename string
---  The file path to load the JSON data from
--- @return table
---  The decoded JSON data as a Lua table, or nil if loading failed
function M.load_json_from_file(filename)
  local file = io.open(wezterm.home_dir .. filename, "r")
  if file then
    local data = file:read "*a"
    file:close()
    local parsed_data = wezterm.json_decode(data)
    wezterm.log_info("JSON data loaded from " .. filename)
    return parsed_data
  else
    wezterm.log_error("Failed to open file " .. filename .. " for reading")
    --NOTE: Returning an empty table instead of nil to avoid nil checks
    return {}
  end
end

--- Get the last semantic zone
--- @param zones table
---  The table of semantic zones
--- @return table
---  The last semantic zone object
function M.get_last_semantic_zone(zones)
  local last_zone = zones[#zones]
  wezterm.log_info("Last Semantic Zone: " .. wezterm.json_encode(last_zone))
  return last_zone
end

--- Get the position of a semantic zone by its ID
--- @param zones table
---  The table of semantic zones
--- @param id number
---  The ID of the semantic zone to find
--- @return table
---  A table containing start_x, start_y, end_x, end_y, or nil if not found
function M.get_semantic_zone_position(zones, id)
  for _, zone in ipairs(zones) do
    if zone.id == id then
      return {
        start_x = zone.start_x,
        start_y = zone.start_y,
        end_x = zone.end_x,
        end_y = zone.end_y,
      }
    end
  end
  wezterm.log_info("No zone found with ID: " .. id)
  return nil
end

--- Get all zones of a specific semantic type
--- @param zones table
---  The table of semantic zones
--- @param semantic_type string
---  The semantic type to filter by (e.g., "Command", "Output", "Prompt")
--- @return table
---  A table containing all zones of the specified type
function M.get_zones_by_type(zones, semantic_type)
  local filtered_zones = {}
  for _, zone in ipairs(zones) do
    if zone.semantic_type == semantic_type then
      table.insert(filtered_zones, zone)
    end
  end
  return filtered_zones
end

--- Get the most recent zone of a specific semantic type
--- @param zones table
---  The table of semantic zones
--- @param semantic_type string
---  The semantic type to search for
--- @return table
---  The most recent zone of the specified type, or nil if not found
function M.get_most_recent_zone_by_type(zones, semantic_type)
  for i = #zones, 1, -1 do
    if zones[i].semantic_type == semantic_type then
      return zones[i]
    end
  end
  return nil
end

--- Count the number of zones of each semantic type
--- @param zones table
---  The table of semantic zones
--- @return table
---  A table with counts for each semantic type
function M.count_zones_by_type(zones)
  local counts = {}
  for _, zone in ipairs(zones) do
    counts[zone.semantic_type] = (counts[zone.semantic_type] or 0) + 1
  end
  return counts
end

--- Get the text content between two zone IDs
--- @param zones table
---  The table of semantic zones
--- @param start_id number
---  The ID of the starting zone
--- @param end_id number
---  The ID of the ending zone
--- @return string
---  The concatenated text content between the two zones, or nil if invalid IDs
function M.get_text_between_zones(zones, start_id, end_id)
  local start_index, end_index
  for i, zone in ipairs(zones) do
    if zone.id == start_id then
      start_index = i
    elseif zone.id == end_id then
      end_index = i
    end
  end

  if start_index and end_index and start_index <= end_index then
    local text = ""
    for i = start_index, end_index do
      text = text .. zones[i].text
    end
    return text
  end

  wezterm.log_info "Invalid zone IDs or range"
  return nil
end

--- Parse semantic zones from a pane and return JSON string
--- @param pane Pane
---  The pane to parse semantic zones from
--- @return table
---  A table representing the parsed semantic zones
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

--- Get the current command
--- @param pane Pane
---  The pane to get the current command from
--- @return string
---  The text of the current command, or nil if not found
function M.get_current_command(pane)
  local zones = M.parse_semantic_zones(pane)
  for i = #zones, 1, -1 do
    local zone = zones[i]
    if zone.semantic_type == "Command" then
      wezterm.log_info("Current Command: " .. zone.text)
      return zone.text
    end
  end
  wezterm.log_info "No Current Command Found"
  return nil
end

--- Get the last command output
--- @param pane Pane
---  The pane to get the last command output from
--- @return string
---  The text of the last command output, or nil if not found
function M.get_last_command_output(pane)
  local zones = M.parse_semantic_zones(pane)
  for i = #zones, 1, -1 do
    local zone = zones[i]
    if zone.semantic_type == "Output" then
      wezterm.log_info("Last Command Output: " .. zone.text)
      return zone.text
    end
  end
  wezterm.log_info "No Command Output Found"
  return nil
end

--- Get the current command and its position
--- @param pane Pane
---  The pane to get the current command from
--- @return table
---  A table containing the command text and its position, or nil if not found
function M.get_current_command_with_position(pane)
  local zones = M.parse_semantic_zones(pane)
  for i = #zones, 1, -1 do
    local zone = zones[i]
    if zone.semantic_type == "Command" then
      wezterm.log_info("Current Command: " .. zone.text)
      return {
        text = zone.text,
        start_x = zone.start_x,
        start_y = zone.start_y,
        end_x = zone.end_x,
        end_y = zone.end_y,
      }
    end
  end
  wezterm.log_info "No Current Command Found"
  return nil
end

--- Select the previous or next output zone
--- @param pane Pane
---  The pane to operate on
--- @param direction string
---  The direction to move ("previous" or "next")
function M.select_output_zone(window, pane, direction)
  -- Execute actions
  window:perform_action(wezterm.action.ActivateCopyMode, pane)
  window:perform_action(wezterm.action.CopyMode "ClearSelectionMode", pane)

  local move_action
  if direction == "previous" then
    move_action = wezterm.action.CopyMode { MoveBackwardZoneOfType = "Output" }
  elseif direction == "next" then
    move_action = wezterm.action.CopyMode { MoveForwardZoneOfType = "Output" }
  end

  window:perform_action(move_action, pane)

  --FIXME: this is not skipping output with empty text
  -- Check if the current output zone is empty and move again if necessary
  -- local cursor_pos = pane:get_cursor_position()
  -- local selected_zone = pane:get_semantic_zone_at(cursor_pos.x, cursor_pos.y)
  -- if selected_zone then
  --   local start_y = selected_zone.start_y
  --   local end_y = selected_zone.end_y
  --   local zone_text = pane:get_lines_as_text(start_y, end_y - start_y + 1)
  --   zone_text = zone_text:gsub("^%s*(.-)%s*$", "%1") -- Trim leading/trailing whitespace
  --   wezterm.log_info("Selected output zone text: " .. zone_text)
  --   if #zone_text == 0 then
  --     wezterm.log_info "Current output zone is empty, moving again"
  --     window:perform_action(move_action, pane)
  --   end
  -- end

  window:perform_action(
    wezterm.action.CopyMode { SetSelectionMode = "SemanticZone" },
    pane
  )

  wezterm.log_info "Actions executed"
end

return M
