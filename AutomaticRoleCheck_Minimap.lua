local addonName = AutomaticRoleCheck.AddonName
local iconPath = "Interface/AddOns/" .. addonName .. "/" .. addonName
local L = AutomaticRoleCheck.Loc
local RADIUS_OFFSET = 5
local BUTTON_SIZE = 31
local BACKGROUND_SIZE = 24
local ICON_SIZE = 13
local GLOW_SIZE = 16
local BORDER_SIZE = 50
local ICON_TEX_MIN = 0.05
local ICON_TEX_MAX = 0.95
local BACKGROUND_TEX_MAX = 0.6
local STATE_GLOW_ALPHA = 0.7
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
local TITLE_COLOR = { 1, 0.82, 0 }
local STATUS_ENABLED_COLOR = { 0.2, 1, 0.2 }
local STATUS_DISABLED_COLOR = { 1, 0.25, 0.25 }
local STATUS_LOADING_COLOR = { 1, 0.82, 0.2 }
local HINT_COLOR = { 0.8, 0.9, 1 }
local SPACER_COLOR = { 1, 1, 1 }

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

local function GetOptions()
  return AutomaticRoleCheck_Options
end

local function HasOptions()
  return GetOptions() ~= nil
end

local function CreateStyledTexture(parent, layer, texturePath, width, height, anchorPoint, x, y, left, right, top, bottom)
  local texture = parent:CreateTexture(nil, layer)
  texture:SetTexture(texturePath)
  texture:SetSize(width, height)
  texture:SetPoint(anchorPoint, x, y)
  if left ~= nil and right ~= nil and top ~= nil and bottom ~= nil then
    texture:SetTexCoord(left, right, top, bottom)
  end
  return texture
end

local function UpdateButtonPosition()
  local options = GetOptions()
  if not button or not options then return end
  local position = options.MinimapButtonAngle or AutomaticRoleCheck.Defaults.MinimapButtonAngle
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
end

local function UpdateVisibility()
  local options = GetOptions()
  if not button or not options then return end
  if options.ShowMinimapButton == false then
    button:Hide()
    if GameTooltip:IsOwned(button) then
      GameTooltip:Hide()
    end
    return
  end
  button:Show()
end

local function UpdateTooltip()
  if not button or not GameTooltip:IsOwned(button) then return end
  local options = GetOptions()
  GameTooltip:ClearLines()
  GameTooltip:SetText(L("minimap_tooltip_title"), TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])
  if not options then
    GameTooltip:AddLine(L("minimap_status_loading"), STATUS_LOADING_COLOR[1], STATUS_LOADING_COLOR[2], STATUS_LOADING_COLOR[3], true)
  elseif options.Enabled then
    GameTooltip:AddLine(L("minimap_status_enabled"), STATUS_ENABLED_COLOR[1], STATUS_ENABLED_COLOR[2], STATUS_ENABLED_COLOR[3], true)
  else
    GameTooltip:AddLine(L("minimap_status_disabled"), STATUS_DISABLED_COLOR[1], STATUS_DISABLED_COLOR[2], STATUS_DISABLED_COLOR[3], true)
  end
  GameTooltip:AddLine(" ", SPACER_COLOR[1], SPACER_COLOR[2], SPACER_COLOR[3], true)
  GameTooltip:AddLine(L("minimap_hint_toggle"), HINT_COLOR[1], HINT_COLOR[2], HINT_COLOR[3], true)
  GameTooltip:AddLine(L("minimap_hint_hide"), HINT_COLOR[1], HINT_COLOR[2], HINT_COLOR[3], true)
  GameTooltip:AddLine(L("minimap_hint_options"), HINT_COLOR[1], HINT_COLOR[2], HINT_COLOR[3], true)
  GameTooltip:Show()
end

local function UpdateStateGlow()
  local options = GetOptions()
  if not button or not stateGlow then return end
  if not options then
    stateGlow:Hide()
    return
  end
  if options.Enabled then
    stateGlow:SetVertexColor(0.15, 1, 0.15, 1)
  else
    stateGlow:SetVertexColor(1, 0.05, 0.05, 1)
  end
  stateGlow:SetAlpha(STATE_GLOW_ALPHA)
  stateGlow:Show()
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
  AutomaticRoleCheck.SetOption("MinimapButtonAngle", pos, false)
  UpdateButtonPosition()
end

local function ShowTooltip(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  UpdateTooltip()
end

local function CreateMinimapButton()
  button = CreateFrame("Button", "AutomaticRoleCheckMinimapButton", Minimap)
  button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
  button:RegisterForClicks("AnyUp")
  button:RegisterForDrag("LeftButton")

  local background = CreateStyledTexture(
    button,
    "BACKGROUND",
    "Interface/Minimap/UI-Minimap-Background",
    BACKGROUND_SIZE,
    BACKGROUND_SIZE,
    "CENTER",
    0,
    0,
    0,
    BACKGROUND_TEX_MAX,
    0,
    BACKGROUND_TEX_MAX
  )
  background:SetVertexColor(0, 0, 0, 0.45)

  CreateStyledTexture(
    button,
    "ARTWORK",
    iconPath,
    ICON_SIZE,
    ICON_SIZE,
    "CENTER",
    0,
    0,
    ICON_TEX_MIN,
    ICON_TEX_MAX,
    ICON_TEX_MIN,
    ICON_TEX_MAX
  )

  stateGlow = CreateStyledTexture(
    button,
    "OVERLAY",
    iconPath,
    GLOW_SIZE,
    GLOW_SIZE,
    "CENTER",
    0,
    0,
    ICON_TEX_MIN,
    ICON_TEX_MAX,
    ICON_TEX_MIN,
    ICON_TEX_MAX
  )
  stateGlow:SetBlendMode("ADD")
  stateGlow:Hide()

  button:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight", "ADD")

  CreateStyledTexture(
    button,
    "OVERLAY",
    "Interface/Minimap/MiniMap-TrackingBorder",
    BORDER_SIZE,
    BORDER_SIZE,
    "TOPLEFT",
    0,
    0
  )

  button:SetScript("OnEnter", ShowTooltip)
  button:SetScript("OnLeave", GameTooltip_Hide)

  button:SetScript("OnClick", function(self, mouseButton)
    local options = GetOptions()
    if not options then
      AutomaticRoleCheck.PrintError(L("options_not_loaded"))
      return
    end
    if mouseButton == "RightButton" then
      AutomaticRoleCheck.OpenOptions()
    elseif mouseButton == "LeftButton" then
      if self.arcSuppressClickToggle then
        self.arcSuppressClickToggle = false
        return
      end
      if IsShiftKeyDown() then
        AutomaticRoleCheck.SetShowMinimapButton(false)
        AutomaticRoleCheck.PrintInfo(L("minimap_hidden_print"))
        return
      end
      AutomaticRoleCheck.SetEnabled(not options.Enabled)
    end
    UpdateStateGlow()
    UpdateTooltip()
  end)

  button:SetScript("OnDragStart", function(self)
    if not HasOptions() then return end
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

  AutomaticRoleCheck.Minimap_OnOptionsChanged = function()
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
