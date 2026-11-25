local ARC = AutomaticRoleCheck
local addonName = ARC.AddonName
local basePath = ARC.Media.LogoBase     -- the logo without its check mark
local checkPath = ARC.Media.LogoCheck   -- the check mark alone, in grey, so it can be tinted
local ON_COLOR = { 0.25, 0.95, 0.35 }
local OFF_COLOR = { 1, 0.28, 0.28 }
local WAITING_COLOR = { 1, 0.78, 0.15 }
local NEUTRAL_COLOR = { 1, 0.55, 0.12 }   -- the check's own orange, when the status colour is switched off
local L = ARC.Loc
local RADIUS_OFFSET = 5
local BUTTON_SIZE = 31
local abs = math.abs
local atan2 = math.atan2
local cos = math.cos
local deg = math.deg
local max = math.max
local min = math.min
local rad = math.rad
local sin = math.sin
local sqrt = math.sqrt
local DRAG_UPDATE_INTERVAL = 0.02
local DRAG_START_THRESHOLD = 6
local STATUS_ENABLED_COLOR = { 0.2, 1, 0.2 }
local STATUS_DISABLED_COLOR = { 1, 0.25, 0.25 }
local STATUS_LOADING_COLOR = { 1, 0.82, 0.2 }

local minimapShapes = {
  ["ROUND"] = { true, true, true, true },
  ["SQUARE"] = { false, false, false, false },
  ["CORNER-TOPLEFT"] = { false, false, false, true },
  ["CORNER-TOPRIGHT"] = { false, false, true, false },
  ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
  ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
  ["SIDE-LEFT"] = { false, true, false, true },
  ["SIDE-RIGHT"] = { true, false, true, false },
  ["SIDE-TOP"] = { false, false, true, true },
  ["SIDE-BOTTOM"] = { true, true, false, false },
  ["TRICORNER-TOPLEFT"] = { false, true, true, true },
  ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
  ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
  ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local button
local stateGlow
local dragElapsed = 0

local GetOptions = ARC.GetOptions

local function HasOptions()
  return GetOptions() ~= nil
end

local ownedX, ownedY   -- where we last put the button ourselves

-- True when another addon (a button manager like EllesmereUI) moved the button: then we leave it alone.
local function MovedByOthers()
  if ownedX == nil then return false end
  if button:GetParent() ~= Minimap then return true end
  local point, relativeTo, relativePoint, x, y = button:GetPoint(1)
  if point ~= "CENTER" or relativeTo ~= Minimap or relativePoint ~= "CENTER" then return true end
  return abs((x or 0) - ownedX) > 0.5 or abs((y or 0) - ownedY) > 0.5
end

local function UpdateButtonPosition()
  local options = GetOptions()
  if not button or not options then return end
  if MovedByOthers() then return end
  local position = options.MinimapButtonAngle or ARC.Defaults.MinimapButtonAngle
  local angle = rad(position)
  local x, y = cos(angle), sin(angle)
  local q = 1
  if x < 0 then
    q = q + 1
  end
  if y > 0 then
    q = q + 2
  end
  local minimapShape = (GetMinimapShape and GetMinimapShape()) or "ROUND"
  local quadTable = minimapShapes[minimapShape] or minimapShapes["ROUND"]
  local w = (Minimap:GetWidth() / 2) + RADIUS_OFFSET
  local h = (Minimap:GetHeight() / 2) + RADIUS_OFFSET
  if quadTable[q] then
    x, y = x * w, y * h
  else
    local diagRadiusW = sqrt(2 * (w) ^ 2) - 10
    local diagRadiusH = sqrt(2 * (h) ^ 2) - 10
    x = max(-w, min(x * diagRadiusW, w))
    y = max(-h, min(y * diagRadiusH, h))
  end
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", x, y)
  ownedX, ownedY = x, y
end

local function UpdateVisibility()
  local options = GetOptions()
  if not button or not options then return end
  if options.ShowMinimapButton == false then
    button:Hide()
    ARC.UI.Tip.Hide(button)
    return
  end
  button:Show()
end

local function ColorCode(c)
  return string.format("|cff%02x%02x%02x", math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

local function UpdateTooltip()
  local Tip = ARC.UI.Tip
  if not button or not Tip.IsOwned(button) then return end
  local options = GetOptions()
  local lines = {}
  if not options then
    lines[#lines + 1] = ColorCode(STATUS_LOADING_COLOR) .. L("minimap_status_loading") .. "|r"
  elseif options.Enabled then
    lines[#lines + 1] = ColorCode(STATUS_ENABLED_COLOR) .. L("minimap_status_enabled") .. "|r"
  else
    lines[#lines + 1] = ColorCode(STATUS_DISABLED_COLOR) .. L("minimap_status_disabled") .. "|r"
  end
  if ARC.IsWaiting and ARC.IsWaiting() then
    lines[#lines + 1] = ColorCode(WAITING_COLOR) .. L("minimap_status_waiting") .. "|r"
  end
  lines[#lines + 1] = " "
  -- One line per click that does something, as set in the options.
  for _, mod in ipairs({ "", "Shift", "Ctrl", "Alt" }) do
    for _, name in ipairs({ "Left", "Right", "Middle" }) do
      local key = "Minimap" .. mod .. name .. "Click"
      local action = options and options[key] or ARC.Defaults[key]
      if action and action ~= "none" then
        local what = L("minimap_act_" .. action)
        if action == "once" then
          what = L(options and options.Enabled and "minimap_act_once_off" or "minimap_act_once_on")
        end
        local label = (mod ~= "" and (mod .. " + ") or "") .. name .. "-click"
        lines[#lines + 1] = ARC.ORANGE .. label .. ":|r " .. what .. "."
      end
    end
  end
  Tip.Show(button, "LEFT", L("minimap_tooltip_title"), unpack(lines))
end
local function UpdateStateGlow()
  local options = GetOptions()
  if not button or not stateGlow then return end
  local c = NEUTRAL_COLOR
  if options and options.MinimapGlow ~= false then
    if ARC.IsWaiting and ARC.IsWaiting() then
      c = WAITING_COLOR      -- something is waiting for combat to end
    elseif options.Enabled then
      c = ON_COLOR
    else
      c = OFF_COLOR
    end
  end
  stateGlow:SetVertexColor(c[1], c[2], c[3], 1)
end

local dragStartX, dragStartY

local function OnDragUpdate(self, elapsed)
  dragElapsed = dragElapsed + elapsed
  if dragElapsed < DRAG_UPDATE_INTERVAL then return end
  dragElapsed = 0
  local px, py = GetCursorPosition()
  if not self.arcDragConfirmed then
    if abs(px - dragStartX) + abs(py - dragStartY) < DRAG_START_THRESHOLD then
      return
    end
    self.arcDragConfirmed = true
  end
  local mx, my = Minimap:GetCenter()
  if not mx or not my then return end
  local scale = Minimap:GetEffectiveScale()
  px, py = px / scale, py / scale
  local pos = deg(atan2(py - my, px - mx)) % 360
  ARC.SetOption("MinimapButtonAngle", pos, false)
  UpdateButtonPosition()
end

local function ShowTooltip(self)
  ARC.UI.Tip.Show(self, "LEFT", "")
  UpdateTooltip()
end

local function CreateMinimapButton()
  button = CreateFrame("Button", "AutomaticRoleCheckMinimapButton", Minimap)
  button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
  button:RegisterForClicks("AnyUp")
  button:RegisterForDrag("LeftButton")

  -- the logo, with its check mark tinted to show the state: green on, red off, amber waiting
  local base = button:CreateTexture(nil, "ARTWORK")
  base:SetTexture(basePath)
  stateGlow = button:CreateTexture(nil, "ARTWORK", nil, 1)
  stateGlow:SetTexture(checkPath)
  stateGlow:SetAllPoints(base)
  stateGlow:SetVertexColor(NEUTRAL_COLOR[1], NEUTRAL_COLOR[2], NEUTRAL_COLOR[3], 1)
  -- Button managers look for button.icon and may crop it; the check mark follows the same crop.
  button.icon = base
  hooksecurefunc(base, "SetTexCoord", function(_, ...) stateGlow:SetTexCoord(...) end)

  local function ApplyLook()
    base:ClearAllPoints()
    base:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    base:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    base:SetTexCoord(0, 1, 0, 1)
    base:SetAlpha(1)
    base:Show()
    stateGlow:SetAlpha(1)
    stateGlow:Show()
  end
  ApplyLook()
  button:HookScript("OnShow", ApplyLook)
  button:HookScript("OnClick", function()
    C_Timer.After(0, ApplyLook)
    C_Timer.After(0.3, ApplyLook)
  end)

  -- under the mouse the logo lights up a little
  button:SetHighlightTexture(basePath, "ADD")
  local highlight = button:GetHighlightTexture()
  highlight:ClearAllPoints()
  highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
  highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
  highlight:SetVertexColor(1, 1, 1, 0.25)

  button:SetScript("OnEnter", ShowTooltip)
  button:SetScript("OnLeave", function() ARC.UI.Tip.Hide() end)

  button:SetScript("OnClick", function(self, mouseButton)
    local options = GetOptions()
    if not options then
      ARC.PrintError(L("options_not_loaded"))
      return
    end
    -- Which click is it? What it does is set in the options (left, right, shift + left, middle).
    if mouseButton == "LeftButton" and self.arcSuppressClickToggle then
      self.arcSuppressClickToggle = false
      return
    end
    -- Setting name: Minimap + key + button + Click, e.g. MinimapShiftRightClick.
    local name = (mouseButton == "LeftButton" and "Left") or (mouseButton == "RightButton" and "Right")
      or (mouseButton == "MiddleButton" and "Middle") or nil
    local mod = IsShiftKeyDown() and "Shift" or IsControlKeyDown() and "Ctrl" or IsAltKeyDown() and "Alt" or ""
    local key = name and ("Minimap" .. mod .. name .. "Click") or nil
    local action = key and (options[key] or ARC.Defaults[key])
    if action == "toggle" then
      ARC.SetEnabled(not options.Enabled)
    elseif action == "options" then
      ARC.OpenOptions()
    elseif action == "once" then
      -- Skip (or, when it is off, allow) the next role check only.
      if options.Enabled then
        ARC.SetDisableOnce(true)
        ARC.PrintInfo(L("cmd_disabled_once"))
      else
        ARC.SetEnableOnce(true)
        ARC.PrintInfo(L("cmd_enabled_once"))
      end
    elseif action == "hide" then
      ARC.SetShowMinimapButton(false)
      ARC.PrintInfo(L("minimap_hidden_print"))
      return
    end
    UpdateStateGlow()
    UpdateTooltip()
  end)

  button:SetScript("OnDragStart", function(self)
    if not HasOptions() or GetOptions().MinimapLocked then return end
    dragElapsed = 0
    dragStartX, dragStartY = GetCursorPosition()
    self.arcDragConfirmed = false
    self:SetScript("OnUpdate", OnDragUpdate)
  end)

  button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    if self.arcDragConfirmed then
      self.arcSuppressClickToggle = true
      local b = self
      C_Timer.After(0, function()
        if b.arcSuppressClickToggle then
          b.arcSuppressClickToggle = false
        end
      end)
    end
    self.arcDragConfirmed = false
  end)

  UpdateVisibility()
  UpdateStateGlow()
  UpdateButtonPosition()

  ARC.Minimap_OnOptionsChanged = function()
    UpdateVisibility()
    UpdateStateGlow()
    UpdateTooltip()
    UpdateButtonPosition()
  end

  local pewFrame = CreateFrame("Frame")
  pewFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  pewFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event ~= "PLAYER_ENTERING_WORLD" or not (arg1 or arg2) then return end
    UpdateVisibility()
    UpdateStateGlow()
    UpdateButtonPosition()
  end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, arg1)
  if event ~= "ADDON_LOADED" or arg1 ~= addonName then return end
  loader:UnregisterAllEvents()
  CreateMinimapButton()
end)
