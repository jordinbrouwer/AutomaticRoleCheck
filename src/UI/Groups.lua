-- The reset link in the corner of a box, and the boxes with plain rows.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local THEME = UI.THEME
local L = ARC.Loc
local GetOptions, SetOption = UI.GetOptions, UI.SetOption
local CreateBox, CreateCheckboxRow, CreateChoiceRow = UI.CreateBox, UI.CreateCheckboxRow, UI.CreateChoiceRow
local checkboxFrames, groups = UI.checkboxFrames, UI.groups

  local function AddReset(box, keys)
    -- A small grey "Reset" in the corner of the box title. The first click asks "Click again"
    -- (for three seconds); the second click puts the settings of this box back to their defaults.
    local link = CreateFrame("Button", nil, box)
    link:SetHeight(14)
    link:SetPoint("TOPRIGHT", box, "TOPRIGHT", -5, -2)
    link.text = link:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    link.text:SetPoint("RIGHT", link, "RIGHT", 0, 0)
    -- the reset icon (our own copy of the arrow), tinted with the text
    link.icon = link:CreateTexture(nil, "ARTWORK")
    link.icon:SetSize(9, 9)
    link.icon:SetPoint("RIGHT", link, "RIGHT", 0, 0)
    link.icon:SetTexture(ARC.Media.Reset)
    link.text:ClearAllPoints()
    link.text:SetPoint("RIGHT", link.icon, "LEFT", -3, 0)
    link.text:SetScale(0.85)
    local armedUntil
    local function Show(text, r, g, b)
      link.text:SetText(text)
      link.confirmText = text
      link.text:SetTextColor(r, g, b)
      link.icon:SetVertexColor(r, g, b, 1)
      link:SetWidth(text ~= "" and (link.text:GetStringWidth() * 0.85 + 16) or 16)
    end
    local function Rest(hover)
      armedUntil = nil
      if hover then Show("", THEME.ORANGE[1], THEME.ORANGE[2], THEME.ORANGE[3]) else Show("", THEME.GREY[1], THEME.GREY[2], THEME.GREY[3]) end
    end
    Rest(false)
    local function DoReset()
      if not GetOptions() then return end
      local defaults = ARC.Defaults or {}
      -- the link first, so the in-combat values don't copy over the out-of-combat ones while resetting
      for _, key in ipairs(keys) do
        if key == "LinkCombat" and defaults[key] ~= nil then SetOption(key, defaults[key]) end
      end
      for _, key in ipairs(keys) do
        if key ~= "LinkCombat" and defaults[key] ~= nil then SetOption(key, defaults[key]) end
      end
    end
    link:SetScript("OnEnter", function(self)
      if not armedUntil then Rest(true) end
      UI.Tip.Show(self, "RIGHT", L("reset"), armedUntil and L("reset_confirm") or L("reset_tip"))
    end)
    link:SetScript("OnLeave", function()
      if not armedUntil then Rest(false) end
      UI.Tip.Hide()
    end)
    link:SetScript("OnClick", function()
      if armedUntil and GetTime() < armedUntil then
        DoReset()
        Rest(false)
        return
      end
      armedUntil = GetTime() + 3
      Show(L("reset_confirm"), 1, 0.42, 0.42)
      if UI.Tip.IsOwned(link) then UI.Tip.Show(link, "RIGHT", L("reset"), L("reset_confirm")) end
      C_Timer.After(3, function()
        if armedUntil and GetTime() >= armedUntil then Rest(false) end
      end)
    end)
    return link
  end

  local function AddBoxedGroup(parent, boxLabel, items, column, kind, extraKeys)
    local box = CreateBox(parent, boxLabel)
    local g = { box = box, column = column, kind = kind, rows = {} }
    local keys = {}
    for _, item in ipairs(items) do
      keys[#keys + 1] = item.key
    end
    for _, key in ipairs(extraKeys or {}) do keys[#keys + 1] = key end
    if kind ~= "disabled" then AddReset(box, keys) end
    for _, item in ipairs(items) do
      local row
      if item.choices then
        row = CreateChoiceRow(box, item)
      else
        local sw
        row, sw = CreateCheckboxRow(box, item.key, L(item.label), L(item.desc))
        checkboxFrames[item.key] = sw
      end
      g.rows[#g.rows + 1] = { row = row, key = item.key }
    end
    groups[#groups + 1] = g
    return box
  end

UI.AddReset, UI.AddBoxedGroup = AddReset, AddBoxedGroup
