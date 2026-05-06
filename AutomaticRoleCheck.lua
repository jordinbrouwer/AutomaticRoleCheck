AutomaticRoleCheck = AutomaticRoleCheck or {}
AutomaticRoleCheck.AddonName = ...
local L = AutomaticRoleCheck.Loc
AutomaticRoleCheck.MessagePrefix = "|CFF0077FFAutomaticRoleCheck|r: "
AutomaticRoleCheck.Defaults = {
  Enabled = true,
  ShowMinimapButton = true,
  DisableWhilstAFK = false,
  DisableOnce = false,
  EnableOnce = false,
  DisableOnceOnLogin = false,
  DisableOnceOnRoleChange = false,
  MinimapButtonAngle = 225,
}

AutomaticRoleCheck.Print = function(message)
  print(AutomaticRoleCheck.MessagePrefix .. message)
end

AutomaticRoleCheck.PrintInfo = AutomaticRoleCheck.Print

AutomaticRoleCheck.PrintError = function(message)
  AutomaticRoleCheck.Print(L("error_prefix") .. message)
end

AutomaticRoleCheck.RefreshMinimapState = function()
  if AutomaticRoleCheck.Minimap_OnOptionsChanged then
    AutomaticRoleCheck.Minimap_OnOptionsChanged()
  end
end

local function GetOptions()
  return AutomaticRoleCheck_Options
end

local function NotifyPanelOptionsChanged(changedKey)
  if AutomaticRoleCheck.Panel_OnOptionsChanged then
    AutomaticRoleCheck.Panel_OnOptionsChanged(changedKey)
  end
end

AutomaticRoleCheck.SetOption = function(key, value, refreshMinimap)
  local options = GetOptions()
  if not options then return false end
  if options[key] == value then return false end
  options[key] = value
  NotifyPanelOptionsChanged(key)
  if refreshMinimap then
    AutomaticRoleCheck.RefreshMinimapState()
  end
  return true
end

AutomaticRoleCheck.GetAddonVersion = function()
  local unknown = L("meta_version_unknown")
  if C_AddOns and C_AddOns.GetAddOnMetadata then
    return C_AddOns.GetAddOnMetadata(AutomaticRoleCheck.AddonName, "Version") or unknown
  end
  if GetAddOnMetadata then
    return GetAddOnMetadata(AutomaticRoleCheck.AddonName, "Version") or unknown
  end
  return unknown
end

AutomaticRoleCheck.OpenOptions = function()
  if not AutomaticRoleCheck.Panel then return end
  local panelId = AutomaticRoleCheck.Panel:GetID()
  if Settings and Settings.OpenToCategory then
    Settings.OpenToCategory(panelId)
    return
  end
  if InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(AutomaticRoleCheck.Panel.name or L("settings_category"))
  end
end

AutomaticRoleCheck.SetEnabled = function(enabled)
  AutomaticRoleCheck.SetOption("Enabled", enabled, true)
end

AutomaticRoleCheck.SetDisableOnce = function(value)
  return AutomaticRoleCheck.SetOption("DisableOnce", value, false)
end

AutomaticRoleCheck.SetEnableOnce = function(value)
  return AutomaticRoleCheck.SetOption("EnableOnce", value, false)
end

AutomaticRoleCheck.SetShowMinimapButton = function(value)
  return AutomaticRoleCheck.SetOption("ShowMinimapButton", value, true)
end

AutomaticRoleCheck.GetRoleName = function()
  local spec = GetSpecialization()
  if spec == nil then return end
  return (select(5, GetSpecializationInfo(spec)))
end

AutomaticRoleCheck.Accept = function(self)
  local options = GetOptions()
  if not options then return end
  if options.Enabled and IsShiftKeyDown() then
    AutomaticRoleCheck.SetDisableOnce(true)
  end
  if not options.Enabled and not options.EnableOnce then return end
  if options.DisableWhilstAFK and UnitIsAFK("player") then return end
  if options.DisableOnce then
    AutomaticRoleCheck.SetDisableOnce(false)
    return
  end
  if options.EnableOnce then
    AutomaticRoleCheck.SetEnableOnce(false)
  end
  self:Click()
end

local eventFrame = CreateFrame("Frame")
local signUpHooked = false
local inviteHooked = false
local roleHooked = false

local function OnAddonLoaded(arg1)
  if arg1 ~= AutomaticRoleCheck.AddonName then return end
  local defaults = AutomaticRoleCheck.Defaults

  if not GetOptions() then
    AutomaticRoleCheck_Options = {}
  end

  local options = GetOptions()
  for key, value in pairs(defaults) do
    if options[key] == nil then
      options[key] = value
    end
  end

  if not options.LastRole then
    options.LastRole = AutomaticRoleCheck.GetRoleName()
  end

  if options.DisableOnceOnLogin then
    AutomaticRoleCheck.SetDisableOnce(true)
  end
end

local function OnPlayerEnteringWorld(arg1, arg2)
  if not (arg1 or arg2) then return end -- Wait for login or reload; first PEW can pass false for both flags.
  local options = GetOptions()
  if not options then return end
  if not options.LastRole then
    options.LastRole = AutomaticRoleCheck.GetRoleName()
  end

  if not signUpHooked then
    local appDialog = LFGListApplicationDialog
    local signUp = appDialog and appDialog.SignUpButton
    if signUp and signUp.HookScript then
      signUp:HookScript("OnShow", AutomaticRoleCheck.Accept)
      signUpHooked = true
    end
  end
  if not inviteHooked then
    local inviteAccept = LFGInvitePopupAcceptButton
    if inviteAccept and inviteAccept.HookScript then
      inviteAccept:HookScript("OnShow", AutomaticRoleCheck.Accept)
      inviteHooked = true
    end
  end
  if not roleHooked then
    local roleAccept = LFDRoleCheckPopupAcceptButton
    if roleAccept and roleAccept.HookScript then
      roleAccept:HookScript("OnShow", AutomaticRoleCheck.Accept)
      roleHooked = true
    end
  end
end

local function OnPlayerSpecializationChanged(arg1)
  if arg1 ~= "player" then return end
  local options = GetOptions()
  if not options then return end
  if not options.DisableOnceOnRoleChange then return end

  local roleName = AutomaticRoleCheck.GetRoleName()
  if roleName == options.LastRole then return end

  AutomaticRoleCheck.SetDisableOnce(true)
  options.LastRole = roleName
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
  if event == "ADDON_LOADED" then
    OnAddonLoaded(arg1)
  elseif event == "PLAYER_ENTERING_WORLD" then
    OnPlayerEnteringWorld(arg1, arg2)
  elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
    OnPlayerSpecializationChanged(arg1)
  end
end)