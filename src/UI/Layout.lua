-- Which settings are shown, and where every box goes (a flow layout that follows the width).
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local S = UI.state
local LAYOUT = UI.LAYOUT
local GetOptions, GetOptionValue = UI.GetOptions, UI.GetOptionValue
local groups = UI.groups

-- Some settings only matter while another one is on; they are hidden while it is off.
local REQUIRES = {
  HideInCombat = "AcceptInCombat",
  PlaySoundInCombat = "AcceptInCombat",
  Sound = "PlaySoundInCombat",
  HideOutOfCombat = "AcceptOutOfCombat",
  PlaySoundOutOfCombat = "AcceptOutOfCombat",
  AcceptDelay = "AcceptOutOfCombat",
  SoundOutOfCombat = "PlaySoundOutOfCombat",
  -- the other minimap settings only matter while the button is shown
  MinimapGlow = "ShowMinimapButton",
  MinimapLocked = "ShowMinimapButton",
}

local function Needed(key)
  local parent = REQUIRES[key]
  if not parent then return true end
  return GetOptionValue(parent) == true and Needed(parent)
end


-- Puts every box and row in place (hidden rows take no room; boxes follow each other).
local function Relayout()
  if not S.layoutParent then return end
  local options = GetOptions()
  local enabled = options ~= nil and options.Enabled == true
  local GAP = 8
  local avail = math.floor(math.max(300, (S.layoutParent:GetWidth() or 760) - LAYOUT.OUTER - LAYOUT.OUTER))
  -- the top strip may need two lines in a narrow window; it says where the boxes start
  local top0 = S.placeStrip and S.placeStrip(avail) or S.layoutTop

  -- Two sections, laid out like text: as many boxes side by side as fit. Section 1: the three option boxes.
  -- Section 2: the table and the minimap box (narrow: the minimap box joins section 1, the table gets its own line).
  local wide = avail >= 390 + GAP + 340
  local SECTION_OF = { left = 1, c1 = 1, c2 = 1, c3 = 1, tbl = 2, right = 2, map = wide and 2 or 1 }
  local sections = { {}, {} }
  local shown = {}
  for _, g in ipairs(groups) do
    local show = (g.kind == "disabled") and not enabled or (g.kind ~= "disabled" and enabled)
    if show and g.cond and not g.cond() then show = false end
    g.box:SetShown(show)
    if show then
      shown[#shown + 1] = g
      local list = sections[SECTION_OF[g.column] or 1]
      list[#list + 1] = g
    end
  end
  for si, list in ipairs(sections) do
    local n = #list
    if n > 0 then
      local cols
      if si == 1 then
        local minW = wide and 190 or 240
        cols = math.max(1, math.min(n, math.floor((avail + GAP) / (minW + GAP))))
      else
        cols = (n >= 2 and wide) and 2 or 1
      end
      for i, g in ipairs(list) do
        local c = (i - 1) % cols
        g.sec, g.line = si, math.floor((i - 1) / cols)
        local w, x
        if si == 2 and cols == 2 then
          local wTable = math.floor((avail - GAP) * 1.2 / 2.2)
          if c == 0 then w, x = wTable, 0 else w, x = avail - wTable - GAP, wTable + GAP end
        else
          w = math.floor((avail - (cols - 1) * GAP) / cols)
          x = c * (w + GAP)
        end
        g.x = x
        g.box:SetWidth(w)
      end
    end
  end
  -- heights (the table needs its width first)
  local lineHeight, lineEqual = {}, {}
  for _, g in ipairs(shown) do
    local height
    if g.tableLayout then
      height = g.tableLayout()
    else
      local rowY, count = -(LAYOUT.BOX_HEADER + LAYOUT.BOX_HEADER_OFFSET), 0
      for _, entry in ipairs(g.rows) do
        local visible = Needed(entry.key)
        entry.row:SetShown(visible)
        if visible then
          entry.row:ClearAllPoints()
          entry.row:SetPoint("TOPLEFT", g.box, "TOPLEFT", LAYOUT.BOX_INDENT, rowY)
          entry.row:SetPoint("TOPRIGHT", g.box, "TOPRIGHT", -LAYOUT.BOX_INDENT, rowY)
          rowY = rowY - LAYOUT.ROW_H
          count = count + 1
        end
      end
      height = LAYOUT.BOX_HEADER + count * LAYOUT.ROW_H + LAYOUT.BOX_BOTTOM + 4
    end
    g.h = height
    local key = g.sec * 100 + g.line
    lineHeight[key] = math.max(lineHeight[key] or 0, height)
    if g.column ~= "map" and g.column ~= "tbl" then lineEqual[key] = math.max(lineEqual[key] or 0, height) end
  end
  -- place the lines under each other; the boxes of section 1 on a line are equally tall
  local y = top0
  for si = 1, 2 do
    local line = 0
    while lineHeight[si * 100 + line] do
      local h = lineHeight[si * 100 + line]
      for _, g in ipairs(sections[si]) do
        if g.line == line then
          g.box:SetHeight((si == 1 and g.column ~= "map") and (lineEqual[si * 100 + line] or g.h) or g.h)
          g.box:ClearAllPoints()
          g.box:SetPoint("TOPLEFT", S.layoutParent, "TOPLEFT", LAYOUT.OUTER + g.x, y)
        end
      end
      y = y - h - LAYOUT.BOX_GAP
      line = line + 1
    end
  end
  local endY = y
  S.layoutParent:SetHeight(-endY + 2)
  -- the window is as tall as its content (up to the height of the screen)
  if S.fitWindow then S.fitWindow(-endY + 2) end
  -- The content height changed: the scroll bar follows on the next frame.
  if S.scrollUpdate then C_Timer.After(0, S.scrollUpdate) end
end

UI.Needed, UI.Relayout = Needed, Relayout
