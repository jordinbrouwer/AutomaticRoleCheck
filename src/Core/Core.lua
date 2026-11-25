-- The base: the shared table, pictures, printing and the one place that listens to game events.
-- The work is in Options, Sound, Roles and Accept; the window in UI/; the button in Minimap; /arc in Command.
AutomaticRoleCheck = AutomaticRoleCheck or {}
local ARC = AutomaticRoleCheck
ARC.AddonName = ...

-- Pictures (our own .tga files in the Media folder).
local MEDIA_DIR = "Interface\\AddOns\\" .. ARC.AddonName .. "\\Media\\"
ARC.Media = {
  Logo = MEDIA_DIR .. "Logo",              -- the full logo (addon icon, window header)
  LogoBase = MEDIA_DIR .. "Logo_Base",     -- the logo without its check mark (minimap button)
  LogoCheck = MEDIA_DIR .. "Logo_Check",   -- the check mark alone, grey, so it can be tinted
  Linked = MEDIA_DIR .. "Linked",
  Unlinked = MEDIA_DIR .. "Unlinked",
  Reset = MEDIA_DIR .. "Reset",
  Grip = MEDIA_DIR .. "Grip",
}

-- The orange of the logo, as a colour code (for tooltips).
ARC.ORANGE = "|cfff26626"

-- Messages for the player: always a toast at the top of the screen (UI/Toast.lua), never a chat line.
ARC.Print = function(message, kind)
  if ARC.ShowToast then ARC.ShowToast(message, kind) end
end
ARC.PrintInfo = function(message) ARC.Print(message, "info") end
ARC.PrintError = function(message) ARC.Print(message, "error") end

-- The saved settings of this character (nil until the game has loaded them).
ARC.GetOptions = function()
  return AutomaticRoleCheck_Options
end

ARC.RefreshMinimapState = function()
  if ARC.Minimap_OnOptionsChanged then
    ARC.Minimap_OnOptionsChanged()
  end
end

-- Game events: ARC.On("EVENT", fn). One frame listens for all of them.
local handlers = {}
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, ...)
  for _, handler in ipairs(handlers[event]) do handler(...) end
end)

ARC.On = function(event, handler)
  if not handlers[event] then
    handlers[event] = {}
    eventFrame:RegisterEvent(event)
  end
  table.insert(handlers[event], handler)
end
