-- Your roles: which specialization you play, the roles you queue as, and keeping them in step.
local ARC = AutomaticRoleCheck
local GetOptions = ARC.GetOptions

-- Newer clients moved the specialization API into C_SpecializationInfo and
-- removed the old globals; fall back to the globals on older clients.
local GetSpec = (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization) or GetSpecialization
local GetSpecInfo = (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo) or GetSpecializationInfo

-- "TANK", "HEALER" or "DAMAGER" for the current specialization.
ARC.GetRoleName = function()
  if not (GetSpec and GetSpecInfo) then return end
  local spec = GetSpec()
  if spec == nil then return end
  return (select(5, GetSpecInfo(spec)))
end

-- The Group Finder roles (tank, healer, damage) that a role check gives you; the options window shows
-- them as three icons. Setting them is not possible in combat.
ARC.GetRoles = function()
  if not GetLFGRoles then return false, false, false end
  local _, tank, healer, damage = GetLFGRoles()
  return tank and true or false, healer and true or false, damage and true or false
end

ARC.SetRoles = function(tank, healer, damage)
  if not SetLFGRoles then return false end
  if InCombatLockdown() then return false end
  local leader = GetLFGRoles and select(1, GetLFGRoles()) or false
  pcall(SetLFGRoles, leader and true or false, tank and true or false, healer and true or false, damage and true or false)
  local options = GetOptions()
  if options and options.SetGroupRole and IsInGroup() then
    local role = ARC.GroupRole(tank, healer, damage)
    if role and UnitSetRole then pcall(UnitSetRole, "player", role) end
  end
  return true
end

-- The one role to have in a group, from the roles you queue as (the first of tank, healer, damage).
ARC.GroupRole = function(tank, healer, damage)
  return tank and "TANK" or healer and "HEALER" or damage and "DAMAGER" or nil
end

-- The roles follow the current specialization (when "Follow spec" is on).
ARC.ApplySpecRole = function()
  local options = GetOptions()
  if not options or not options.FollowSpec then return end
  local role = ARC.GetRoleName()
  if not role then return end
  ARC.SetRoles(role == "TANK", role == "HEALER", role == "DAMAGER")
end

ARC.On("PLAYER_SPECIALIZATION_CHANGED", function(unit)
  if unit ~= "player" then return end
  local options = GetOptions()
  if not options then return end
  if options.FollowSpec then C_Timer.After(1, ARC.ApplySpecRole) end
  if not options.DisableOnceOnRoleChange then return end

  local roleName = ARC.GetRoleName()
  if roleName == options.LastRole then return end
  ARC.SetDisableOnce(true)
  options.LastRole = roleName
end)

-- Joined a group: set the role there too, from the roles you queue as.
ARC.On("GROUP_JOINED", function()
  local options = GetOptions()
  if options and options.SetGroupRole then
    C_Timer.After(1, function() ARC.SetRoles(ARC.GetRoles()) end)
  end
end)
