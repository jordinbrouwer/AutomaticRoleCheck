AutomaticRoleCheck = {
    FirstCheck = true,
    Defaults = {
      Enabled = true,
      DisableWhilstAFK = false,
      DisableOnce = false,
      DisableOnceOnLogin = false,
    }
}

if not AutomaticRoleCheck_Options then
  AutomaticRoleCheck_Options = AutomaticRoleCheck.Defaults
end

AutomaticRoleCheck.Accept = function(self)
  if AutomaticRoleCheck_Options.Enabled and not (AutomaticRoleCheck_Options.DisableWhilstAFK and UnitIsAFK("player")) then
    if not (AutomaticRoleCheck_Options.DisableOnce or (AutomaticRoleCheck.FirstCheck and AutomaticRoleCheck_Options.DisableOnceOnLogin)) then
      self:Click()
    end
    if AutomaticRoleCheck.FirstCheck then
      AutomaticRoleCheck.FirstCheck = false
    end
    if AutomaticRoleCheck_Options.DisableOnce then
      AutomaticRoleCheck_Options.DisableOnce = false
    end
  end
end

LFGListApplicationDialog.SignUpButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
LFGInvitePopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
LFDRoleCheckPopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)