-- Sounds. While the addon is on, the game's own "ready check" sound is muted, so only your chosen sound plays.
-- (Our "Ready check" choice is the same file, so it is let through for a moment when we play it.)
-- The mute is per file, so it also hits popups the addon leaves to you: for those the sound is played again.
local ARC = AutomaticRoleCheck
local GetOptions = ARC.GetOptions

-- Both file ids of the game's "ready check" sound (the id changed over the years: both are muted).
local READY_SOUND_FILES = { 567478, 567409 }
local READY_CHECK_KIT = 8960
local gameSoundMuted = false

local function SetGameSoundMuted(mute)
  if not (MuteSoundFile and UnmuteSoundFile) then return end
  for _, file in ipairs(READY_SOUND_FILES) do
    if mute then MuteSoundFile(file) else UnmuteSoundFile(file) end
  end
  gameSoundMuted = mute
end

local function SyncGameSound()
  local options = GetOptions()
  local want = options ~= nil and options.Enabled == true and options.MuteGameSound ~= false
  if want ~= gameSoundMuted then SetGameSoundMuted(want) end
end

-- Plays one of the sounds you can choose in the options.
ARC.PlayOwnSound = function(id)
  if gameSoundMuted and id == READY_CHECK_KIT then
    SetGameSoundMuted(false)
    PlaySound(id, "Master")
    C_Timer.After(0.5, SyncGameSound)
  else
    PlaySound(id, "Master")
  end
end

-- The game's ready-check sound, for a popup the addon does not take over (silent while muted).
ARC.PlayGameSound = function()
  if gameSoundMuted then ARC.PlayOwnSound(READY_CHECK_KIT) end
end

-- Popups that play the ready-check sound and that the addon never accepts. Our handlers run after the
-- game's, so the muted sound has already gone by.
for _, event in ipairs({ "READY_CHECK", "LFG_PROPOSAL_SHOW", "LFG_READY_CHECK_SHOW" }) do
  ARC.On(event, ARC.PlayGameSound)
end

ARC.OnOptionChanged("Enabled", SyncGameSound)
ARC.On("PLAYER_ENTERING_WORLD", function(isLogin, isReload)
  if not (isLogin or isReload) then return end
  SyncGameSound()
  -- the Group Finder "you are invited" dialog
  if LFGListInviteDialog_Show then hooksecurefunc("LFGListInviteDialog_Show", ARC.PlayGameSound) end
end)
