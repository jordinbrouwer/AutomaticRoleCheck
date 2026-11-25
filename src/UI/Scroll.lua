-- The scroll area of the window, with its thin scroll bar.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local S = UI.state
local Relayout = UI.Relayout

-- Builds the scroll area into host and gives back the frame that holds the boxes.
function UI.CreateScrollArea(host)
  -- Many settings: everything sits in a scroll area, so nothing runs off the bottom.
  local scroll = CreateFrame("ScrollFrame", nil, host)
  scroll:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
  scroll:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", 0, 0)
  local parent = CreateFrame("Frame", nil, scroll)
  parent:SetSize(600, 900)
  scroll:SetScrollChild(parent)
  scroll:SetScript("OnSizeChanged", function(_, width) parent:SetWidth(math.max(200, width)); Relayout() end)
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local range = self:GetVerticalScrollRange()
    self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * 40)))
  end)
  S.layoutParent = parent

  -- A thin scroll bar on the right: a track, and a thumb you can drag. It hides when everything fits.
  local track = CreateFrame("Frame", nil, host)
  track:SetWidth(3)
  track:SetPoint("TOPRIGHT", host, "TOPRIGHT", -5, -2)
  track:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -5, 2)
  local trackBg = track:CreateTexture(nil, "BACKGROUND")
  trackBg:SetAllPoints()
  trackBg:SetColorTexture(1, 1, 1, 0.07)
  local thumb = CreateFrame("Button", nil, track)
  thumb:SetWidth(3)
  local thumbTex = thumb:CreateTexture(nil, "ARTWORK")
  thumbTex:SetAllPoints()
  thumbTex:SetColorTexture(THEME.THUMB[1], THEME.THUMB[2], THEME.THUMB[3], 0.85)
  local function UpdateThumb()
    scroll:UpdateScrollChildRect()
    local range = scroll:GetVerticalScrollRange()
    local trackH = track:GetHeight()
    -- If the window became taller (or the content shorter) while we were scrolled down, go back up
    -- as far as needed: never stay scrolled past the end.
    if scroll:GetVerticalScroll() > (range or 0) then scroll:SetVerticalScroll(math.max(0, range or 0)) end
    if not range or range < 1 or not trackH or trackH <= 0 then
      scroll:SetVerticalScroll(0)
      track:Hide()
      return
    end
    track:Show()
    local viewH = scroll:GetHeight()
    local thumbH = math.max(28, trackH * viewH / (viewH + range))
    thumb:SetHeight(thumbH)
    local pos = (scroll:GetVerticalScroll() / range) * (trackH - thumbH)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOP", track, "TOP", 0, -pos)
  end
  local grab = 0
  thumb:SetScript("OnMouseDown", function(self)
    local _, cursorY = GetCursorPosition()
    grab = self:GetTop() * self:GetEffectiveScale() - cursorY
    thumbTex:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 1)
    self:SetScript("OnUpdate", function()
      local _, y2 = GetCursorPosition()
      local top = track:GetTop() - (y2 + grab) / track:GetEffectiveScale()
      local free = math.max(1, track:GetHeight() - thumb:GetHeight())
      local ratio = math.max(0, math.min(1, top / free))
      scroll:SetVerticalScroll(ratio * scroll:GetVerticalScrollRange())
    end)
  end)
  thumb:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil)
    thumbTex:SetColorTexture(THEME.THUMB[1], THEME.THUMB[2], THEME.THUMB[3], 0.85)
  end)
  thumb:SetScript("OnEnter", function() thumbTex:SetColorTexture(THEME.THUMB_HOVER[1], THEME.THUMB_HOVER[2], THEME.THUMB_HOVER[3], 1) end)
  thumb:SetScript("OnLeave", function() thumbTex:SetColorTexture(THEME.THUMB[1], THEME.THUMB[2], THEME.THUMB[3], 0.85) end)
  scroll:HookScript("OnVerticalScroll", UpdateThumb)
  scroll:HookScript("OnScrollRangeChanged", UpdateThumb)
  scroll:HookScript("OnSizeChanged", UpdateThumb)
  S.scrollUpdate = UpdateThumb
  return parent
end
