AutomaticRoleCheck = {}
AutomaticRoleCheck.__index = AutomaticRoleCheck

AutomaticRoleCheck.Accept = function(self)
    self:Click();
end

function AutomaticRoleCheck:New()
    LFGInvitePopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
    LFGListInviteDialog.AcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
    LFDRoleCheckPopupAcceptButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
    LFGListApplicationDialog.SignUpButton:HookScript("OnShow", AutomaticRoleCheck.Accept)
end

AutomaticRoleCheck:New()
