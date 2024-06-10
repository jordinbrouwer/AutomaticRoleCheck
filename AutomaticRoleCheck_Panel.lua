AutomaticRoleCheck.Panel = CreateFrame("Frame", nil, UIParent)
AutomaticRoleCheck.Panel:RegisterEvent("ADDON_LOADED")
AutomaticRoleCheck.Panel:RegisterEvent("PLAYER_LOGOUT")
AutomaticRoleCheck.Panel.name = "AutomaticRoleCheck"

AutomaticRoleCheck.Panel.General = CreateFrame("Frame", nil, AutomaticRoleCheck.Panel)

AutomaticRoleCheck.Panel.General.Inner = AutomaticRoleCheck.Panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
AutomaticRoleCheck.Panel.General.Inner:SetPoint("TOPLEFT", 10, -15)
AutomaticRoleCheck.Panel.General.Inner:SetJustifyH("LEFT")
AutomaticRoleCheck.Panel.General.Inner:SetJustifyV("TOP")
AutomaticRoleCheck.Panel.General.Inner:SetText("AutomaticRoleCheck")

AutomaticRoleCheck.Panel.General.Inner.EnabledButton = CreateFrame("CheckButton", nil, AutomaticRoleCheck.Panel, "ChatConfigCheckButtonTemplate")
AutomaticRoleCheck.Panel.General.Inner.EnabledButton:SetPoint("TOPLEFT", 10, -45)
AutomaticRoleCheck.Panel.General.Inner.EnabledButton.Text:SetFontObject("GameFontHighlightSmall")
AutomaticRoleCheck.Panel.General.Inner.EnabledButton.Text:SetPoint("LEFT", AutomaticRoleCheck.Panel.General.Inner.EnabledButton, "RIGHT", 0, 1)
AutomaticRoleCheck.Panel.General.Inner.EnabledButton.Text:SetText("Enable AutomaticRoleCheck")
AutomaticRoleCheck.Panel.General.Inner.EnabledButton.tooltip = "If the AutomaticRoleCheck addon is enabled."

AutomaticRoleCheck.Panel.General.Inner.EnabledButton:HookScript("OnClick", function()
  AutomaticRoleCheck.Options.Enabled = AutomaticRoleCheck.Panel.General.Inner.EnabledButton:GetChecked()
end)

function AutomaticRoleCheck.Panel.PopulatePanel()
  AutomaticRoleCheck.Panel.General.Inner.EnabledButton:SetChecked(AutomaticRoleCheck.Options.Enabled)
end

AutomaticRoleCheck.Panel:HookScript("OnShow", AutomaticRoleCheck.Panel.PopulatePanel)
AutomaticRoleCheck.Panel:HookScript("OnEvent", AutomaticRoleCheck.EventHandler)

InterfaceOptions_AddCategory(AutomaticRoleCheck.Panel)