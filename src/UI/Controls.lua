-- Boxes, rows with a switch, rows with a chip, and the dropdown list.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local ApplyOutline = UI.ApplyOutline
local L = ARC.Loc
local LAYOUT, THEME = UI.LAYOUT, UI.THEME
local FlatSwitch, FlatChip = UI.FlatSwitch, UI.FlatChip
local CHOICES, GetOptionValue, SetOption = UI.CHOICES, UI.GetOptionValue, UI.SetOption
local choiceButtons = UI.choiceButtons

local function CreateBox(parent, label)
  local box = CreateFrame("Frame", nil, parent)

  local bg = box:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(box)
  bg:SetColorTexture(THEME.BOX_BG[1], THEME.BOX_BG[2], THEME.BOX_BG[3], THEME.BOX_BG[4])

  local c = THEME.BOX_BORDER
  UI.AddBorder(box, c)

  if label then
    local title = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", box, "TOPLEFT", 8, -6)
    title:SetTextColor(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], THEME.ACCENT[4])
    title:SetText(label)
    box.title = title
  end

  return box
end

-- A row with a label on the left and a switch on the right.
local function CreateCheckboxRow(parent, configKey, labelText, tooltipText)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(LAYOUT.ROW_H)

  local sw = FlatSwitch(row, function(value) SetOption(configKey, value) end)
  sw.tooltip = tooltipText
  sw.tooltipTitle = labelText
  sw.tooltipOwner = row
  sw:SetPoint("RIGHT", row, "RIGHT", 0, 0)

  local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  lbl:SetPoint("LEFT", row, "LEFT", 0, 0)
  lbl:SetPoint("RIGHT", sw, "LEFT", -6, 0)
  lbl:SetJustifyH("LEFT")
  lbl:SetWordWrap(false)
  lbl:SetText(labelText)

  if tooltipText then
    row:SetScript("OnEnter", function(self)
      UI.Tip.Show(self, "RIGHT", labelText, tooltipText)
    end)
    row:SetScript("OnLeave", function() UI.Tip.Hide() end)
  end

  row:EnableMouse(true)
  row:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then sw:Click() end
  end)

  sw:SetChecked(GetOptionValue(configKey) == true)
  return row, sw
end

-- A dropdown of our own: a flat list under the chip with every choice of a setting; the current one is
-- gold. Click a choice to pick it, click anywhere else to close.
local menuFrame, menuCatcher
local function CloseMenu()
  if menuFrame then menuFrame:Hide() end
  if menuCatcher then menuCatcher:Hide() end
end

local function OpenChoiceMenu(anchor, key)
  if anchor.disabled then return end
  local choices = CHOICES[key]
  if not choices then return end
  if not menuFrame then
    menuCatcher = CreateFrame("Button", nil, UIParent)
    menuCatcher:SetFrameStrata("FULLSCREEN_DIALOG")
    menuCatcher:SetAllPoints(UIParent)
    menuCatcher:SetScript("OnClick", CloseMenu)
    menuFrame = CreateFrame("Frame", nil, UIParent)
    menuFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    menuFrame:SetFrameLevel(menuCatcher:GetFrameLevel() + 10)
    menuFrame:SetClampedToScreen(true)
    menuFrame:EnableMouse(true)
    local bg = menuFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(THEME.TIP_BG[1], THEME.TIP_BG[2], THEME.TIP_BG[3], 0.98)
    UI.AddBorder(menuFrame, THEME.ACCENT)
    menuFrame.rows = {}
  end
  local current = GetOptionValue(key)
  local ROW = 20
  local widest = 0
  for i, choice in ipairs(choices) do
    local row = menuFrame.rows[i]
    if not row then
      row = CreateFrame("Button", nil, menuFrame)
      row:SetHeight(ROW)
      row.hl = row:CreateTexture(nil, "BACKGROUND")
      row.hl:SetAllPoints()
      row.hl:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 0)
      row.dot = row:CreateTexture(nil, "ARTWORK")
      row.dot:SetSize(5, 5)
      row.dot:SetPoint("LEFT", 7, 0)
      row.dot:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 1)
      row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      row.label:SetPoint("LEFT", 18, 0)
      row:SetScript("OnEnter", function(self) self.hl:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 0.18) end)
      row:SetScript("OnLeave", function(self) self.hl:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 0) end)
      menuFrame.rows[i] = row
    end
    row.label:SetText(L(choice.label))
    local on = choice.value == current
    row.dot:SetShown(on)
    if on then row.label:SetTextColor(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3]) else row.label:SetTextColor(0.92, 0.93, 0.95) end
    row:SetScript("OnClick", function()
      CloseMenu()
      SetOption(key, choice.value)
      if key:find("^Sound") and ARC.PlayOwnSound then ARC.PlayOwnSound(choice.value) end
    end)
    widest = math.max(widest, row.label:GetStringWidth() or 0)
  end
  for i = #choices + 1, #menuFrame.rows do menuFrame.rows[i]:Hide() end
  local width = math.max(anchor:GetWidth() or 80, widest + 30)
  menuFrame:SetSize(width, #choices * ROW + 4)
  for i = 1, #choices do
    local row = menuFrame.rows[i]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 2, -2 - (i - 1) * ROW)
    row:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -2, -2 - (i - 1) * ROW)
    row:Show()
  end
  menuFrame:ClearAllPoints()
  if (anchor:GetBottom() or 0) - menuFrame:GetHeight() < 20 then
    menuFrame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 2)
  else
    menuFrame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
  end
  ApplyOutline(menuFrame)
  menuCatcher:Show()
  menuFrame:Show()
end

local function ChoiceText(key)
  local choices = CHOICES[key]
  local value = GetOptionValue(key)
  for _, c in ipairs(choices) do if c.value == value then return L(c.label) end end
  return L(choices[1].label)
end

-- A label and a chip that shows the current choice; clicking goes to the next one.
local function CreateChoiceRow(parent, item)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(LAYOUT.ROW_H)

  local btn = FlatChip(row, 118, 18)
  btn:AddArrow()
  btn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
  local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  lbl:SetPoint("LEFT", row, "LEFT", 0, 0)
  lbl:SetPoint("RIGHT", btn, "LEFT", -6, 0)
  lbl:SetJustifyH("LEFT")
  lbl:SetWordWrap(false)
  lbl:SetText(L(item.label))

  function btn:Sync() self:SetText(ChoiceText(item.key)) end
  btn:SetScript("OnClick", function(self) OpenChoiceMenu(self, item.key) end)

  local tip = L(item.desc)
  local function Show(self)
    UI.Tip.Show(self, "RIGHT", L(item.label), tip)
  end
  row:EnableMouse(true)
  row:SetScript("OnEnter", Show)
  row:SetScript("OnLeave", function() UI.Tip.Hide() end)
  btn:HookScript("OnEnter", Show)
  btn:HookScript("OnLeave", function() UI.Tip.Hide() end)

  btn:Sync()
  choiceButtons[item.key] = btn
  return row
end

UI.CloseMenu, UI.CreateBox, UI.CreateCheckboxRow, UI.OpenChoiceMenu, UI.ChoiceText, UI.CreateChoiceRow = CloseMenu, CreateBox, CreateCheckboxRow, OpenChoiceMenu, ChoiceText, CreateChoiceRow
