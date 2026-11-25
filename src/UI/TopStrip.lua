-- The line at the top: the Enabled box and the My role box (one line, or two when the window is narrow).
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local S = UI.state
local L = ARC.Loc
local LAYOUT, THEME = UI.LAYOUT, UI.THEME
local FlatSwitch = UI.FlatSwitch
local GetOptionValue, SetOption = UI.GetOptionValue, UI.SetOption
local CreateBox, CreateCheckboxRow = UI.CreateBox, UI.CreateCheckboxRow
local ROLE_BOX_H, ROLES, ToggleRole = UI.ROLE_BOX_H, UI.ROLES, UI.ToggleRole
local checkboxFrames, roleButtons = UI.checkboxFrames, UI.roleButtons

local ENABLED_W = 120                  -- the Enabled box
local STRIP_GAP = 8                    -- between the Enabled box and the My role box
local ROLE_BTN_W, ROLE_BTN_GAP = 78, 6 -- the three role buttons
local FOLLOW_W, SET_W = 122, 132       -- the two switches at the right end of the My role box

local function SectionTitle(box, text)
  local title = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetTextColor(THEME.ACCENT[1], THEME.ACCENT[2], THEME.ACCENT[3], 1)
  title:SetText(text)
  return title
end

---------------------------------------------------------------- Enabled
-- "Enabled": a box like the role box, with a blue title and the switch; click anywhere on it.
local function BuildEnabledBox(parent)
  local box = CreateBox(parent, nil)
  box:SetSize(ENABLED_W, ROLE_BOX_H)
  SectionTitle(box, L("panel_label_Enabled")):SetPoint("LEFT", box, "LEFT", 8, 0)
  local sw = FlatSwitch(box, function(value) SetOption("Enabled", value) end)
  sw.tooltip, sw.tooltipTitle, sw.tooltipOwner = L("panel_desc_Enabled"), L("panel_label_Enabled"), box
  sw:SetPoint("RIGHT", box, "RIGHT", -8, 0)
  sw:SetChecked(GetOptionValue("Enabled") == true)
  box:EnableMouse(true)
  box:SetScript("OnMouseUp", function() sw:Click() end)
  box:SetScript("OnEnter", function(self)
    UI.Tip.Show(self, "RIGHT", L("panel_label_Enabled"), L("panel_desc_Enabled"))
  end)
  box:SetScript("OnLeave", function() UI.Tip.Hide() end)
  checkboxFrames["Enabled"] = sw
  return box
end

---------------------------------------------------------------- My role
-- The three role buttons (Tank, Healer, Damage), one after the other, starting after `title`.
local function BuildRoleButtons(roleBox, title)
  local prev
  for _, def in ipairs(ROLES) do
    local btn = CreateFrame("Button", nil, roleBox)
    btn:SetSize(ROLE_BTN_W, 18)
    if prev then btn:SetPoint("LEFT", prev, "RIGHT", ROLE_BTN_GAP, 0) else btn:SetPoint("LEFT", title, "RIGHT", 12, 0) end
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.border = UI.AddBorder(btn, THEME.GREY)   -- the colour is set by SyncRoles
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(16, 16)
    btn.icon:SetPoint("LEFT", btn, "LEFT", 6, 0)
    local hasIcon = def.atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(def.atlas)
    if hasIcon then btn.icon:SetAtlas(def.atlas) end
    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.label:SetPoint("LEFT", btn, "LEFT", hasIcon and 26 or 8, 0)
    btn.label:SetText(L(def.name))
    btn.role = def.role
    btn:SetScript("OnClick", function(self) ToggleRole(self.role) end)
    btn:SetScript("OnEnter", function(self)
      if self.can == false then
        UI.Tip.Show(self, "RIGHT", L(def.name), "|cffff6b6b" .. L("role_cant") .. "|r")
      else
        UI.Tip.Show(self, "RIGHT", L(def.name), L("role_tip"))
      end
    end)
    btn:SetScript("OnLeave", function() UI.Tip.Hide() end)
    roleButtons[#roleButtons + 1] = btn
    prev = btn
  end
end

-- The box with the roles and the two switches "Follow spec" and "Set in group".
local function BuildRoleBox(parent)
  local box = CreateBox(parent, nil)
  box:SetHeight(ROLE_BOX_H)
  local title = SectionTitle(box, L("panel_group_role"))
  BuildRoleButtons(box, title)
  local rowSet, swSet = CreateCheckboxRow(box, "SetGroupRole", L("panel_label_SetGroupRole"), L("panel_desc_SetGroupRole"))
  rowSet:SetWidth(SET_W)
  checkboxFrames["SetGroupRole"] = swSet
  local rowFollow, swFollow = CreateCheckboxRow(box, "FollowSpec", L("panel_label_FollowSpec"), L("panel_desc_FollowSpec"))
  rowFollow:SetWidth(FOLLOW_W)
  checkboxFrames["FollowSpec"] = swFollow
  return box, title, rowFollow, rowSet
end

-- Builds the top line into parent, starting at height y. Gives back where the boxes below it start.
function UI.BuildTopStrip(parent, y)
  local stripY = y - 4
  local enabledBox = BuildEnabledBox(parent)
  local roleBox, roleTitle, rowFollow, rowSet = BuildRoleBox(parent)

  -- Places the strip for this width (it runs with every layout). One line when it fits; narrow: "Enabled"
  -- on its own line and "My role" in two lines. Gives back where the boxes below start.
  S.placeStrip = function(avail)
    avail = avail or 760
    enabledBox:ClearAllPoints()
    enabledBox:SetPoint("TOPLEFT", parent, "TOPLEFT", LAYOUT.OUTER, stripY)
    roleBox:ClearAllPoints()
    rowSet:ClearAllPoints()
    rowFollow:ClearAllPoints()
    roleTitle:ClearAllPoints()
    local bottom
    -- one line only when the roles AND the two switches really fit next to each other
    local need = ENABLED_W + STRIP_GAP + 8 + roleTitle:GetStringWidth() + 12 + 3 * ROLE_BTN_W + 2 * ROLE_BTN_GAP
      + 24 + FOLLOW_W + 10 + SET_W + 8 + LAYOUT.OUTER
    if avail >= need then
      roleBox:SetPoint("TOPLEFT", parent, "TOPLEFT", LAYOUT.OUTER + ENABLED_W + STRIP_GAP, stripY)
      roleBox:SetWidth(avail - ENABLED_W - STRIP_GAP)
      roleBox:SetHeight(ROLE_BOX_H)
      roleTitle:SetPoint("LEFT", roleBox, "LEFT", 8, 0)
      rowSet:SetPoint("RIGHT", roleBox, "RIGHT", -8, 0)
      rowFollow:SetPoint("RIGHT", rowSet, "LEFT", -10, 0)
      bottom = stripY - ROLE_BOX_H
    else
      local top2 = stripY - ROLE_BOX_H - 4
      roleBox:SetPoint("TOPLEFT", parent, "TOPLEFT", LAYOUT.OUTER, top2)
      roleBox:SetWidth(avail)
      roleBox:SetHeight(ROLE_BOX_H * 2 - 2)
      roleTitle:SetPoint("LEFT", roleBox, "TOPLEFT", 8, -ROLE_BOX_H / 2)
      rowFollow:SetPoint("LEFT", roleBox, "BOTTOMLEFT", 8, ROLE_BOX_H / 2 - 1)
      rowSet:SetPoint("LEFT", rowFollow, "RIGHT", 10, 0)
      bottom = top2 - (ROLE_BOX_H * 2 - 2)
    end
    enabledBox:Show()
    roleBox:Show()
    return bottom - LAYOUT.BOX_GAP
  end

  return y - 4 - ROLE_BOX_H - LAYOUT.BOX_GAP
end
