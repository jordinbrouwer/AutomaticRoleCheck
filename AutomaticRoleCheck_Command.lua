SLASH_AUTOMATICROLECHECK1 = "/arc"

function SlashCmdList.AUTOMATICROLECHECK(cmd)
  if cmd == "" then
    print("|CFF959697AutomaticRoleCheck|r: Currently " .. (AutomaticRoleCheck.Options.Enabled and "enabled" or "disabled"))
    print("  |CFF959697/arc enable|r: To enable the addon")
    print("  |CFF959697/arc disable|r: To disable the addon")
    print("  |CFF959697/arc disableonce|r: To disable the addon once")
  elseif cmd == "enable" then
    AutomaticRoleCheck.Options.Enabled = true
    print("|CFF959697AutomaticRoleCheck|r: Enabled AutomaticRoleCheck")
  elseif cmd == "disable" then
    AutomaticRoleCheck.Options.Enabled = false
    print("|CFF959697AutomaticRoleCheck|r: Disabled AutomaticRoleCheck")
  elseif cmd == "disableonce" then
    AutomaticRoleCheck.Options.DisableOnce = true
    print("|CFF959697AutomaticRoleCheck|r: Disabled AutomaticRoleCheck once")
  else
    print("|CFF959697AutomaticRoleCheck|r: Invalid command")
  end
end