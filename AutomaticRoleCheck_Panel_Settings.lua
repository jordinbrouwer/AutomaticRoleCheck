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

AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton = CreateFrame("CheckButton", nil, AutomaticRoleCheck.Panel.Settings, "ChatConfigCheckButtonTemplate")
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton:SetPoint("TOPLEFT", 10, -75)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton.Text:SetFontObject("GameFontHighlightSmall")
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton.Text:SetPoint("LEFT", AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton, "RIGHT", 0, 1)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton.Text:SetText("Disable once on login")
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton.tooltip = "If the addon is disabled once on login."

AutomaticRoleCheck.Panel.Inner.EnabledButton:HookScript("OnClick", function()
  if AutomaticRoleCheck.Panel.Inner.EnabledButton:GetChecked() then
    AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:Enable()
    AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton:Enable()
  else
    AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:Disable()
    AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton:Disable()
  end
end)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:HookScript("OnClick", function()
  AutomaticRoleCheck.Options.DisableOnce = AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:GetChecked()
end)
AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton:HookScript("OnClick", function()
  AutomaticRoleCheck.Options.DisableOnceOnLogin = AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton:GetChecked()
end)

function AutomaticRoleCheck.Panel.Settings.PopulatePanel()
  AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceButton:SetChecked(AutomaticRoleCheck.Options.DisableOnce)
  AutomaticRoleCheck.Panel.Settings.Inner.DisableOnceOnLoginButton:SetChecked(AutomaticRoleCheck.Options.DisableOnceOnLogin)
end

AutomaticRoleCheck.Panel.Settings:HookScript("OnShow", AutomaticRoleCheck.Panel.Settings.PopulatePanel)
AutomaticRoleCheck.Panel.Settings:HookScript("OnEvent", AutomaticRoleCheck.EventHandler)

InterfaceOptions_AddCategory(AutomaticRoleCheck.Panel.Settings);
