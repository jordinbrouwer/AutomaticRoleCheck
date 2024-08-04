SLASH_AUTOMATICROLECHECK1 = "/arc"

SlashCmdList.AUTOMATICROLECHECK = function (cmd)
  if cmd == "help" then
    print("|CFFFF0000AutomaticRoleCheck|r: List of available commands:")
    print("  |CFFFF0000/arc options|r: To open the addon options.")
    print("  |CFFFF0000/arc enable|r: To enable the addon.")
    print("  |CFFFF0000/arc disable|r: To disable the addon.")
    print("  |CFFFF0000/arc disableonce|r: To disable the addon once the next role check.")
  elseif cmd == "options" then
    Settings.OpenToCategory(AutomaticRoleCheck.Panel:GetID())
  elseif cmd == "enable" then
    AutomaticRoleCheck_Options.Enabled = true
    print("|CFFFF0000AutomaticRoleCheck|r: Enabled the addon.")
  elseif cmd == "disable" then
    AutomaticRoleCheck_Options.Enabled = false
    print("|CFFFF0000AutomaticRoleCheck|r: Disabled the addon.")
  elseif cmd == "disableonce" then
    AutomaticRoleCheck_Options.DisableOnce = true
    print("|CFFFF0000AutomaticRoleCheck|r: Disabled once for the next role check.")
  else
    print("|CFFFF0000AutomaticRoleCheck|r: " .. (cmd == "" and (AutomaticRoleCheck_Options.Enabled and "Enabled: " .. ((AutomaticRoleCheck_Options.DisableOnce or (AutomaticRoleCheck.FirstCheck and AutomaticRoleCheck_Options.DisableOnceOnLogin)) and "Will disable for the next role check." or "Will remain active for the next role check.") or "Disabled") or "Invalid command."))
    print("  Type |CFFFF0000/arc help|r for a listing of the addon commands.")
  end
end