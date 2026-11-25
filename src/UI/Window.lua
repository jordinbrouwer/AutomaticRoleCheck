-- The options window: header, close button, resize grip, opening and closing.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local LAYOUT = UI.LAYOUT
local THEME = UI.THEME
local S = UI.state
local L = ARC.Loc
local GetOptions, GetOptionValue = UI.GetOptions, UI.GetOptionValue
local SyncRoles = UI.SyncRoles
local Relayout = UI.Relayout
local CloseMenu, ApplyOutline = UI.CloseMenu, UI.ApplyOutline
local WINDOW = UI.WINDOW
local checkboxFrames, choiceButtons, tableCells = UI.checkboxFrames, UI.choiceButtons, UI.tableCells

local BG = { 0.07, 0.07, 0.08, 0.97 }
local TITLE_COLOR = { 0.91, 0.97, 1 }
local SUBTITLE_COLOR = { 0.22, 0.77, 1 }
local FOOTER_COLOR = { 0.79, 0.8, 0.83 }
local FOOTER_LINE = { 0.11, 0.29, 0.4 }   -- the thin line along the top of the band
local HEADER_H = 44              -- the header band
local CONTENT_TOP = 47           -- the boxes start under the header
local CONTENT_PADDING = 51 + LAYOUT.FOOTER   -- window height = content height + this (header, footer, edges and a little air)

---------------------------------------------------------------- keeping the window in step with the settings
local function SyncAllCheckboxes()
  for key, sw in pairs(checkboxFrames) do
    if sw then sw:SetChecked(GetOptionValue(key) == true) end
  end
  for _, btn in pairs(choiceButtons) do btn:Sync() end
  for _, cell in ipairs(tableCells) do cell.sync() end
  SyncRoles()
end

ARC.RefreshWindow = function()
  SyncAllCheckboxes()
  Relayout()
end

---------------------------------------------------------------- the parts of the window
local window

-- The flat dark frame with the blue line along the top.
local function BuildFrame()
  local frame = CreateFrame("Frame", "AutomaticRoleCheckWindow", UIParent)
  frame:SetSize(WINDOW.WIDTH, math.min(WINDOW.MAX_H, math.floor(UIParent:GetHeight() * 0.88)))
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(BG[1], BG[2], BG[3], BG[4])
  UI.AddBorder(frame, THEME.BORDER)
  local accent = frame:CreateTexture(nil, "ARTWORK")
  accent:SetPoint("TOPLEFT", 1, -1)
  accent:SetPoint("TOPRIGHT", -1, -1)
  accent:SetHeight(2)
  accent:SetColorTexture(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 1)
  return frame
end

-- The header band: a dark blue bar with the logo, the name and the description from the .toc file.
local function BuildHeader(frame)
  local header = CreateFrame("Frame", nil, frame)
  header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -3)
  header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -3)
  header:SetHeight(HEADER_H)
  header:SetClipsChildren(true)
  local band = header:CreateTexture(nil, "BACKGROUND")
  band:SetAllPoints()
  band:SetColorTexture(THEME.HEADER[1], THEME.HEADER[2], THEME.HEADER[3], 1)
  local logo = header:CreateTexture(nil, "OVERLAY")
  logo:SetSize(34, 34)
  logo:SetPoint("LEFT", header, "LEFT", 12, 0)
  logo:SetTexture(ARC.Media.Logo)
  local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3], 1)
  title:SetText(ARC.AddonName)
  local sub = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
  sub:SetTextColor(SUBTITLE_COLOR[1], SUBTITLE_COLOR[2], SUBTITLE_COLOR[3], 1)
  local notes = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ARC.AddonName, "Notes"))
    or (GetAddOnMetadata and GetAddOnMetadata(ARC.AddonName, "Notes"))
  sub:SetText(notes and notes ~= "" and notes or L("header_sub"))
  -- name and description together are centred on the logo: the name sits half the block above the middle
  title:SetPoint("LEFT", header, "LEFT", 56, (sub:GetStringHeight() + 2) / 2)
end

-- A dark blue band along the bottom (like the header) with a hint about where to find the commands.
local function BuildFooter(frame)
  local band = frame:CreateTexture(nil, "ARTWORK")
  band:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
  band:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  band:SetHeight(LAYOUT.FOOTER)
  band:SetColorTexture(THEME.HEADER[1], THEME.HEADER[2], THEME.HEADER[3], 1)
  local line = frame:CreateTexture(nil, "ARTWORK")
  line:SetPoint("BOTTOMLEFT", band, "TOPLEFT", 0, 0)
  line:SetPoint("BOTTOMRIGHT", band, "TOPRIGHT", 0, 0)
  UI.OnePixel(line, true)
  line:SetColorTexture(FOOTER_LINE[1], FOOTER_LINE[2], FOOTER_LINE[3], 1)
  local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  hint:SetPoint("LEFT", band, "LEFT", 10, 0)
  hint:SetTextColor(FOOTER_COLOR[1], FOOTER_COLOR[2], FOOTER_COLOR[3])
  hint:SetText(L("footer_hint", ARC.ORANGE .. "/arc help|r"))
end
-- A drawn cross in the top right corner.
local function BuildCloseButton(frame)
  local close = CreateFrame("Button", nil, frame)
  close:SetSize(24, 22)
  close:SetPoint("TOPRIGHT", -9, -3)
  local marks = {}
  for _, angle in ipairs({ math.pi / 4, -math.pi / 4 }) do
    local t = close:CreateTexture(nil, "ARTWORK")
    t:SetSize(11, 1.5)
    t:SetPoint("CENTER")
    t:SetRotation(angle)
    marks[#marks + 1] = t
  end
  local function Paint(c) for _, t in ipairs(marks) do t:SetColorTexture(c[1], c[2], c[3], 1) end end
  Paint(THEME.MUTED)
  close:SetScript("OnEnter", function() Paint(THEME.BRIGHT) end)
  close:SetScript("OnLeave", function() Paint(THEME.MUTED) end)
  close:SetScript("OnClick", function() frame:Hide() end)
end

-- The height of the window follows its content, but can be set by dragging (and is then remembered).
-- The window can never be taller than its content needs.
local function SetupFitting(frame)
  S.fitWindow = function(contentH)
    local o = GetOptions()
    local fit = math.floor(math.max(160, math.min(UIParent:GetHeight(), contentH + CONTENT_PADDING)) + 0.5)
    if frame.SetResizeBounds then
      frame:SetResizeBounds(WINDOW.MIN_W, math.min(WINDOW.MIN_H, fit), math.min(WINDOW.MAX_W, UIParent:GetWidth()), fit)
    end
    if o and o.WindowHeight then
      if frame:GetHeight() > fit + 0.5 and not frame.sizing then
        frame:SetHeight(fit)
        o.WindowHeight = fit
      end
      return
    end
    frame:SetHeight(math.floor(math.max(160, math.min(math.floor(UIParent:GetHeight() * 0.92), contentH + CONTENT_PADDING)) + 0.5))
  end
end

-- Showing: the saved size, and the layout done again right away and twice more (the window is built
-- hidden, so its sizes are only known a moment after it is shown): nothing has to be dragged into place.
local function SetupShowing(frame)
  frame:SetScript("OnHide", CloseMenu)
  frame:HookScript("OnHide", function() UI.Tip.Hide() end)
  local function Refresh()
    local scroll = S.layoutParent and S.layoutParent:GetParent()
    if scroll then
      local w = scroll:GetWidth()
      if w and w > 0 then S.layoutParent:SetWidth(w) end
      scroll:UpdateScrollChildRect()
      scroll:SetVerticalScroll(scroll:GetVerticalScroll())
      -- a hide and show makes the scroll area draw everything inside it again
      S.layoutParent:Hide()
      S.layoutParent:Show()
    end
    SyncAllCheckboxes()
    Relayout()
  end
  frame:SetScript("OnShow", function(self)
    local o = GetOptions()
    if o and tonumber(o.WindowWidth) then
      self:SetWidth(math.max(WINDOW.MIN_W, math.min(WINDOW.MAX_W, UIParent:GetWidth(), tonumber(o.WindowWidth))))
    end
    if o and tonumber(o.WindowHeight) then
      self:SetHeight(math.max(WINDOW.MIN_H, math.min(UIParent:GetHeight(), tonumber(o.WindowHeight))))
    end
    Refresh()
    C_Timer.After(0, Refresh)
    C_Timer.After(0.1, Refresh)
    C_Timer.After(0.4, Refresh)
  end)
end

-- Escape closes the window.
local function SetupEscape(frame)
  tinsert(UISpecialFrames, "AutomaticRoleCheckWindow")
  -- belt and braces: the window also listens for Escape itself, and passes every other key on
  frame:EnableKeyboard(true)
  -- (changing what a frame passes on is not allowed in combat, so it is only done outside combat)
  if not InCombatLockdown() then frame:SetPropagateKeyboardInput(true) end
  frame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
      if not InCombatLockdown() then self:SetPropagateKeyboardInput(false) end
      self:Hide()
    end
  end)
  frame:HookScript("OnShow", function(self)
    if not InCombatLockdown() then self:SetPropagateKeyboardInput(true) end
  end)
end

-- The grip in the bottom right corner: drag to change width and height, right-click for the default size.
-- The size is remembered.
local function BuildGrip(frame)
  frame:SetResizable(true)
  if frame.SetResizeBounds then
    frame:SetResizeBounds(WINDOW.MIN_W, WINDOW.MIN_H, math.min(WINDOW.MAX_W, UIParent:GetWidth()), UIParent:GetHeight())
  elseif frame.SetMinResize then
    frame:SetMinResize(WINDOW.MIN_W, WINDOW.MIN_H)
    if frame.SetMaxResize then frame:SetMaxResize(math.min(WINDOW.MAX_W, UIParent:GetWidth()), UIParent:GetHeight()) end
  end
  local grip = CreateFrame("Button", nil, frame)
  grip:SetSize(14, 14)
  grip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
  grip:SetFrameLevel(frame:GetFrameLevel() + 20)
  local icon = grip:CreateTexture(nil, "OVERLAY")   -- our own picture (a corner of dots)
  icon:SetAllPoints()
  icon:SetTexture(ARC.Media.Grip)
  local function Paint(c) icon:SetVertexColor(c[1], c[2], c[3], 1) end
  Paint(THEME.MUTED)
  grip:SetScript("OnEnter", function(self)
    Paint(THEME.BRIGHT)
    UI.Tip.Show(self, "LEFT", L("grip_title"),
      ARC.ORANGE .. L("grip_label_drag") .. "|r " .. L("grip_tip_drag"),
      ARC.ORANGE .. L("grip_label_right") .. "|r " .. L("grip_tip_reset"))
  end)
  grip:SetScript("OnLeave", function() Paint(THEME.MUTED); UI.Tip.Hide() end)
  grip:SetScript("OnMouseDown", function(_, mouseButton)
    if mouseButton ~= "LeftButton" then return end
    -- sizing from the top left corner: the window is anchored there first
    local left, top = frame:GetLeft(), frame:GetTop()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    frame.sizing = true
    frame:StartSizing("BOTTOMRIGHT")
  end)
  grip:SetScript("OnMouseUp", function(_, mouseButton)
    local o = GetOptions()
    if mouseButton == "RightButton" then
      -- right-click: back to the default size
      if o then o.WindowWidth, o.WindowHeight = nil, nil end
      frame:SetWidth(WINDOW.WIDTH)
      Relayout()
      return
    end
    frame:StopMovingOrSizing()
    frame.sizing = false
    if o then
      o.WindowWidth, o.WindowHeight = math.floor(frame:GetWidth() + 0.5), math.floor(frame:GetHeight() + 0.5)
    end
    Relayout()
  end)
end

---------------------------------------------------------------- the window
local function BuildWindow()
  window = BuildFrame()
  BuildHeader(window)
  BuildCloseButton(window)
  BuildFooter(window)
  local host = CreateFrame("Frame", nil, window)
  host:SetPoint("TOPLEFT", window, "TOPLEFT", 0, -CONTENT_TOP)
  host:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 0, 4 + LAYOUT.FOOTER)
  UI.BuildCanvas(host)
  SetupFitting(window)
  SetupShowing(window)
  SetupEscape(window)
  BuildGrip(window)
  ApplyOutline(window)
  window:Hide()
end

ARC.OpenOptions = function()
  if not GetOptions() then
    ARC.PrintError(L("options_not_loaded"))
    return
  end
  if not window then BuildWindow() end
  if window:IsShown() then
    window:Hide()
  else
    window:Show()
  end
end
