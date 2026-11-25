-- Toasts: messages at the top of the screen. A band with the logo and name, the text, and a bar that runs out.
-- Click to close; the bar waits while the mouse is over it. ARC.ShowToast(text, kind, options): kind "info" or "error".
-- options: title, sticky (stays until clicked), width, cells = { { key, text, extras, wide } }: a grid of keys.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local ApplyOutline = UI.ApplyOutline

local WIDTH = 290
local PAD = 10
local HEADER_H = 24
local BAR_H = 3
local GAP = 6                -- between two toasts
local TOP_OFFSET = 140       -- from the top of the screen
local MAX_TOASTS = 4
local SECONDS = { info = 5, error = 7 }
local TITLE_COLOR = { 0.91, 0.97, 1 }
local BORDER = { info = { 0.11, 0.29, 0.4 }, error = { 0.8, 0.2, 0.2 } }
local BAR = { info = THEME.ORANGE, error = { 1, 0.28, 0.28 } }
local CELL_GAP_X, CELL_GAP_Y = 12, 10    -- between the cells of a grid
local KEY_H = 18
local KEY_BG, KEY_EDGE, KEY_SHADOW = { 0.114, 0.133, 0.169 }, { 0.23, 0.26, 0.31 }, { 0.04, 0.05, 0.06 }
local CELL_TEXT = { 0.79, 0.8, 0.83 }
local OPT_BG, OPT_EDGE = { 0.075, 0.133, 0.173 }, { 0.165, 0.29, 0.36 }   -- the blue keys (what you can add)

local pool, active = {}, {}

local function Layout()
  local y = -TOP_OFFSET
  for _, toast in ipairs(active) do
    toast:ClearAllPoints()
    toast:SetPoint("TOP", UIParent, "TOP", 0, y)
    y = y - toast:GetHeight() - GAP
  end
end

local function Release(toast)
  toast:Hide()
  toast:SetScript("OnUpdate", nil)
  for i, t in ipairs(active) do
    if t == toast then table.remove(active, i) break end
  end
  pool[#pool + 1] = toast
  Layout()
end

-- A key like a key of a keyboard. Orange for a command; blue (opt) for something you can add after it.
local function MakeKey(toast, opt)
  local key = CreateFrame("Frame", nil, toast)
  key:SetHeight(KEY_H)
  local bg = key:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  local edge, text
  if opt then
    bg:SetColorTexture(OPT_BG[1], OPT_BG[2], OPT_BG[3], 1)
    edge, text = OPT_EDGE, THEME.ACCENT
  else
    bg:SetColorTexture(KEY_BG[1], KEY_BG[2], KEY_BG[3], 1)
    edge, text = KEY_EDGE, THEME.ORANGE
  end
  UI.AddBorder(key, edge)
  local shadow = key:CreateTexture(nil, "ARTWORK")   -- the thick lower edge of a key
  shadow:SetPoint("BOTTOMLEFT", 1, 1)
  shadow:SetPoint("BOTTOMRIGHT", -1, 1)
  shadow:SetHeight(2)
  shadow:SetColorTexture(KEY_SHADOW[1], KEY_SHADOW[2], KEY_SHADOW[3], 1)
  key.text = key:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  key.text:SetPoint("CENTER", 0, 1)
  key.text:SetTextColor(text[1], text[2], text[3])
  ApplyOutline(key)
  return key
end

local function SetKey(key, label)
  key.text:SetText(label)
  key:SetWidth(math.max(34, math.ceil(key.text:GetStringWidth()) + 16))
end

-- One cell of a grid: a key (and maybe blue keys after it) with its explanation under it.
local function MakeCell(toast)
  local cell = { key = MakeKey(toast, false), extras = {} }
  cell.plus = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  cell.plus:SetText("+")
  cell.plus:SetTextColor(CELL_TEXT[1], CELL_TEXT[2], CELL_TEXT[3])
  cell.desc = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  cell.desc:SetJustifyH("LEFT")
  cell.desc:SetTextColor(CELL_TEXT[1], CELL_TEXT[2], CELL_TEXT[3])
  local path, size = cell.desc:GetFont()
  if path then
    cell.desc:SetFont(path, size, "OUTLINE")
    cell.plus:SetFont(path, size, "OUTLINE")
  end
  return cell
end

local function HideCell(cell)
  cell.key:Hide()
  cell.plus:Hide()
  cell.desc:Hide()
  for _, extra in ipairs(cell.extras) do extra:Hide() end
end

-- Puts one cell at (x, y). Gives back its height.
local function PlaceCell(toast, cell, data, x, y, width)
  SetKey(cell.key, data.key)
  cell.key:ClearAllPoints()
  cell.key:SetPoint("TOPLEFT", toast, "TOPLEFT", x, y)
  cell.key:Show()
  local last = cell.key
  local extras = data.extras or {}
  cell.plus:SetShown(#extras > 0)
  if #extras > 0 then
    cell.plus:ClearAllPoints()
    cell.plus:SetPoint("LEFT", cell.key, "RIGHT", 5, 0)
    last = cell.plus
  end
  for n = 1, math.max(#extras, #cell.extras) do
    local extra = cell.extras[n]
    if not extras[n] then
      extra:Hide()
    else
      if not extra then
        extra = MakeKey(toast, true)
        cell.extras[n] = extra
      end
      SetKey(extra, extras[n])
      extra:ClearAllPoints()
      extra:SetPoint("LEFT", last, "RIGHT", n == 1 and 5 or 4, 0)
      extra:Show()
      last = extra
    end
  end
  cell.desc:SetWidth(width)
  cell.desc:SetText(data.text)
  cell.desc:ClearAllPoints()
  cell.desc:SetPoint("TOPLEFT", toast, "TOPLEFT", x, y - KEY_H - 5)
  cell.desc:Show()
  return KEY_H + 5 + math.ceil(cell.desc:GetStringHeight())
end

-- Fills the grid (two columns; a cell with wide = true takes a whole row) and gives back its height.
local function FillCells(toast, cells, width)
  toast.cells = toast.cells or {}
  local colW = math.floor((width - 2 * PAD - CELL_GAP_X) / 2)
  local y, rowH, used, started = -(HEADER_H + 11), 0, 0, false
  for i = 1, math.max(#cells, #toast.cells) do
    local data = cells[i]
    if not data then
      HideCell(toast.cells[i])
    else
      if not toast.cells[i] then toast.cells[i] = MakeCell(toast) end
      local need = data.wide and 2 or 1
      if started and used + need > 2 then
        y = y - rowH - CELL_GAP_Y
        rowH, used = 0, 0
      end
      local x = PAD + used * (colW + CELL_GAP_X)
      local h = PlaceCell(toast, toast.cells[i], data, x, y, data.wide and (width - 2 * PAD) or colW)
      rowH = math.max(rowH, h)
      used = used + need
      started = true
    end
  end
  return -y + rowH - HEADER_H - 11
end
local function Create()
  local toast = CreateFrame("Button", nil, UIParent)
  toast:SetWidth(WIDTH)
  toast:SetFrameStrata("FULLSCREEN_DIALOG")
  local bg = toast:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(THEME.TIP_BG[1], THEME.TIP_BG[2], THEME.TIP_BG[3], 0.98)
  toast.border = UI.AddBorder(toast, BORDER.info)

  local band = toast:CreateTexture(nil, "ARTWORK")
  band:SetPoint("TOPLEFT", 1, -1)
  band:SetPoint("TOPRIGHT", -1, -1)
  band:SetHeight(HEADER_H)
  band:SetColorTexture(THEME.HEADER[1], THEME.HEADER[2], THEME.HEADER[3], 1)
  local logo = toast:CreateTexture(nil, "OVERLAY")
  logo:SetSize(16, 16)
  logo:SetPoint("LEFT", band, "LEFT", 8, 0)
  logo:SetTexture(ARC.Media.Logo)
  toast.title = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  toast.title:SetPoint("LEFT", logo, "RIGHT", 6, 0)
  toast.title:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])

  -- the cross (sticky toasts only)
  toast.cross = CreateFrame("Frame", nil, toast)
  toast.cross:SetSize(12, 12)
  toast.cross:SetPoint("RIGHT", band, "RIGHT", -9, 0)
  for _, angle in ipairs({ math.pi / 4, -math.pi / 4 }) do
    local line = toast.cross:CreateTexture(nil, "OVERLAY")
    line:SetSize(11, 1.5)
    line:SetPoint("CENTER")
    line:SetRotation(angle)
    line:SetColorTexture(THEME.MUTED[1], THEME.MUTED[2], THEME.MUTED[3], 1)
  end

  toast.body = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  toast.body:SetPoint("TOPLEFT", toast, "TOPLEFT", PAD, -(HEADER_H + 9))
  toast.body:SetWidth(WIDTH - 2 * PAD)
  toast.body:SetJustifyH("LEFT")
  toast.body:SetTextColor(1, 1, 1)

  local track = toast:CreateTexture(nil, "ARTWORK")
  track:SetPoint("BOTTOMLEFT", 1, 1)
  track:SetPoint("BOTTOMRIGHT", -1, 1)
  track:SetHeight(BAR_H)
  track:SetColorTexture(0.14, 0.15, 0.17, 1)
  toast.track = track
  toast.bar = toast:CreateTexture(nil, "OVERLAY")
  toast.bar:SetPoint("BOTTOMLEFT", 1, 1)
  toast.bar:SetHeight(BAR_H)

  toast:RegisterForClicks("AnyUp")
  toast:SetScript("OnClick", Release)
  toast:SetScript("OnEnter", function(self) self.hover = true end)
  toast:SetScript("OnLeave", function(self) self.hover = false end)
  ApplyOutline(toast)
  return toast
end

ARC.ShowToast = function(text, kind, options)
  kind = BORDER[kind] and kind or "info"
  local sticky = options and options.sticky
  if #active >= MAX_TOASTS then Release(active[1]) end
  local toast = table.remove(pool) or Create()
  UI.SetBorderColor(toast.border, BORDER[kind])
  toast.title:SetText(options and options.title or ARC.AddonName)
  toast.bar:SetColorTexture(BAR[kind][1], BAR[kind][2], BAR[kind][3], 1)
  toast.bar:SetShown(not sticky)
  toast.track:SetShown(not sticky)
  toast.cross:SetShown(sticky and true or false)
  local width = options and options.width or WIDTH
  toast:SetWidth(width)
  toast.body:SetWidth(width - 2 * PAD)
  local contentH
  if options and options.cells then
    toast.body:SetText("")
    contentH = FillCells(toast, options.cells, width) + 2
  else
    for _, cell in ipairs(toast.cells or {}) do HideCell(cell) end
    toast.body:SetText(text)
    contentH = math.ceil(toast.body:GetStringHeight())
  end
  toast:SetHeight(HEADER_H + 9 + contentH + 9 + (sticky and 0 or BAR_H + 1))
  toast.hover = false
  toast.total = SECONDS[kind]
  toast.left = toast.total
  toast.barWidth = width - 2
  toast.bar:SetWidth(toast.barWidth)
  if sticky then
    toast:SetScript("OnUpdate", nil)
  else
    toast:SetScript("OnUpdate", function(self, elapsed)
      if self.hover then return end
      self.left = self.left - elapsed
      if self.left <= 0 then
        Release(self)
      else
        self.bar:SetWidth(math.max(1, self.barWidth * self.left / self.total))
      end
    end)
  end
  active[#active + 1] = toast
  toast:Show()
  Layout()
end