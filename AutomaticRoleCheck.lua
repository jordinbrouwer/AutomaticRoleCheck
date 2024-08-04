AutomaticRoleCheck = {
    FirstCheck = true,
    Defaults = {
      Enabled = true,
      DisableOnce = false,
      DisableOnceOnLogin = false,
    }
}

if not AutomaticRoleCheck_Options then
  AutomaticRoleCheck_Options = AutomaticRoleCheck.Defaults
end

AutomaticRoleCheck.Accept = function(self)
  if not (AutomaticRoleCheck_Options.DisableOnce or (AutomaticRoleCheck.FirstCheck and AutomaticRoleCheck_Options.DisableOnceOnLogin)) then
    self:Click()
  end
  AutomaticRoleCheck.FirstCheck = false
  AutomaticRoleCheck_Options.DisableOnce = false
end

LFGListApplicationDialog.SignUpButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
LFGInvitePopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
LFDRoleCheckPopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)