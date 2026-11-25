-- The table "When it is accepted": the in-combat and out-of-combat settings side by side, with a link
-- button between the two columns that makes the second column follow the first.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local L = ARC.Loc
local LAYOUT = UI.LAYOUT
local Circle, FlatSwitch, FlatChip = UI.Circle, UI.FlatSwitch, UI.FlatChip
local GetOptions, GetOptionValue, SetOption = UI.GetOptions, UI.GetOptionValue, UI.SetOption
local CreateBox, OpenChoiceMenu, ChoiceText, AddReset = UI.CreateBox, UI.OpenChoiceMenu, UI.ChoiceText, UI.AddReset
local Needed = UI.Needed
local tableCells, groups = UI.tableCells, UI.groups

-- Each row: label (locale key), kind of control, the in-combat setting (nil: only out of combat), the
-- out-of-combat setting.
local TABLE_ROWS = {
  { "row_accept",   "check",  "AcceptInCombat",    "AcceptOutOfCombat" },
  { "row_hide",     "check",  "HideInCombat",      "HideOutOfCombat" },
  { "row_sound_on", "check",  "PlaySoundInCombat", "PlaySoundOutOfCombat" },
  { "row_sound",    "choice", "Sound",             "SoundOutOfCombat" },
  { "row_delay",    "choice", nil,                 "AcceptDelay" },
}
-- the tooltip texts of each row: { in combat, out of combat, extra line } (locale keys)
local ROW_TIPS = {
  row_accept = { "tip_accept_in", "tip_accept_out", "tip_accept_off" },
  row_hide = { "tip_hide_in", "tip_hide_out" },
  row_sound_on = { "tip_sound_on_in", "tip_sound_on_out" },
  row_sound = { "tip_sound", "tip_sound" },
  row_delay = { nil, "tip_delay_out" },
}

local COL_W = 96        -- width of a column
local CELL_W = COL_W - 10  -- a chip in a column
local ROW_H = 22        -- height of a row
local HEAD_H = 18       -- height of the column headings
local SEG_H = 8         -- a little air between the title and the column headings
local COL_GAP = 48      -- room between the two columns, for the link in the middle
local KNOT_Y = LAYOUT.BOX_HEADER + SEG_H + 16   -- where the link sits (from the top of the box)

-- Where the middle of a column is, counted from the right edge of the box.
local function ColumnX(col)
  -- the right column ends exactly where the controls in the other boxes end
  local right = -LAYOUT.BOX_INDENT - CELL_W / 2
  if col == 2 then return right end
  return right - COL_W - COL_GAP
end
local MID_X = (ColumnX(1) + ColumnX(2)) / 2

---------------------------------------------------------------- the link between the columns
-- An icon between the two column headings: a round knob with two chain links. Linked: blue, the links
-- hooked into each other, and a bar joins the two columns. Not linked: grey, the links apart.
local function BuildLink(box)
  local knot = CreateFrame("Button", nil, box)
  knot:SetSize(18, 18)
  knot.ring = Circle(knot, 18, "BACKGROUND")
  knot.ring:SetPoint("CENTER")
  knot.fill = Circle(knot, 16, "ARTWORK")
  knot.fill:SetPoint("CENTER")
  knot.icon = knot:CreateTexture(nil, "OVERLAY")
  knot.icon:SetSize(15, 15)
  knot.icon:SetPoint("CENTER")
  knot:SetScript("OnClick", function()
    if GetOptions() then SetOption("LinkCombat", GetOptionValue("LinkCombat") ~= true) end
  end)
  knot:SetScript("OnEnter", function(self)
    UI.Tip.Show(self, "RIGHT", L(GetOptionValue("LinkCombat") == true and "link_on" or "link_off"), L("link_tip"))
  end)
  knot:SetScript("OnLeave", function() UI.Tip.Hide() end)
  knot:SetPoint("CENTER", box, "TOPRIGHT", MID_X, -KNOT_Y)

  local function Paint(linked)
    local c = linked and THEME.ACCENT or THEME.GREY
    knot.ring:SetColorTexture(0, 0, 0, 0)
    knot.fill:SetColorTexture(THEME.DISC[1], THEME.DISC[2], THEME.DISC[3], 1)   -- a dark disc: it hides the line behind the icon
    knot.icon:SetTexture(linked and ARC.Media.Linked or ARC.Media.Unlinked)
    knot.icon:SetVertexColor(c[1], c[2], c[3], 1)
  end
  return knot, Paint
end

---------------------------------------------------------------- headings and lines
-- The column headings, a thin line under them, and the lines between the two columns.
local function BuildHeader(box)
  for col, key in ipairs({ "panel_col_in", "panel_col_out" }) do
    local fs = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("TOP", box, "TOPRIGHT", ColumnX(col), -(LAYOUT.BOX_HEADER + SEG_H + 2))
    fs:SetTextColor(THEME.MUTED[1], THEME.MUTED[2], THEME.MUTED[3])
    fs:SetText(L(key))
  end
  local headLine = box:CreateTexture(nil, "ARTWORK")
  headLine:SetColorTexture(1, 1, 1, 0.1)
  UI.OnePixel(headLine, true)
  local lineY = -(LAYOUT.BOX_HEADER + SEG_H + HEAD_H)
  headLine:SetPoint("TOPLEFT", box, "TOPLEFT", LAYOUT.BOX_INDENT - 4, lineY)
  headLine:SetPoint("TOPRIGHT", box, "TOPRIGHT", -(LAYOUT.BOX_INDENT - 4), lineY)
  -- a faint line between the columns (not while linked) ...
  local divider = box:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(1, 1, 1, 0.06)
  UI.OnePixel(divider, false)
  -- ... and a bar while linked, which joins them
  local joinBar = box:CreateTexture(nil, "ARTWORK")
  joinBar:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 0.75)
  joinBar:SetWidth(3)
  return divider, joinBar
end

---------------------------------------------------------------- one row
-- One tooltip for the whole row: a short line for each side (in combat, out of combat).
local function ShowRowTip(owner, rowKey)
  local tips = ROW_TIPS[rowKey]
  local paragraphs = {}
  if tips then
    local inText, outText = tips[1] and L(tips[1]), tips[2] and L(tips[2])
    if inText and outText and inText == outText then
      paragraphs[#paragraphs + 1] = inText
    else
      if inText then paragraphs[#paragraphs + 1] = ARC.ORANGE .. L("tip_label_in") .. "|r " .. inText end
      if outText then paragraphs[#paragraphs + 1] = ARC.ORANGE .. L("tip_label_out") .. "|r " .. outText end
    end
    if tips[3] then paragraphs[#paragraphs + 1] = L(tips[3]) end
  end
  UI.Tip.Show(owner, "RIGHT", L(rowKey), unpack(paragraphs))
end

-- A switch or a chip for one setting. It is kept in tableCells so it follows the setting.
local function MakeCell(box, kind, key, showTip)
  local cell = {}
  if kind == "check" then
    local sw = FlatSwitch(box, function(value) SetOption(key, value) end)
    sw.tooltipFn = showTip
    cell.frame = sw
    cell.sync = function() sw:SetChecked(GetOptionValue(key) == true) end
    cell.enable = function(on) if on then sw:Enable() else sw:Disable() end end
  else
    local chip = FlatChip(box, CELL_W, 18)
    chip:AddArrow()
    chip:SetScript("OnClick", function(self) OpenChoiceMenu(self, key) end)
    chip:HookScript("OnEnter", showTip)
    chip:HookScript("OnLeave", function() UI.Tip.Hide() end)
    cell.frame = chip
    cell.sync = function() chip:SetText(ChoiceText(key)) end
    cell.enable = function(on) if on then chip:Enable() else chip:Disable() end end
  end
  cell.sync()
  tableCells[#tableCells + 1] = cell
  return cell
end

local function BuildRow(box, def, index)
  local r = { inKey = def[3], outKey = def[4] }
  -- every second row has a faint band, so the eye can follow a row across
  r.band = box:CreateTexture(nil, "BACKGROUND")
  r.band:SetColorTexture(1, 1, 1, index % 2 == 1 and 0.035 or 0)
  r.label = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.label:SetJustifyH("LEFT")
  r.label:SetWordWrap(false)
  r.label:SetText(L(def[1]))
  r.hit = CreateFrame("Frame", nil, box)
  r.hit:EnableMouse(true)
  local function ShowTip() ShowRowTip(r.hit, def[1]) end
  r.hit:SetScript("OnEnter", ShowTip)
  r.hit:SetScript("OnLeave", function(self) UI.Tip.Hide(self) end)
  -- A setting that only exists on one side has nothing in the other column.
  if def[3] then r.inCell = MakeCell(box, def[2], def[3], ShowTip) end
  r.outCell = MakeCell(box, def[2], def[4], ShowTip)
  -- the row's tooltip frame lies behind the switches and chips, so they get the clicks
  local level = box:GetFrameLevel()
  r.hit:SetFrameLevel(level + 1)
  if r.inCell then r.inCell.frame:SetFrameLevel(level + 3) end
  r.outCell.frame:SetFrameLevel(level + 3)
  return r
end

-- Shows or hides a row and puts it at height `y`.
local function PlaceRow(box, r, y, linked, linkedOut)
  r.band:ClearAllPoints()
  r.band:SetPoint("TOPLEFT", box, "TOPLEFT", LAYOUT.BOX_INDENT - 4, y)
  r.band:SetPoint("TOPRIGHT", box, "TOPRIGHT", -(LAYOUT.BOX_INDENT - 4), y)
  r.band:SetHeight(ROW_H)
  r.label:ClearAllPoints()
  r.label:SetPoint("TOPLEFT", box, "TOPLEFT", LAYOUT.BOX_INDENT, y - 6)
  r.label:SetWidth(math.max(112, (box:GetWidth() or 0) - (COL_W * 2 + COL_GAP + 56)))
  r.hit:ClearAllPoints()
  r.hit:SetPoint("TOPLEFT", box, "TOPLEFT", 6, y - 1)
  r.hit:SetPoint("TOPRIGHT", box, "TOPRIGHT", -6, y - 1)
  r.hit:SetHeight(ROW_H - 2)
  if r.inCell then
    r.inCell.frame:ClearAllPoints()
    r.inCell.frame:SetPoint("TOP", box, "TOPRIGHT", ColumnX(1), y - 3)
    r.inCell.enable(true)
  end
  r.outCell.frame:ClearAllPoints()
  r.outCell.frame:SetPoint("TOP", box, "TOPRIGHT", ColumnX(2), y - 3)
  -- Linked: the out-of-combat cells follow the in-combat ones and can't be changed here.
  r.outCell.enable(not (linked and linkedOut[r.outKey]))
end

---------------------------------------------------------------- the whole table
local function AddTableGroup(parent)
  local box = CreateBox(parent, L("panel_group_accepted"))
  local g = { box = box, column = "tbl", rows = {} }
  local linkedOut = {}
  for _, outKey in pairs(ARC.LinkedKeys or {}) do linkedOut[outKey] = true end

  -- Reset for the whole table (the link too)
  local tableKeys = { "LinkCombat" }
  for _, def in ipairs(TABLE_ROWS) do
    if def[3] then tableKeys[#tableKeys + 1] = def[3] end
    tableKeys[#tableKeys + 1] = def[4]
  end
  AddReset(box, tableKeys)

  local knot, PaintLink = BuildLink(box)
  local divider, joinBar = BuildHeader(box)
  local rows = {}
  for index, def in ipairs(TABLE_ROWS) do rows[index] = BuildRow(box, def, index) end

  -- Puts the rows in place (a row with nothing to show takes no room); gives back the height of the box.
  g.tableLayout = function()
    local linked = GetOptionValue("LinkCombat") == true
    PaintLink(linked)
    local top = -(LAYOUT.BOX_HEADER + SEG_H + HEAD_H + 2)
    local y, count = top, 0
    for _, r in ipairs(rows) do
      local inShown = r.inKey and Needed(r.inKey)
      local outShown = Needed(r.outKey)
      local visible = (inShown or outShown) and true or false
      r.label:SetShown(visible)
      r.hit:SetShown(visible)
      r.band:SetShown(visible)
      if r.inCell then r.inCell.frame:SetShown(inShown and true or false) end
      r.outCell.frame:SetShown(outShown and true or false)
      if visible then
        PlaceRow(box, r, y, linked, linkedOut)
        y = y - ROW_H
        count = count + 1
      end
    end
    -- the link sits in the middle of the table, on the line between the columns
    knot:ClearAllPoints()
    knot:SetPoint("CENTER", box, "TOPRIGHT", MID_X, -KNOT_Y)
    local barHeight = math.max(1, count * ROW_H - 4)
    for _, bar in ipairs({ divider, joinBar }) do
      bar:ClearAllPoints()
      bar:SetPoint("TOP", box, "TOPRIGHT", MID_X, top - 2)
      bar:SetHeight(barHeight)
    end
    divider:SetShown(not linked)
    joinBar:SetShown(linked)
    return LAYOUT.BOX_HEADER + SEG_H + HEAD_H + 2 + count * ROW_H + LAYOUT.BOX_BOTTOM + 2
  end

  groups[#groups + 1] = g
  return box
end

UI.AddTableGroup = AddTableGroup
