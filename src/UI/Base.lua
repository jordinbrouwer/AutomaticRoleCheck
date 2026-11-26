-- The look and the shared parts of the window. Every UI file takes its tools from the UI table.
AutomaticRoleCheck = AutomaticRoleCheck or {}
local UI = {}
AutomaticRoleCheck.UI = UI

-- Values that change while the window lives (set in one file, read in another).
-- layoutParent, layoutTop, scrollUpdate, fitWindow, placeStrip
UI.state = {}

-- The parts of the window, filled when it is built, and used to keep them in step with the settings.
UI.checkboxFrames = {}   -- setting -> switch
UI.choiceButtons = {}     -- setting -> chip
UI.roleButtons = {}
UI.tableCells = {}        -- the cells of the "When it is accepted" table: { sync = function }
UI.groups = {}           -- { box, column, kind, rows = { { row, key }, ... } }

-- The sizes (pixels). The same names as in GroupHighlight and LootAnchor.
local LAYOUT = {
  OUTER = 10,          -- between the window edge and the boxes
  TOP = 10,            -- between the header and the first box
  BOX_INDENT = 8,      -- the same as the title: what is in a box lines up with its title
  ROW_H = 20,          -- a row with a switch
  BOX_BOTTOM = 4,      -- between the last row and the bottom edge
  BOX_HEADER = 16,     -- the title row of a box
  BOX_HEADER_OFFSET = 2,
  BOX_GAP = 4,         -- between two boxes under each other
  FOOTER = 24,         -- the band with the hint at the bottom
}

-- The colours, each named for what it is used for (so a colour is changed in one place).
-- The same names as in GroupHighlight and LootAnchor, in AutomaticRoleCheck's own colours (blue and orange).
local THEME = {
  ACCENT = { 0.0, 0.67, 0.94, 1 },          -- the blue of the logo
  ORANGE = { 0.95, 0.4, 0.15, 1 },          -- the orange of the logo
  HEADER = { 0.043, 0.141, 0.2, 1 },        -- the dark blue band at the top of the window
  BORDER = { 0.28, 0.3, 0.36, 1 },          -- the edge of switches and chips
  BOX_BG = { 0.1, 0.1, 0.1, 0.6 },          -- the boxes round the sections
  BOX_BORDER = { 0.4, 0.4, 0.4, 0.8 },
  BUTTON = { 0.09, 0.1, 0.13, 1 },          -- the background of a chip
  TRACK = { 0.2, 0.21, 0.26, 1 },           -- a switch that is off
  MUTED = { 0.62, 0.64, 0.7, 1 },           -- quiet text, icons at rest
  BRIGHT = { 0.95, 0.96, 0.98, 1 },         -- the same icons under the mouse
  GREY = { 0.5, 0.52, 0.58, 1 },            -- something that is off or not linked
  THUMB = { 0.55, 0.57, 0.63, 1 },          -- the handle of the scroll bar
  THUMB_HOVER = { 0.75, 0.77, 0.83, 1 },
  TIP_BG = { 0.06, 0.065, 0.08, 1 },        -- the background of tooltips and the dropdown list
  DISC = { 0.07, 0.075, 0.09, 1 },          -- the dark disc behind the link icon
}
-- The size of the window (in pixels). It can be dragged between the min and max; the height never goes
-- above what the content needs.
local WINDOW = {
  WIDTH = 780,        -- the width that fits the top line, and the table and the minimap box side by side
  MIN_W = 440,
  MAX_W = 780,        -- the window cannot be made wider than its default width
  MIN_H = 220,
  MAX_H = 700,        -- when the window opens for the first time (and at most 88% of the screen)
}

UI.LAYOUT, UI.THEME, UI.WINDOW = LAYOUT, THEME, WINDOW

-- Makes a line exactly one screen pixel thick, whatever the UI scale (a plain 1 can render as 0, 1 or 2
-- pixels, so lines looked uneven and corners did not meet).
function UI.OnePixel(line, horizontal)
  line:SetTexelSnappingBias(0)
  line:SetSnapToPixelGrid(false)
  if PixelUtil then
    if horizontal then PixelUtil.SetHeight(line, 1, 1) else PixelUtil.SetWidth(line, 1, 1) end
  else
    if horizontal then line:SetHeight(1) else line:SetWidth(1) end
  end
end

-- A thin border of one-pixel lines: top and bottom full width, the sides in between (no doubled corners).
-- color = { r, g, b, a }; alpha replaces its alpha when given. Gives back the lines (for UI.SetBorderColor).
function UI.AddBorder(frame, color, alpha)
  local top, bottom, left, right = frame:CreateTexture(nil, "BORDER"), frame:CreateTexture(nil, "BORDER"),
    frame:CreateTexture(nil, "BORDER"), frame:CreateTexture(nil, "BORDER")
  top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);              top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0);     bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  left:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0);            left:SetPoint("BOTTOMLEFT", bottom, "TOPLEFT", 0, 0)
  right:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT", 0, 0);         right:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", 0, 0)
  UI.OnePixel(top, true); UI.OnePixel(bottom, true); UI.OnePixel(left, false); UI.OnePixel(right, false)
  local lines = { top, bottom, left, right }
  UI.SetBorderColor(lines, color, alpha)
  return lines
end

function UI.SetBorderColor(lines, color, alpha)
  for _, line in ipairs(lines) do line:SetColorTexture(color[1], color[2], color[3], alpha or color[4] or 1) end
end
