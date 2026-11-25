local ARC = AutomaticRoleCheck
SLASH_AUTOMATICROLECHECK1 = "/arc"
local L = ARC.Loc

local GetOptions = ARC.GetOptions

local function PrintStatus()
  local options = GetOptions()
  if not options then
    ARC.PrintInfo(L("status_loading"))
    return
  end
  local status
  if options.Enabled then
    status = options.DisableOnce and L("status_enabled_disable_next") or L("status_enabled_remain")
  else
    status = options.EnableOnce and L("status_disabled_enable_next") or L("status_disabled_remain")
  end
  ARC.PrintInfo(status)
end

local function EnsureOptionsLoaded()
  if GetOptions() then return true end
  ARC.PrintError(L("options_not_loaded"))
  return false
end

-- The list of commands: one toast with a key for each command; it stays until you click it.
local HELP_CELLS = {
  { key = "/arc", text = "cmd_card_root" },
  { key = "/arc status", text = "cmd_card_status" },
  { key = "/arc enable", extras = { "once" }, text = "cmd_card_enable" },
  { key = "/arc disable", extras = { "once" }, text = "cmd_card_disable" },
  { key = "/arc minimap", extras = { "show", "hide", "toggle" }, text = "cmd_card_minimap", wide = true },
}

local function HandleHelp()
  local cells = {}
  for i, def in ipairs(HELP_CELLS) do
    cells[i] = { key = def.key, extras = def.extras, text = L(def.text), wide = def.wide }
  end
  ARC.ShowToast("", "info", { title = L("cmd_title"), sticky = true, width = 350, cells = cells })
end
local commandDefinitions = {
  status = {
    requiresOptions = true,
    handler = PrintStatus,
  },
  help = {
    requiresOptions = false,
    handler = function() HandleHelp() end,
  },
  enable = {
    requiresOptions = true,
    handler = function(arg)
      if arg == "" then
        ARC.SetEnabled(true)
        ARC.PrintInfo(L("cmd_enabled_addon"))
        return
      end
      if arg == "once" then
        ARC.SetEnableOnce(true)
        ARC.PrintInfo(L("cmd_enabled_once"))
        return
      end
      ARC.PrintError(L("cmd_invalid_enable"))
    end,
  },
  disable = {
    requiresOptions = true,
    handler = function(arg)
      if arg == "" then
        ARC.SetEnabled(false)
        ARC.PrintInfo(L("cmd_disabled_addon"))
        return
      end
      if arg == "once" then
        ARC.SetDisableOnce(true)
        ARC.PrintInfo(L("cmd_disabled_once"))
        return
      end
      ARC.PrintError(L("cmd_invalid_disable"))
    end,
  },
  minimap = {
    requiresOptions = true,
    handler = function(arg)
      local options = GetOptions()
      local mode = arg == "" and "toggle" or arg
      if mode == "show" then
        ARC.SetShowMinimapButton(true)
      elseif mode == "hide" then
        ARC.SetShowMinimapButton(false)
      elseif mode == "toggle" then
        ARC.SetShowMinimapButton(not options.ShowMinimapButton)
      else
        ARC.PrintError(L("cmd_invalid_minimap"))
        return
      end
      ARC.PrintInfo(
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

  -- /arc alone opens the options; /arc help lists the commands.
  if action == "" then
    if EnsureOptionsLoaded() then ARC.OpenOptions() end
    return
  end
  if action == "help" then
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
    ARC.PrintError(L("cmd_invalid"))
    HandleHelp()
  end
end