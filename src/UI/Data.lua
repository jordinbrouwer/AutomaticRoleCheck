-- What each setting can be, and how a setting is read and written.
local ARC = AutomaticRoleCheck
local UI = ARC.UI

-- The choices behind the chips that switch to the next value when clicked.
local SOUNDS = {
  { value = 8959, label = "sound_raid_warning" },
  { value = 8960, label = "sound_ready_check" },
  { value = 878, label = "sound_quest_complete" },
  { value = 5274, label = "sound_auction_bell" },
  { value = 3081, label = "sound_whisper" },
}
local CHOICES = {
  Sound = SOUNDS,
  SoundOutOfCombat = SOUNDS,
  Scope = {
    { value = "everywhere", label = "choice_everywhere" },
    { value = "group", label = "choice_group" },
    { value = "instance", label = "choice_instance" },
  },
  AcceptDelay = {
    { value = 0, label = "choice_nowait" },
    { value = 1, label = "choice_1s" },
    { value = 2, label = "choice_2s" },
    { value = 3, label = "choice_3s" },
    { value = 5, label = "choice_5s" },
  },
}
-- What a click on the minimap button can do (the same list for every kind of click).
local CLICK_ACTIONS = {
  { value = "toggle", label = "act_toggle" },
  { value = "options", label = "act_options" },
  { value = "once", label = "act_once" },
  { value = "hide", label = "act_hide" },
  { value = "none", label = "act_none" },
}
local CLICK_SHORT = { toggle = "short_toggle", options = "short_options", once = "short_once", hide = "short_hide", none = "short_none" }   -- locale keys
local CLICK_MODS = { "", "Shift" }
local CLICK_BUTTONS = { "Left", "Right" }
local CLICK_KEYS = {}
for _, mod in ipairs(CLICK_MODS) do
  for _, name in ipairs(CLICK_BUTTONS) do
    local key = "Minimap" .. mod .. name .. "Click"
    CHOICES[key] = CLICK_ACTIONS
    CLICK_KEYS[#CLICK_KEYS + 1] = key
  end
end

local function GetOptions()
  return AutomaticRoleCheck_Options
end

local function GetOptionValue(configKey)
  local defaultValue = ARC.Defaults and ARC.Defaults[configKey]
  if defaultValue == nil then defaultValue = false end
  local options = GetOptions()
  if not options or options[configKey] == nil then return defaultValue end
  return options[configKey]
end

local function SetOption(key, value)
  if not GetOptions() then return end
  if key == "DisableOnce" then
    ARC.SetDisableOnce(value)
  elseif key == "EnableOnce" then
    ARC.SetEnableOnce(value)
  elseif key == "ShowMinimapButton" then
    ARC.SetShowMinimapButton(value)
  else
    -- the minimap button follows its settings straight away
    ARC.SetOption(key, value, key == "Enabled" or key:find("^Minimap") ~= nil)
  end
end

UI.CHOICES, UI.CLICK_SHORT, UI.CLICK_MODS, UI.CLICK_BUTTONS, UI.CLICK_KEYS = CHOICES, CLICK_SHORT, CLICK_MODS, CLICK_BUTTONS, CLICK_KEYS
UI.GetOptions, UI.GetOptionValue, UI.SetOption = GetOptions, GetOptionValue, SetOption
