SLASH_AUTOMATICROLECHECK1 = "/arc"

function SlashCmdList.AUTOMATICROLECHECK(cmd)
  if cmd == "enable" then
    AutomaticRoleCheck.Options.Enabled = true
    print("|CFF959697AutomaticRoleCheck|r: Enabled AutomaticRoleCheck")
  elseif cmd == "disable" then
    AutomaticRoleCheck.Options.Enabled = false
    print("|CFF959697AutomaticRoleCheck|r: Disabled AutomaticRoleCheck")
  elseif cmd == "disableonce" then
    AutomaticRoleCheck.Options.DisableOnce = true
    print("|CFF959697AutomaticRoleCheck|r: Disable Once AutomaticRoleCheck")
  else
    print("|CFF959697AutomaticRoleCheck|r: " .. (AutomaticRoleCheck.Options.Enabled and "Enabled" or "Disabled") .. " (|CFF9596971.4.0|r)")
  end
end
