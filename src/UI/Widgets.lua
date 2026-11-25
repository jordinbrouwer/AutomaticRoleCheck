-- The small flat parts: edges, a round dot, an on/off switch and a chip.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME

-- A filled circle (a texture with a round mask).
local function Circle(parent, size, layer)
  local t = parent:CreateTexture(nil, layer or "ARTWORK")
  t:SetSize(size, size)
  local m = parent:CreateMaskTexture()
  m:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  m:SetAllPoints(t)
  t:AddMaskTexture(m)
  t:SetColorTexture(1, 1, 1, 1)
  return t
end

-- A small on/off switch (a pill with a knob). onChange(value) runs when it is clicked.
local function FlatSwitch(parent, onChange)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(26, 14)
  b.track = b:CreateTexture(nil, "BACKGROUND")
  b.track:SetAllPoints()
  b.knob = b:CreateTexture(nil, "ARTWORK")
  b.knob:SetSize(10, 10)
  b.on, b.disabled = false, false
  function b:Paint(hover)
    local c = self.on and THEME.ACCENT or THEME.TRACK
    local lift = hover and not self.disabled and 0.08 or 0
    self.track:SetColorTexture(math.min(1, c[1] + lift), math.min(1, c[2] + lift), math.min(1, c[3] + lift), 1)
    self.knob:ClearAllPoints()
    self.knob:SetPoint(self.on and "RIGHT" or "LEFT", self, self.on and "RIGHT" or "LEFT", self.on and -2 or 2, 0)
    if self.on then self.knob:SetColorTexture(0.08, 0.08, 0.1, 1) else self.knob:SetColorTexture(0.72, 0.74, 0.8, 1) end
    self:SetAlpha(self.disabled and 0.4 or 1)
  end
  function b:SetChecked(v) self.on = v and true or false self:Paint() end
  function b:GetChecked() return self.on end
  function b:Enable() self.disabled = false self:Paint() end
  function b:Disable() self.disabled = true self:Paint() end
  b:SetScript("OnClick", function(self)
    if self.disabled then return end
    self.on = not self.on
    self:Paint(true)
    if onChange then onChange(self.on) end
  end)
  -- the switch catches the mouse itself, so it shows the tooltip (b.tooltip) too
  b:SetScript("OnEnter", function(self)
    self:Paint(true)
    if self.tooltipFn then
      self.tooltipFn(self)
    elseif self.tooltip then
      -- the tooltip hangs on the row, so it does not jump when the mouse moves onto the switch
      UI.Tip.Show(self.tooltipOwner or self, "RIGHT", self.tooltipTitle, self.tooltip)
    end
  end)
  b:SetScript("OnLeave", function(self)
    self:Paint(false)
    UI.Tip.Hide(self.tooltipOwner or self)
  end)
  b:Paint()
  return b
end

-- A flat button with a text; gold edge when the mouse is over it.
local function FlatChip(parent, width, height)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(width, height)
  b.bg = b:CreateTexture(nil, "BACKGROUND")
  b.bg:SetAllPoints()
  b.bg:SetColorTexture(THEME.BUTTON[1], THEME.BUTTON[2], THEME.BUTTON[3], 1)
  local border = UI.AddBorder(b, THEME.BORDER)
  b.label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  b.label:SetPoint("CENTER")
  b.disabled = false
  function b:SetText(text) self.label:SetText(text) end
  function b:Enable() self.disabled = false self:SetAlpha(1) end
  function b:Disable() self.disabled = true self:SetAlpha(0.4) end
  -- A small "v" at the right end: the chip opens a list of choices.
  function b:AddArrow()
    for _, dx in ipairs({ -1.8, 1.8 }) do
      local t = self:CreateTexture(nil, "OVERLAY")
      t:SetSize(5, 1.5)
      t:SetPoint("RIGHT", self, "RIGHT", -8 - (dx > 0 and 0 or 3.6), 0)
      t:SetRotation(math.rad(dx > 0 and 45 or -45))
      t:SetColorTexture(THEME.MUTED[1], THEME.MUTED[2], THEME.MUTED[3], 1)
    end
    -- the text keeps clear of the arrow: it fills the chip up to the arrow and shrinks to fit
    self.label:ClearAllPoints()
    self.label:SetPoint("LEFT", self, "LEFT", 6, 0)
    self.label:SetPoint("RIGHT", self, "RIGHT", -20, 0)
    self.label:SetJustifyH("CENTER")
    self.label:SetWordWrap(false)
  end
  b:SetScript("OnEnter", function(self)
    if not self.disabled then UI.SetBorderColor(border, THEME.ACCENT) end
  end)
  b:SetScript("OnLeave", function() UI.SetBorderColor(border, THEME.BORDER) end)
  return b
end

-- Gives every text in a frame (and in everything inside it) an outline. Used on the window, the dropdown
-- list and the game's settings page.
local function ApplyOutline(frame, flags)
  flags = flags or "OUTLINE"
  for _, region in ipairs({ frame:GetRegions() }) do
    if region.GetObjectType and region:GetObjectType() == "FontString" then
      local path, size = region:GetFont()
      if path then region:SetFont(path, size, flags) end
    end
  end
  for _, child in ipairs({ frame:GetChildren() }) do ApplyOutline(child, flags) end
end

UI.Circle, UI.FlatSwitch, UI.FlatChip, UI.ApplyOutline = Circle, FlatSwitch, FlatChip, ApplyOutline
