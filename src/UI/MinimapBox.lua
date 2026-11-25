-- The box for the minimap button: three switches (show, colour, lock) and a grid of clicks.
-- Wide box: the switches on the left, the grid on the right. Narrow box: the grid under the switches.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local L = ARC.Loc
local LAYOUT = UI.LAYOUT
local FlatSwitch, FlatChip = UI.FlatSwitch, UI.FlatChip
local CLICK_SHORT, CLICK_MODS, CLICK_BUTTONS, CLICK_KEYS = UI.CLICK_SHORT, UI.CLICK_MODS, UI.CLICK_BUTTONS, UI.CLICK_KEYS
local GetOptionValue, SetOption = UI.GetOptionValue, UI.SetOption
local CreateBox, OpenChoiceMenu, ChoiceText, AddReset = UI.CreateBox, UI.OpenChoiceMenu, UI.ChoiceText, UI.AddReset
local Needed = UI.Needed
local checkboxFrames, tableCells, groups = UI.checkboxFrames, UI.tableCells, UI.groups

local SWITCH_COL_W = 100   -- width of the column with the switches
local SWITCH_ROW_H = 20
local GRID_ROW_H, GRID_HEAD_H = 20, 13
local GRID_LABEL_W = 40    -- width of the labels ("Left", "Right") in front of the chips
local COMPACT_BELOW = 330  -- a box narrower than this uses the narrow layout

-- Each switch: setting, label and tooltip text (locale keys).
local SWITCHES = {
  { "ShowMinimapButton", "mini_show_long", "panel_desc_ShowMinimapButton" },
  { "MinimapGlow", "mini_glow", "panel_desc_MinimapGlow" },
  { "MinimapLocked", "mini_lock", "panel_desc_MinimapLocked" },
}

---------------------------------------------------------------- the switches
-- A row with a label and a switch; the whole row shows the tooltip and can be clicked.
local function BuildSwitches(box)
  local switches = {}
  for _, def in ipairs(SWITCHES) do
    local key, label, desc = def[1], L(def[2]), L(def[3])
    local holder = CreateFrame("Frame", nil, box)
    holder:SetSize(SWITCH_COL_W, SWITCH_ROW_H)
    local sw = FlatSwitch(holder, function(value) SetOption(key, value) end)
    sw.tooltip, sw.tooltipTitle, sw.tooltipOwner = desc, label, holder
    sw:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", 0, 0)
    text:SetText(label)
    holder:EnableMouse(true)
    holder:SetScript("OnMouseUp", function() sw:Click() end)
    holder:HookScript("OnEnter", function(self) UI.Tip.Show(self, "RIGHT", label, desc) end)
    holder:HookScript("OnLeave", function() UI.Tip.Hide() end)
    checkboxFrames[key] = sw
    switches[#switches + 1] = { holder = holder, key = key }
  end
  return switches
end

-- Shows the switches that are needed, one under the other. Gives back how many are shown.
local function PlaceSwitches(box, switches, top)
  local shown = 0
  for _, s in ipairs(switches) do
    local visible = Needed(s.key)
    s.holder:SetShown(visible)
    if visible then
      s.holder:ClearAllPoints()
      s.holder:SetPoint("TOPLEFT", box, "TOPLEFT", LAYOUT.BOX_INDENT, top - shown * SWITCH_ROW_H)
      shown = shown + 1
    end
  end
  return shown
end

---------------------------------------------------------------- the grid of clicks
-- Rows: Left, Right. Columns: plain, with Shift. Each cell is a chip that opens the list of actions.
local function BuildGrid(box)
  local grid = { heads = {}, labels = {}, chips = {} }
  grid.line = box:CreateTexture(nil, "ARTWORK")
  grid.line:SetColorTexture(1, 1, 1, 0.1)
  for col, text in ipairs({ "grid_plain", "grid_shift" }) do
    local fs = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetJustifyH("CENTER")
    fs:SetTextColor(THEME.MUTED[1], THEME.MUTED[2], THEME.MUTED[3])
    fs:SetText(L(text))
    grid.heads[col] = fs
  end
  for rowIndex, name in ipairs(CLICK_BUTTONS) do
    local label = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetText(L("grid_" .. name))
    grid.labels[rowIndex] = label
    grid.chips[rowIndex] = {}
    for col, mod in ipairs(CLICK_MODS) do
      local key = "Minimap" .. mod .. name .. "Click"
      local chip = FlatChip(box, 80, 18)
      chip:SetScript("OnClick", function(self) OpenChoiceMenu(self, key) end)
      chip:AddArrow()
      chip:HookScript("OnEnter", function(self)
        local title = (mod ~= "" and (mod .. " + ") or "") .. name .. "-click"
        UI.Tip.Show(self, "RIGHT", title, ARC.ORANGE .. ChoiceText(key) .. "|r", L("grid_tip"))
      end)
      chip:HookScript("OnLeave", function() UI.Tip.Hide() end)
      tableCells[#tableCells + 1] = {
        sync = function() chip:SetText(L(CLICK_SHORT[GetOptionValue(key)] or "short_none")) end,
      }
      tableCells[#tableCells].sync()
      grid.chips[rowIndex][col] = chip
    end
  end
  return grid
end

local function ShowGrid(grid, show)
  grid.line:SetShown(show)
  for _, fs in ipairs(grid.heads) do fs:SetShown(show) end
  for rowIndex = 1, #CLICK_BUTTONS do
    grid.labels[rowIndex]:SetShown(show)
    for col = 1, #CLICK_MODS do grid.chips[rowIndex][col]:SetShown(show) end
  end
end

-- Puts the grid in place: next to the switches (wide box) or under them (narrow box).
-- Gives back how much taller the box gets (only the narrow box grows).
local function PlaceGrid(box, grid, top, shownSwitches, compact)
  local x0, gridTop, colW, extra
  grid.line:ClearAllPoints()
  if compact then
    x0 = LAYOUT.BOX_INDENT
    gridTop = top - shownSwitches * SWITCH_ROW_H - 8
    colW = math.max(60, math.floor(((box:GetWidth() or 240) - x0 - GRID_LABEL_W - 8) / 2))
    grid.line:SetWidth(0)
    UI.OnePixel(grid.line, true)
    grid.line:SetPoint("TOPLEFT", box, "TOPLEFT", 8, gridTop + 4)
    grid.line:SetPoint("TOPRIGHT", box, "TOPRIGHT", -8, gridTop + 4)
    extra = 8 + GRID_HEAD_H + 2 + #CLICK_BUTTONS * GRID_ROW_H
  else
    local lineX = LAYOUT.BOX_INDENT + SWITCH_COL_W + 10   -- the line between the columns
    x0 = lineX + 10                                         -- where the grid starts
    gridTop = top
    colW = math.max(60, math.floor(((box:GetWidth() or 340) - x0 - GRID_LABEL_W - 8) / 2))
    grid.line:SetHeight(0)
    UI.OnePixel(grid.line, false)
    grid.line:SetPoint("TOPLEFT", box, "TOPLEFT", lineX, top - 2)
    grid.line:SetPoint("BOTTOMLEFT", box, "TOPLEFT", lineX, top - shownSwitches * SWITCH_ROW_H + 2)
    extra = 0
  end
  for col, fs in ipairs(grid.heads) do
    fs:SetWidth(colW)
    fs:ClearAllPoints()
    fs:SetPoint("TOPLEFT", box, "TOPLEFT", x0 + GRID_LABEL_W + (col - 1) * colW, gridTop - 3)
  end
  for rowIndex = 1, #CLICK_BUTTONS do
    local rowY = gridTop - GRID_HEAD_H - 2 - (rowIndex - 1) * GRID_ROW_H
    grid.labels[rowIndex]:ClearAllPoints()
    grid.labels[rowIndex]:SetPoint("TOPLEFT", box, "TOPLEFT", x0, rowY - 5)
    for col = 1, #CLICK_MODS do
      local chip = grid.chips[rowIndex][col]
      chip:SetWidth(colW - 4)
      chip:ClearAllPoints()
      chip:SetPoint("TOPLEFT", box, "TOPLEFT", x0 + GRID_LABEL_W + (col - 1) * colW + 2, rowY - 2)
    end
  end
  return extra
end

---------------------------------------------------------------- the whole box
local function AddMinimapGroup(parent)
  local box = CreateBox(parent, L("panel_group_minimap"))
  local g = { box = box, column = "map", rows = {} }
  local keys = { "MinimapButtonAngle", "ShowMinimapButton", "MinimapGlow", "MinimapLocked" }
  for _, key in ipairs(CLICK_KEYS) do keys[#keys + 1] = key end
  AddReset(box, keys)

  local switches = BuildSwitches(box)
  local grid = BuildGrid(box)

  -- Puts everything in place; gives back the height of the box.
  g.tableLayout = function()
    local top = -(LAYOUT.BOX_HEADER + 4)
    local shown = PlaceSwitches(box, switches, top)
    local showGrid = GetOptionValue("ShowMinimapButton") == true
    local height = LAYOUT.BOX_HEADER + 4 + shown * SWITCH_ROW_H + LAYOUT.BOX_BOTTOM
    ShowGrid(grid, showGrid)
    if showGrid then
      height = height + PlaceGrid(box, grid, top, shown, (box:GetWidth() or 340) < COMPACT_BELOW)
    end
    return height
  end

  groups[#groups + 1] = g
  return box
end

UI.AddMinimapGroup = AddMinimapGroup
