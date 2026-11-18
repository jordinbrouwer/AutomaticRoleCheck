SLASH_AUTOMATICROLECHECK1 = "/arc"
local L = AutomaticRoleCheck.Loc

local function GetOptions()
  return AutomaticRoleCheck_Options
end

local function PrintStatus()
  local options = GetOptions()
  if not options then
    AutomaticRoleCheck.PrintInfo(L("status_loading"))
    return
  end
  local status
  if options.Enabled then
    status = options.DisableOnce and L("status_enabled_disable_next") or L("status_enabled_remain")
  else
    status = options.EnableOnce and L("status_disabled_enable_next") or L("status_disabled_remain")
  end
  AutomaticRoleCheck.PrintInfo(status)
end

local function EnsureOptionsLoaded()
  if GetOptions() then return true end
  AutomaticRoleCheck.PrintError(L("options_not_loaded"))
  return false
end

local commandDefinitions

local function HandleHelp()
  local orderedKeys = { "status", "enable", "disable", "minimap", "options" }
  AutomaticRoleCheck.PrintInfo(L("cmd_list_header"))
  print("  |CFF0077FF/arc|r: " .. L("cmd_help_root"))
  for _, key in ipairs(orderedKeys) do
    local definition = commandDefinitions[key]
    if definition then
      local label = definition.args ~= "" and ("/arc " .. key .. " " .. definition.args) or ("/arc " .. key)
      print("  |CFF0077FF" .. label .. "|r: " .. L(definition.helpKey))
    end
  end
end

commandDefinitions = {
  status = {
    args = "",
    helpKey = "cmd_help_status",
    requiresOptions = true,
    handler = PrintStatus,
  },
  options = {
    args = "",
    helpKey = "cmd_help_options",
    requiresOptions = true,
    handler = function()
      AutomaticRoleCheck.OpenOptions()
    end,
  },
  enable = {
    args = "[once]",
    helpKey = "cmd_help_enable",
    requiresOptions = true,
    handler = function(arg)
      if arg == "" then
        AutomaticRoleCheck.SetEnabled(true)
        AutomaticRoleCheck.PrintInfo(L("cmd_enabled_addon"))
        return
      end
      if arg == "once" then
        AutomaticRoleCheck.SetEnableOnce(true)
        AutomaticRoleCheck.PrintInfo(L("cmd_enabled_once"))
        return
      end
      AutomaticRoleCheck.PrintError(L("cmd_invalid_enable"))
    end,
  },
  disable = {
    args = "[once]",
    helpKey = "cmd_help_disable",
    requiresOptions = true,
    handler = function(arg)
      if arg == "" then
        AutomaticRoleCheck.SetEnabled(false)
        AutomaticRoleCheck.PrintInfo(L("cmd_disabled_addon"))
        return
      end
      if arg == "once" then
        AutomaticRoleCheck.SetDisableOnce(true)
        AutomaticRoleCheck.PrintInfo(L("cmd_disabled_once"))
        return
      end
      AutomaticRoleCheck.PrintError(L("cmd_invalid_disable"))
    end,
  },
  minimap = {
    args = "[show/hide/toggle]",
    helpKey = "cmd_help_minimap",
    requiresOptions = true,
    handler = function(arg)
      local options = GetOptions()
      local mode = arg == "" and "toggle" or arg
      if mode == "show" then
        AutomaticRoleCheck.SetShowMinimapButton(true)
      elseif mode == "hide" then
        AutomaticRoleCheck.SetShowMinimapButton(false)
      elseif mode == "toggle" then
        AutomaticRoleCheck.SetShowMinimapButton(not options.ShowMinimapButton)
      else
        AutomaticRoleCheck.PrintError(L("cmd_invalid_minimap"))
        return
      end
      AutomaticRoleCheck.PrintInfo(
        options.ShowMinimapButton and L("cmd_minimap_shown") or L("cmd_minimap_hidden")
      )
    end,
  },
}

SlashCmdList.AUTOMATICROLECHECK = function(cmd)
  cmd = strlower(strtrim(cmd or ""))
  local action, arg = cmd:match("^(%S+)%s*(.-)%s*$")
  action = action or ""
  arg = arg or ""

  if action == "" then
    HandleHelp()
    return
  end

  local definition = commandDefinitions[action]
  if definition then
    if definition.requiresOptions and not EnsureOptionsLoaded() then
      return
    end
    definition.handler(arg)
  else
    AutomaticRoleCheck.PrintError(L("cmd_invalid"))
    HandleHelp()
  end
end