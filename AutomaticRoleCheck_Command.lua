SLASH_AUTOMATICROLECHECK1 = "/arc"

function SlashCmdList.AUTOMATICROLECHECK(cmd)
    if cmd == "enable" then
        AutomaticRoleCheck.Options.Enabled = true
        print("|CFF959697AutomaticRoleCheck|r: Enabled AutomaticRoleCheck")
    elseif cmd == "disable" then
        AutomaticRoleCheck.Options.Enabled = false
        print("|CFF959697AutomaticRoleCheck|r: Disabled AutomaticRoleCheck")
    else
        print("|CFF959697AutomaticRoleCheck|r: 1.0.0")
    end
end