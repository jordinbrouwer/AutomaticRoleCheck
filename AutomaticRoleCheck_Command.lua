SLASH_AUTOMATICROLECHECK1 = "/arc"

SlashCmdList.AUTOMATICROLECHECK = function (cmd)
  if cmd == "help" then
    print("|CFF0077FFAutomaticRoleCheck|r: List of available commands:")
    print("  |CFF0077FF/arc options|r: To open the addon options.")
    print("  |CFF0077FF/arc enable|r: To enable the addon.")
    print("  |CFF0077FF/arc disable|r: To disable the addon.")
    print("  |CFF0077FF/arc disableonce|r: To disable the addon once the next role check.")
  elseif cmd == "options" then
    Settings.OpenToCategory(AutomaticRoleCheck.Panel:GetID())
  elseif cmd == "enable" then
    AutomaticRoleCheck_Options.Enabled = true
    print("|CFF0077FFAutomaticRoleCheck|r: Enabled the addon.")
  elseif cmd == "disable" then
    AutomaticRoleCheck_Options.Enabled = false
    print("|CFF0077FFAutomaticRoleCheck|r: Disabled the addon.")
  elseif cmd == "disableonce" then
    AutomaticRoleCheck_Options.DisableOnce = true
    print("|CFF0077FFAutomaticRoleCheck|r: Disabled once for the next role check.")
  else
    print("|CFF0077FFAutomaticRoleCheck|r: " .. (cmd == "" and (AutomaticRoleCheck_Options.Enabled and "Enabled: " .. ((AutomaticRoleCheck_Options.DisableOnce or (AutomaticRoleCheck.FirstCheck and AutomaticRoleCheck_Options.DisableOnceOnLogin)) and "Will disable for the next role check." or "Will remain active for the next role check.") or "Disabled.") or "Invalid command."))
    print("  Type |CFF0077FF/arc help|r for a listing of the addon commands.")
  end
end