AutomaticRoleCheck.Panel = CreateFrame("Frame", nil, UIParent)
AutomaticRoleCheck.Panel:RegisterEvent("ADDON_LOADED")
AutomaticRoleCheck.Panel:RegisterEvent("PLAYER_LOGOUT")
AutomaticRoleCheck.Panel.name = "AutomaticRoleCheck"

AutomaticRoleCheck.Panel.Inner = AutomaticRoleCheck.Panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
AutomaticRoleCheck.Panel.Inner:SetPoint("TOPLEFT", 10, -15)
AutomaticRoleCheck.Panel.Inner:SetJustifyH("LEFT")
AutomaticRoleCheck.Panel.Inner:SetJustifyV("TOP")
AutomaticRoleCheck.Panel.Inner:SetText("AutomaticRoleCheck")

AutomaticRoleCheck.Panel.Inner.EnabledButton = CreateFrame("CheckButton", nil, AutomaticRoleCheck.Panel, "ChatConfigCheckButtonTemplate")
AutomaticRoleCheck.Panel.Inner.EnabledButton:SetPoint("TOPLEFT", 10, -45)
AutomaticRoleCheck.Panel.Inner.EnabledButton.Text:SetFontObject("GameFontHighlightSmall")
AutomaticRoleCheck.Panel.Inner.EnabledButton.Text:SetPoint("LEFT", AutomaticRoleCheck.Panel.Inner.EnabledButton, "RIGHT", 0, 1)
AutomaticRoleCheck.Panel.Inner.EnabledButton.Text:SetText("Enable AutomaticRoleCheck")
AutomaticRoleCheck.Panel.Inner.EnabledButton.tooltip = "If the AutomaticRoleCheck addon is enabled."

AutomaticRoleCheck.Panel.Inner.EnabledButton:HookScript("OnClick", function()
  AutomaticRoleCheck.Options.Enabled = AutomaticRoleCheck.Panel.Inner.EnabledButton:GetChecked()
end)
AutomaticRoleCheck.Panel:HookScript("OnShow", function()
  AutomaticRoleCheck.Panel.Inner.EnabledButton:SetChecked(AutomaticRoleCheck.Options.Enabled)
end)
AutomaticRoleCheck.Panel:HookScript("OnEvent", AutomaticRoleCheck.EventHandler)

InterfaceOptions_AddCategory(AutomaticRoleCheck.Panel)