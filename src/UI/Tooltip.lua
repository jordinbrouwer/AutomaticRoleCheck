-- Our own tooltip: a dark box with a blue edge, a blue title and white text.
-- UI.Tip.Show(owner, anchor, title, paragraph, ...)  anchor "RIGHT" or "LEFT";  UI.Tip.Hide(owner)
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME

local MAX_W, PAD = 260, 10

local frame = CreateFrame("Frame", "AutomaticRoleCheckTip", UIParent)
frame:SetFrameStrata("TOOLTIP")
frame:SetClampedToScreen(true)
frame:Hide()
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(THEME.TIP_BG[1], THEME.TIP_BG[2], THEME.TIP_BG[3], 0.98)
UI.AddBorder(frame, THEME.ACCENT)
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -PAD)
title:SetJustifyH("LEFT")
title:SetTextColor(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3])
local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
body:SetJustifyH("LEFT")
body:SetTextColor(1, 1, 1)
body:SetSpacing(2)
UI.ApplyOutline(frame)   -- the thin outline, like the rest of the window

local Tip = {}
UI.Tip = Tip

function Tip.Show(owner, anchor, titleText, ...)
  if not owner then return end
  local bodyText = table.concat({ ... }, "\n")
  local hasTitle = titleText ~= nil and titleText ~= ""
  local hasBody = bodyText ~= ""
  frame.owner = owner
  local w, h = 0, PAD * 2
  title:SetShown(hasTitle)
  if hasTitle then
    title:SetWidth(0)
    title:SetText(titleText)
    w = title:GetStringWidth()
    h = h + title:GetStringHeight()
  end
  body:SetShown(hasBody)
  body:ClearAllPoints()
  if hasBody then
    body:SetWidth(0)
    body:SetText(bodyText)
    local bodyW = math.min(MAX_W, body:GetStringWidth())
    body:SetWidth(math.ceil(bodyW) + 1)
    w = math.max(w, bodyW)
    h = h + body:GetStringHeight() + (hasTitle and 4 or 0)
    if hasTitle then
      body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    else
      body:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -PAD)
    end
  end
  frame:SetSize(math.ceil(w) + PAD * 2, math.ceil(h))
  frame:ClearAllPoints()
  if anchor == "LEFT" then
    frame:SetPoint("BOTTOMRIGHT", owner, "TOPLEFT", -2, 2)
  else
    frame:SetPoint("BOTTOMLEFT", owner, "TOPRIGHT", 2, 2)
  end
  frame:Show()
end

function Tip.Hide(owner)
  if not owner or frame.owner == owner then
    frame:Hide()
    frame.owner = nil
  end
end

function Tip.IsOwned(owner)
  return frame:IsShown() and frame.owner == owner
end