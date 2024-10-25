AutomaticRoleCheck.Panel = Settings.RegisterVerticalLayoutCategory("AutomaticRoleCheck")

local function RegisterCheckbox(configKey, name, tooltip)
  local defaultValue = AutomaticRoleCheck.Defaults[configKey]
  local function GetValue()
    return AutomaticRoleCheck_Options[configKey]
  end
  local function SetValue(value)
    AutomaticRoleCheck_Options[configKey] = value
  end
  local setting = Settings.RegisterProxySetting(AutomaticRoleCheck.Panel, "AutomaticRoleCheck_Options." .. configKey, type(defaultValue), name, defaultValue, GetValue, SetValue)
  Settings.CreateCheckbox(AutomaticRoleCheck.Panel, setting, tooltip)
end

RegisterCheckbox("Enabled", "Enabled", "Reflects if the addon is enabled. Can also be modified with a command.")
RegisterCheckbox("DisableWhilstAFK", "Disable whilst AFK", "Indicates whether the addon should be disabled while you are AFK.")
RegisterCheckbox("DisableOnce", "Disable once", "Indicates if the addon is disabled for the upcoming role check. Can also be modified with a command.")
RegisterCheckbox("DisableOnceOnLogin", "Disable once on each login", "Indicates if the addon is disabled for the first role check upon each login.")
RegisterCheckbox("DisableOnceOnRoleChange", "Disable once after role change", "Indicates if the addon is disabled for the first role check upon changing role.")

Settings.RegisterAddOnCategory(AutomaticRoleCheck.Panel)