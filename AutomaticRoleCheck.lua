AutomaticRoleCheck = {}
AutomaticRoleCheck.__index = AutomaticRoleCheck

AutomaticRoleCheck.Defaults = {
  Enabled = true,
  DisableOnce = false,
  DisableOnceOnLogin = false,
}
AutomaticRoleCheck.Accept = function(self)
  if AutomaticRoleCheck.Options.Enabled then
    if not AutomaticRoleCheck.Options.DisableOnce then
      self:Click()
    end
  end
  AutomaticRoleCheck.Options.DisableOnce = false
end
AutomaticRoleCheck.EventHandler = function(self, event, arg, ...)
  if event == "ADDON_LOADED" and arg == "AutomaticRoleCheck" then
    AutomaticRoleCheck.Options = AutomaticRoleCheck.Defaults
    if AutomaticRoleCheck_Options then
      for k, v in pairs(AutomaticRoleCheck_Options) do
        AutomaticRoleCheck.Options[k] = v
      end
      AutomaticRoleCheck.Options.DisableOnce = AutomaticRoleCheck.Options.DisableOnce and -- ?
                                              AutomaticRoleCheck.Options.DisableOnce or -- then
                                              AutomaticRoleCheck.Options.DisableOnceOnLogin -- else
    end
  elseif event == "PLAYER_LOGOUT" then
    AutomaticRoleCheck_Options = AutomaticRoleCheck.Options
  end
end

LFGListApplicationDialog.SignUpButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
LFGInvitePopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
LFDRoleCheckPopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)