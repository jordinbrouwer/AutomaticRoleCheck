-- The settings: their defaults, changing them, and tidying the saved file when the addon loads.
local ARC = AutomaticRoleCheck
local GetOptions = ARC.GetOptions

ARC.Defaults = {
  Enabled = true,
  ShowMinimapButton = true,
  DisableWhilstAFK = false,
  DisableOnce = false,
  EnableOnce = false,
  DisableOnceOnLogin = false,
  DisableOnceOnRoleChange = false,
  AcceptInCombat = true,   -- in combat: accept right after combat ends (the game won't let addons do it earlier)
  HideInCombat = true,     -- while waiting, the game's own popup is hidden
  PlaySoundInCombat = true,
  Sound = 8960,            -- sound kit played when something starts waiting
  AcceptRoleCheck = true,  -- which kinds of popup are accepted
  AcceptRolePoll = true,
  AcceptInvite = true,
  AcceptSignUp = true,
  AcceptTank = true,       -- ... and for which role you are playing
  AcceptHealer = true,
  AcceptDamage = true,
  Scope = "everywhere",    -- "everywhere", "group" (a group or an instance) or "instance"
  AcceptDelay = 0,         -- seconds to wait before accepting (out of combat)
  LinkCombat = true,       -- out-of-combat settings copy the in-combat ones (so the two sets of defaults below are the same)
  FollowSpec = false,      -- keep the roles you queue as in step with your current specialization
  SetGroupRole = false,    -- also set your role in your group (outside combat)
  AcceptOutOfCombat = true,        -- out of combat: accept for you
  HideOutOfCombat = true,          -- ... without the popup showing
  PlaySoundOutOfCombat = true,
  SoundOutOfCombat = 8960,
  MinimapButtonAngle = 225,
  MinimapGlow = true,         -- the check mark of the button shows on, off or waiting
  MinimapLocked = false,      -- the button can't be dragged
  -- What each click on the minimap button does: "toggle", "options", "once" (skip or allow the next check),
  -- "hide" or "none". Names: MinimapLeftClick, MinimapShiftRightClick, MinimapCtrlMiddleClick, ...
  MinimapLeftClick = "toggle",
  MinimapRightClick = "options",
  MinimapMiddleClick = "none",
  MinimapShiftLeftClick = "hide",
  MinimapShiftRightClick = "none",
  MinimapShiftMiddleClick = "none",
  MinimapCtrlLeftClick = "none",
  MinimapCtrlRightClick = "none",
  MinimapCtrlMiddleClick = "none",
  MinimapAltLeftClick = "none",
  MinimapAltRightClick = "none",
  MinimapAltMiddleClick = "none",
}

-- With "Linked" on, the out-of-combat settings copy the in-combat ones (the options window shows them
-- as two columns of one table).
local IN_TO_OUT = {
  AcceptInCombat = "AcceptOutOfCombat",
  HideInCombat = "HideOutOfCombat",
  PlaySoundInCombat = "PlaySoundOutOfCombat",
  Sound = "SoundOutOfCombat",
}
ARC.LinkedKeys = IN_TO_OUT

-- Other parts can follow a setting: ARC.OnOptionChanged("Enabled", function(value) ... end)
local observers = {}
ARC.OnOptionChanged = function(key, handler)
  observers[key] = observers[key] or {}
  table.insert(observers[key], handler)
end

ARC.SetOption = function(key, value, refreshMinimap)
  local options = GetOptions()
  if not options then return false end
  if options[key] == value then return false end
  options[key] = value
  if key == "LinkCombat" and value then
    for inKey, outKey in pairs(IN_TO_OUT) do options[outKey] = options[inKey] end
  elseif options.LinkCombat and IN_TO_OUT[key] then
    options[IN_TO_OUT[key]] = value
  end
  if ARC.RefreshWindow then ARC.RefreshWindow(key) end
  for _, handler in ipairs(observers[key] or {}) do handler(value) end
  if refreshMinimap then ARC.RefreshMinimapState() end
  return true
end

ARC.SetEnabled = function(enabled)
  ARC.SetOption("Enabled", enabled, true)
end

ARC.SetDisableOnce = function(value)
  return ARC.SetOption("DisableOnce", value, false)
end

ARC.SetEnableOnce = function(value)
  return ARC.SetOption("EnableOnce", value, false)
end

ARC.SetShowMinimapButton = function(value)
  return ARC.SetOption("ShowMinimapButton", value, true)
end

-- The saved file. DB_VERSION goes up when settings are renamed or removed; the steps run once.
local DB_VERSION = 2
local OBSOLETE_KEYS = {   -- settings of features that were taken out (the "accepted" notices, the button size)
  "ShowNotice", "ShowNoticeOutOfCombat", "NoticeSeconds", "NoticeSecondsOutOfCombat", "MinimapSize",
}

local function Migrate(options)
  if (options.DbVersion or 0) >= DB_VERSION then return end
  for _, key in ipairs(OBSOLETE_KEYS) do options[key] = nil end
  options.DbVersion = DB_VERSION
end

ARC.On("ADDON_LOADED", function(addonName)
  if addonName ~= ARC.AddonName then return end
  AutomaticRoleCheck_Options = AutomaticRoleCheck_Options or {}
  local options = AutomaticRoleCheck_Options
  Migrate(options)
  for key, value in pairs(ARC.Defaults) do
    if options[key] == nil then options[key] = value end
  end
  if not options.LastRole then options.LastRole = ARC.GetRoleName() end
  if options.DisableOnceOnLogin then ARC.SetDisableOnce(true) end
end)
