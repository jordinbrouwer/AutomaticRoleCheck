AutomaticRoleCheck.Panel.Settings = CreateFrame("Frame", nil, AutomaticRoleCheck.Panel);
AutomaticRoleCheck.Panel.Settings.name = "Settings";
AutomaticRoleCheck.Panel.Settings.parent = AutomaticRoleCheck.Panel.name;

AutomaticRoleCheck.Panel.Settings.Inner = AutomaticRoleCheck.Panel.Settings:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
AutomaticRoleCheck.Panel.Settings.Inner:SetPoint("TOPLEFT", 10, -15)
AutomaticRoleCheck.Panel.Settings.Inner:SetJustifyH("LEFT")
AutomaticRoleCheck.Panel.Settings.Inner:SetJustifyV("TOP")
AutomaticRoleCheck.Panel.Settings.Inner:SetText("AutomaticRoleCheck - Settings")

AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton = CreateFrame("CheckButton", nil, AutomaticRoleCheck.Panel.Settings, "ChatConfigCheckButtonTemplate")
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:SetPoint("TOPLEFT", 10, -45)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton.Text:SetFontObject("GameFontHighlightSmall")
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton.Text:SetPoint("LEFT", AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton, "RIGHT", 0, 1)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton.Text:SetText("Disable once")
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton.tooltip = "If the addon is disabled once for the upcoming role check."

AutomaticRoleCheck.Panel.Inner.EnabledButton:HookScript("OnClick", function()
  if AutomaticRoleCheck.Panel.Inner.EnabledButton:GetChecked() then
    AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:Enable()
  else
    AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:Disable()
  end
end)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:HookScript("OnClick", function()
  AutomaticRoleCheck.Options.DisableOnce = AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:GetChecked()
end)
AutomaticRoleCheck.Panel.Settings:HookScript("OnShow", function()
  AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:SetChecked(AutomaticRoleCheck.Options.DisableOnce)
end)
AutomaticRoleCheck.Panel.Settings:HookScript("OnEvent", AutomaticRoleCheck.EventHandler)

InterfaceOptions_AddCategory(AutomaticRoleCheck.Panel.Settings);