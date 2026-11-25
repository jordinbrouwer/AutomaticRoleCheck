-- The game's own settings page: a short page with a button that opens the window.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local L = ARC.Loc

local FlatChip = UI.FlatChip
local canvasFrame = CreateFrame("Frame")
local SettingsPanel = _G.SettingsPanel

-- The game's own settings page is a short page with a button; the real settings are in a window
-- that /arc opens (built the first time it is needed).
ARC.Panel = Settings.RegisterCanvasLayoutCategory(canvasFrame, L("settings_category"))

---------------------------------------------------------------- the game's settings page: a short page
do
  local icon = canvasFrame:CreateTexture(nil, "ARTWORK")
  icon:SetSize(44, 44)
  icon:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", 24, -24)
  icon:SetTexture(ARC.Media.Logo)

  local title = canvasFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  title:SetPoint("LEFT", icon, "RIGHT", 12, 0)
  title:SetText(ARC.AddonName or "AutomaticRoleCheck")

  local desc = canvasFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  desc:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -14)
  desc:SetPoint("RIGHT", canvasFrame, "RIGHT", -24, 0)
  desc:SetJustifyH("LEFT")
  desc:SetText(L("page_desc"))

  local open = FlatChip(canvasFrame, 280, 30)
  open:SetPoint("CENTER", canvasFrame, "CENTER", 0, 0)
  open:SetText(L("page_open"))
  open:SetScript("OnClick", function()
    if SettingsPanel and HideUIPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
    ARC.OpenOptions()
    local window = _G.AutomaticRoleCheckWindow
    if window and not window:IsShown() then window:Show() end
  end)

  local hint = canvasFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  hint:SetPoint("TOP", open, "BOTTOM", 0, -10)
  hint:SetTextColor(THEME.MUTED[1], THEME.MUTED[2], THEME.MUTED[3])
  hint:SetText(L("page_hint"))
  UI.ApplyOutline(canvasFrame)
end

Settings.RegisterAddOnCategory(ARC.Panel)
