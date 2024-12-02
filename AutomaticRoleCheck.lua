AutomaticRoleCheck = {
  AddonName = ...,
  Defaults = {
    Enabled = true,
    DisableWhilstAFK = false,
    DisableOnce = false,
    DisableOnceOnLogin = false,
    DisableOnceOnRoleChange = false,
  }
}

AutomaticRoleCheck.GetRoleName = function()
  local spec = GetSpecialization()
  if spec == nil then return end
  return (select(5, GetSpecializationInfo(spec)))
end

AutomaticRoleCheck.Accept = function(self)
  if not AutomaticRoleCheck_Options.Enabled then return end
  if AutomaticRoleCheck_Options.DisableWhilstAFK and UnitIsAFK("player") then return end
  if AutomaticRoleCheck_Options.DisableOnce then
    AutomaticRoleCheck_Options.DisableOnce = false
    return
  end
  self:Click()
end

local f = CreateFrame("frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:SetScript("OnEvent", function(_, event, arg1, arg2)
  if event == "ADDON_LOADED" then
    if arg1 ~= AutomaticRoleCheck.AddonName then return end

    if not AutomaticRoleCheck_Options then
      AutomaticRoleCheck_Options = AutomaticRoleCheck.Defaults
    end

    if not AutomaticRoleCheck_Options.LastRole then
      AutomaticRoleCheck_Options.LastRole = AutomaticRoleCheck.GetRoleName()
    end

    if AutomaticRoleCheck_Options.DisableOnceOnLogin then
      AutomaticRoleCheck_Options.DisableOnce = true
    end
  elseif event == "PLAYER_ENTERING_WORLD" and (arg1 or arg2) then
    if not AutomaticRoleCheck_Options.LastRole then
      AutomaticRoleCheck_Options.LastRole = AutomaticRoleCheck.GetRoleName()
    end

    LFGListApplicationDialog.SignUpButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
    LFGInvitePopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
    LFDRoleCheckPopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
  elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
    if arg1 ~= "player" then return end
    if not AutomaticRoleCheck_Options.DisableOnceOnRoleChange then return end

    local roleName = AutomaticRoleCheck.GetRoleName()
    if roleName == AutomaticRoleCheck_Options.LastRole then return end

    AutomaticRoleCheck_Options.DisableOnce = true
    AutomaticRoleCheck_Options.LastRole = roleName
  end
end)