-- The three role buttons (Tank, Healer, Damage) and what they do.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local roleButtons = UI.roleButtons
local L = ARC.Loc
local GetOptions = UI.GetOptions

-- The three role icons ("My role"): the roles you queue as in the Group Finder.
local ROLE_BOX_H = 26
local ROLES = {
  { role = "TANK",    name = "role_tank",   atlas = "UI-LFG-RoleIcon-Tank-Micro-GroupFinder"   },
  { role = "HEALER",  name = "role_healer", atlas = "UI-LFG-RoleIcon-Healer-Micro-GroupFinder" },
  { role = "DAMAGER", name = "role_damage", atlas = "UI-LFG-RoleIcon-DPS-Micro-GroupFinder"    },
}
-- The game confirms a change slowly. For 1.5 seconds the icons show what you asked for,
-- so clicking two roles in a row works.
local wanted, wantedAt

-- Which roles your class can fill at all.
local function Available()
  if UnitGetAvailableRoles then
    local tank, healer, damage = UnitGetAvailableRoles("player")
    return { TANK = tank and true or false, HEALER = healer and true or false, DAMAGER = damage and true or false }
  end
  return { TANK = true, HEALER = true, DAMAGER = true }
end

local function CurrentRoles()
  if wanted and wantedAt and GetTime() - wantedAt < 1.5 then return wanted end
  wanted = nil
  local t, h, d = ARC.GetRoles()
  return { TANK = t, HEALER = h, DAMAGER = d }
end

local function SyncRoles()
  if #roleButtons == 0 then return end
  local state = CurrentRoles()
  local available = Available()
  for _, btn in ipairs(roleButtons) do
    local can = available[btn.role]
    local on = state[btn.role] and can
    btn.can = can
    -- Three looks: on (gold), off but possible (normal border and text), and not possible for your
    -- class (faint, with the icon greyed out).
    local c
    if on then c = THEME.ACCENT elseif can then c = THEME.GREY else c = { 0.2, 0.21, 0.24 } end
    UI.SetBorderColor(btn.border, c)
    if on then
      btn.bg:SetColorTexture(0.03, 0.1, 0.15, 1)
    elseif can then
      btn.bg:SetColorTexture(0.09, 0.1, 0.12, 1)
    else
      btn.bg:SetColorTexture(0.03, 0.03, 0.04, 1)
    end
    if can then
      btn.label:SetTextColor(on and 0.35 or 0.85, on and 0.8 or 0.86, on and 1 or 0.9)
      btn:SetAlpha(1)
      btn.icon:SetDesaturated(false)
    else
      btn.label:SetTextColor(0.38, 0.38, 0.4)
      btn:SetAlpha(0.45)
      btn.icon:SetDesaturated(true)
    end
  end
end

-- Toggles one role. Several roles can be on at once, as in the Group Finder.
local function ToggleRole(role)
  if not GetOptions() then return end
  if not Available()[role] then
    return
  end
  local current = CurrentRoles()
  local want = { TANK = current.TANK, HEALER = current.HEALER, DAMAGER = current.DAMAGER }
  want[role] = not want[role]
  if not (want.TANK or want.HEALER or want.DAMAGER) then return end -- keep at least one role
  if not ARC.SetRoles(want.TANK, want.HEALER, want.DAMAGER) then
    ARC.PrintError(L("roles_combat"))
    return
  end
  wanted, wantedAt = want, GetTime()
  SyncRoles()
  -- Afterwards, look at what the game really did: if it did not accept the change, say so.
  C_Timer.After(1.6, function()
    wanted = nil
    local t, h, d = ARC.GetRoles()
    if t ~= (want.TANK and true or false) or h ~= (want.HEALER and true or false) or d ~= (want.DAMAGER and true or false) then
      ARC.PrintError(L("roles_rejected"))
    end
    SyncRoles()
  end)
end

-- The icons follow the game: roles can also be changed in the Group Finder.
local roleEvents = CreateFrame("Frame")
roleEvents:RegisterEvent("LFG_ROLE_UPDATE")
roleEvents:SetScript("OnEvent", function() wanted = nil SyncRoles() end)

UI.ROLE_BOX_H, UI.ROLES, UI.SyncRoles, UI.ToggleRole = ROLE_BOX_H, ROLES, SyncRoles, ToggleRole
