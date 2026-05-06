AutomaticRoleCheck = AutomaticRoleCheck or {}

local canvasFrame = CreateFrame("Frame")
local L = AutomaticRoleCheck.Loc

AutomaticRoleCheck.Panel = Settings.RegisterCanvasLayoutCategory(canvasFrame, L("settings_category"))

local LAYOUT = {
  LEFT_MARGIN = 16,
  BOX_LEFT = 16,
  BOX_RIGHT_MARGIN = 16,
  CHECK_INDENT = 12,
  ROW_HEIGHT = 26,
  BOX_PADDING_BOT = 8,
  BOX_HEADER_HEIGHT = 20,
  START_Y = -16,
  LOGO_SIZE = 32,
  BOX_VERTICAL_GAP = 8,
  BOX_HEADER_OFFSET = 2,
  TOP_ELEMENT_OFFSET = -2,
  MINIMAP_ROW_WIDTH = 200,
  MINIMAP_ROW_OFFSET_X = 20,
  MINIMAP_ROW_OFFSET_Y = 16,
}

local THEME = {
  SECTION_COLOR = { r = 1, g = 0.82, b = 0, a = 1 },
  BOX_BG_COLOR = { r = 0.1, g = 0.1, b = 0.1, a = 0.6 },
  BOX_BORDER_COLOR = { r = 0.4, g = 0.4, b = 0.4, a = 0.8 },
  ICON_TEX_MIN = 0.05,
  ICON_TEX_MAX = 0.95,
}

local function GetOptions()
  return AutomaticRoleCheck_Options
end

local function GetOptionValue(configKey)
  local defaultValue = (AutomaticRoleCheck.Defaults and AutomaticRoleCheck.Defaults[configKey]) or false
  local options = GetOptions()
  if not options or options[configKey] == nil then return defaultValue end
  return options[configKey]
end

local function CreateBox(parent, label)
  local box = CreateFrame("Frame", nil, parent)

  local bg = box:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(box)
  bg:SetColorTexture(THEME.BOX_BG_COLOR.r, THEME.BOX_BG_COLOR.g, THEME.BOX_BG_COLOR.b, THEME.BOX_BG_COLOR.a)

  local function MakeLine(anchor1, anchor2, offsetX1, offsetY1, offsetX2, offsetY2)
    local line = box:CreateTexture(nil, "BORDER")
    line:SetColorTexture(THEME.BOX_BORDER_COLOR.r, THEME.BOX_BORDER_COLOR.g, THEME.BOX_BORDER_COLOR.b, THEME.BOX_BORDER_COLOR.a)
    line:SetPoint(anchor1, box, anchor1, offsetX1, offsetY1)
    line:SetPoint(anchor2, box, anchor2, offsetX2, offsetY2)
    return line
  end
  MakeLine("TOPLEFT", "TOPRIGHT", 0, 0, 0, -1)
  MakeLine("BOTTOMLEFT", "BOTTOMRIGHT", 0, 1, 0, 0)
  MakeLine("TOPLEFT", "BOTTOMLEFT", 0, 0, 1, 0)
  MakeLine("TOPRIGHT", "BOTTOMRIGHT", -1, 0, 0, 0)

  if label then
    local title = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", box, "TOPLEFT", 8, -6)
    title:SetTextColor(THEME.SECTION_COLOR.r, THEME.SECTION_COLOR.g, THEME.SECTION_COLOR.b, THEME.SECTION_COLOR.a)
    title:SetText(label)
  end

  return box
end

local function CreateCheckboxRow(parent, configKey, labelText, tooltipText)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(LAYOUT.ROW_HEIGHT)

  local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  cb:SetSize(24, 24)
  cb:SetPoint("LEFT", row, "LEFT", 0, 0)

  local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
  lbl:SetText(labelText)

  if tooltipText then
    row:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", GameTooltip_Hide)
  end

  row:EnableMouse(true)
  row:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      cb:Click()
    end
  end)

  cb:SetChecked(GetOptionValue(configKey) == true)

  cb:SetScript("OnClick", function(self)
    if not GetOptions() then return end
    local value = self:GetChecked()
    if configKey == "DisableOnce" then
      AutomaticRoleCheck.SetDisableOnce(value)
    elseif configKey == "EnableOnce" then
      AutomaticRoleCheck.SetEnableOnce(value)
    elseif configKey == "ShowMinimapButton" then
      AutomaticRoleCheck.SetShowMinimapButton(value)
    else
      AutomaticRoleCheck.SetOption(configKey, value, configKey == "Enabled")
    end
  end)

  return row, cb
end

local checkboxFrames = {}
local enabledBox, disabledBox

local function SetPanelModeEnabled(isEnabled)
  if enabledBox then
    enabledBox:SetShown(isEnabled)
  end
  if disabledBox then
    disabledBox:SetShown(not isEnabled)
  end
end

local function BuildCanvas()
  local parent = canvasFrame
  local y = LAYOUT.START_Y

  local iconPath = "Interface/AddOns/" .. (AutomaticRoleCheck.AddonName or "AutomaticRoleCheck") .. "/" .. (AutomaticRoleCheck.AddonName or "AutomaticRoleCheck")

  local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", parent, "TOPLEFT", LAYOUT.LEFT_MARGIN, y + LAYOUT.TOP_ELEMENT_OFFSET)
  title:SetTextColor(1, 0.82, 0, 1)
  title:SetText(AutomaticRoleCheck.AddonName or "AutomaticRoleCheck")

  local logo = parent:CreateTexture(nil, "OVERLAY")
  logo:SetTexture(iconPath)
  logo:SetSize(LAYOUT.LOGO_SIZE, LAYOUT.LOGO_SIZE)
  logo:SetTexCoord(THEME.ICON_TEX_MIN, THEME.ICON_TEX_MAX, THEME.ICON_TEX_MIN, THEME.ICON_TEX_MAX)
  logo:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -LAYOUT.LEFT_MARGIN, y + LAYOUT.TOP_ELEMENT_OFFSET)

  y = y - LAYOUT.LOGO_SIZE

  local function AddBoxedGroup(boxLabel, items)
    local boxHeight = LAYOUT.BOX_HEADER_HEIGHT + (#items * LAYOUT.ROW_HEIGHT) + LAYOUT.BOX_PADDING_BOT + 4
    local box = CreateBox(parent, boxLabel)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", LAYOUT.BOX_LEFT, y)
    box:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -LAYOUT.BOX_RIGHT_MARGIN, y)
    box:SetHeight(boxHeight)

    local rowY = -(LAYOUT.BOX_HEADER_HEIGHT + LAYOUT.BOX_HEADER_OFFSET)
    for _, item in ipairs(items) do
      local row, cb = CreateCheckboxRow(
        box,
        item.key,
        L(item.label),
        L(item.desc)
      )
      row:SetPoint("TOPLEFT", box, "TOPLEFT", LAYOUT.CHECK_INDENT, rowY)
      row:SetPoint("TOPRIGHT", box, "TOPRIGHT", -LAYOUT.CHECK_INDENT, rowY)
      rowY = rowY - LAYOUT.ROW_HEIGHT
      checkboxFrames[item.key] = cb
    end

    y = y - boxHeight - LAYOUT.BOX_VERTICAL_GAP
    return box
  end

  do
    local rowEnabled, cbEnabled = CreateCheckboxRow(
      parent, "Enabled",
      L("panel_label_Enabled"),
      L("panel_desc_Enabled")
    )
    rowEnabled:SetPoint("TOPLEFT",  parent, "TOPLEFT",  LAYOUT.LEFT_MARGIN, y)
    rowEnabled:SetPoint("TOPRIGHT", parent, "CENTER",   0,           y)
    checkboxFrames["Enabled"] = cbEnabled

    y = y - LAYOUT.ROW_HEIGHT
  end

  y = y - 4
  local boxY = y

  enabledBox = AddBoxedGroup(L("panel_group_when_enabled"), {
    { key = "DisableWhilstAFK",        label = "panel_label_DisableWhilstAFK",        desc = "panel_desc_DisableWhilstAFK"        },
    { key = "DisableOnce",             label = "panel_label_DisableOnce",             desc = "panel_desc_DisableOnce"             },
    { key = "DisableOnceOnLogin",      label = "panel_label_DisableOnceOnLogin",      desc = "panel_desc_DisableOnceOnLogin"      },
    { key = "DisableOnceOnRoleChange", label = "panel_label_DisableOnceOnRoleChange", desc = "panel_desc_DisableOnceOnRoleChange" },
  })

  y = boxY
  disabledBox = AddBoxedGroup(L("panel_group_when_disabled"), {
    { key = "EnableOnce", label = "panel_label_EnableOnce", desc = "panel_desc_EnableOnce" },
  })

  local rowMinimap, cbMinimap = CreateCheckboxRow(
    parent, "ShowMinimapButton",
    L("panel_label_ShowMinimapButton"),
    L("panel_desc_ShowMinimapButton")
  )
  rowMinimap:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", LAYOUT.MINIMAP_ROW_OFFSET_X, LAYOUT.MINIMAP_ROW_OFFSET_Y)
  rowMinimap:SetWidth(LAYOUT.MINIMAP_ROW_WIDTH)
  checkboxFrames["ShowMinimapButton"] = cbMinimap
end

local function SyncAllCheckboxes()
  for key, cb in pairs(checkboxFrames) do
    if cb then
      cb:SetChecked(GetOptionValue(key) == true)
    end
  end
end

local function UpdateVisibility()
  local options = GetOptions()
  local isEnabled = options and options.Enabled == true
  SetPanelModeEnabled(isEnabled)
end

AutomaticRoleCheck.Panel_OnOptionsChanged = function()
  SyncAllCheckboxes()
  UpdateVisibility()
end

BuildCanvas()
SyncAllCheckboxes()
UpdateVisibility()

if SettingsPanel and SettingsPanel.SetCurrentCategory then
  hooksecurefunc(SettingsPanel, "SetCurrentCategory", function(_, category)
    if category and category:GetID() == AutomaticRoleCheck.Panel:GetID() then
      SyncAllCheckboxes()
      UpdateVisibility()
    end
  end)
end

Settings.RegisterAddOnCategory(AutomaticRoleCheck.Panel)
