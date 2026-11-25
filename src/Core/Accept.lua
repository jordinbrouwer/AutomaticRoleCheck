-- Accepting the popups (role check, role poll, invite, sign-up). Out of combat the Accept button is clicked at once.
-- In combat the game blocks that for addons, so the popup waits and is accepted when combat ends.
local ARC = AutomaticRoleCheck
local GetOptions = ARC.GetOptions

local pending = {}   -- button -> true, waiting for combat to end

-- The Accept buttons of the four popups, found when they exist (some are created late by the game).
local function IsRoleCheck(button) return button == LFDRoleCheckPopupAcceptButton end
local function IsRolePoll(button) return button == RolePollPopupAcceptButton end
local function IsInvite(button) return button == LFGInvitePopupAcceptButton end

-- Which setting key belongs to a popup ("Accept" .. kind).
local function PopupKind(button)
  if IsRoleCheck(button) then return "RoleCheck" end
  if IsRolePoll(button) then return "RolePoll" end
  if IsInvite(button) then return "Invite" end
  return "SignUp"
end

-- true while something waits for combat to end (the minimap button shows it)
ARC.IsWaiting = function() return next(pending) ~= nil end

local function Still(button)
  return button and button:IsVisible() and (not button.IsEnabled or button:IsEnabled())
end

---------------------------------------------------------------- hiding the game's popup
-- While it waits, the game's popup is hidden (alpha and mouse off, not closed). It comes back after combat.
local hidden = {} -- popup frame -> { mouse = { [frame] = wasEnabled } }

local function Restore(popup)
  local state = popup and hidden[popup]
  if not state then return end
  for f, was in pairs(state.mouse) do pcall(f.EnableMouse, f, was) end
  popup:SetAlpha(1)
  hidden[popup] = nil
end

local function HidePopup(button)
  local popup = button and button:GetParent()
  if not popup or hidden[popup] then return end
  -- If the game closes it by itself (it timed out), make it normal again for next time.
  if not popup.arcRestoreHooked then
    popup:HookScript("OnHide", function(self) Restore(self) end)
    popup.arcRestoreHooked = true
  end
  -- A protected frame can't be changed by an addon in combat (that gives the "blocked"
  -- error): then it is left as it is.
  if popup.IsProtected and popup:IsProtected() and InCombatLockdown() then return end
  local state = { mouse = {} }
  local function DisableMouse(f)
    if f.IsProtected and f:IsProtected() and InCombatLockdown() then return end
    if f.IsMouseEnabled and f.EnableMouse then
      state.mouse[f] = f:IsMouseEnabled()
      pcall(f.EnableMouse, f, false)
    end
    for _, child in ipairs({ f:GetChildren() }) do DisableMouse(child) end
  end
  DisableMouse(popup)
  popup:SetAlpha(0)
  hidden[popup] = state
end

local function ShowPopup(button)
  Restore(button and button:GetParent())
end

---------------------------------------------------------------- waiting for the end of combat
local function Wait(button)
  if pending[button] then return end
  pending[button] = true
  local options = GetOptions() or {}
  if options.PlaySoundInCombat ~= false then
    ARC.PlayOwnSound(tonumber(options.Sound) or (SOUNDKIT and SOUNDKIT.RAID_WARNING) or 8959)
  end
  if options.HideInCombat ~= false then HidePopup(button) end
  ARC.RefreshMinimapState()
end

ARC.On("PLAYER_REGEN_ENABLED", function()
  local any = false
  for button in pairs(pending) do
    any = true
    pending[button] = nil
    ShowPopup(button)
    if Still(button) then button:Click() end
  end
  if any then ARC.RefreshMinimapState() end
end)

---------------------------------------------------------------- the decision
-- Should this popup be accepted, given the settings and where you are? (Uses up "once" choices.)
local function ShouldAccept(button, options)
  -- These choices count for the moment the popup appears, also when it is accepted later.
  if options.Enabled and IsShiftKeyDown() then ARC.SetDisableOnce(true) end
  if not options.Enabled and not options.EnableOnce then return false end
  if options.DisableWhilstAFK and UnitIsAFK("player") then return false end
  -- Only the kinds of popup, roles and places you chose (a choice you made never uses up "once").
  if options["Accept" .. PopupKind(button)] == false then return false end
  local role = ARC.GetRoleName()
  if (role == "TANK" and options.AcceptTank == false) or (role == "HEALER" and options.AcceptHealer == false)
    or (role == "DAMAGER" and options.AcceptDamage == false) then return false end
  if options.Scope == "group" and not (IsInGroup() or IsInInstance()) then return false end
  if options.Scope == "instance" and not IsInInstance() then return false end
  if options.AcceptOutOfCombat == false and not InCombatLockdown() then return false end
  if options.DisableOnce then
    ARC.SetDisableOnce(false)
    return false
  end
  if options.EnableOnce then ARC.SetEnableOnce(false) end
  return true
end

local function AcceptNow(button)
  local options = GetOptions() or {}
  if InCombatLockdown() then
    -- With "Accept in combat" off nothing happens here: the game's popup stays for you to click.
    if options.AcceptInCombat ~= false then Wait(button) end
    return
  end
  if options.AcceptOutOfCombat == false then return end
  if options.HideOutOfCombat ~= false then HidePopup(button) end
  button:Click()
  -- If the popup is still there a moment later (the click did nothing), it comes back.
  C_Timer.After(0.3, function() ShowPopup(button) end)
  if options.PlaySoundOutOfCombat == true then
    ARC.PlayOwnSound(tonumber(options.SoundOutOfCombat) or 8960)
  end
end

-- Runs when one of the popups shows (a script on its Accept button).
ARC.Accept = function(button)
  local options = GetOptions()
  if not options or not ShouldAccept(button, options) then return end
  -- The delay is for accepting out of combat; after combat it is accepted straight away.
  local delay = tonumber(options.AcceptDelay) or 0
  if delay > 0 then
    C_Timer.After(delay, function() if Still(button) then AcceptNow(button) end end)
  else
    AcceptNow(button)
  end
end

---------------------------------------------------------------- hooking the popups
-- Each popup's Accept button gets our script once it exists.
local hooked = {}
local function Hook(name, getButton)
  if hooked[name] then return end
  local button = getButton()
  if button and button.HookScript then
    button:HookScript("OnShow", ARC.Accept)
    hooked[name] = true
  end
end

ARC.On("PLAYER_ENTERING_WORLD", function(isLogin, isReload)
  if not (isLogin or isReload) then return end   -- the first one can pass false for both
  local options = GetOptions()
  if not options then return end
  if not options.LastRole then options.LastRole = ARC.GetRoleName() end
  Hook("signUp", function() return LFGListApplicationDialog and LFGListApplicationDialog.SignUpButton end)
  Hook("invite", function() return LFGInvitePopupAcceptButton end)
  Hook("roleCheck", function() return LFDRoleCheckPopupAcceptButton end)
  Hook("rolePoll", function() return RolePollPopupAcceptButton end)
end)
