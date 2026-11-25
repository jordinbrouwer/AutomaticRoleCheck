-- Builds everything inside the window: the scroll area, the top line and all the boxes.
local ARC = AutomaticRoleCheck
local UI = ARC.UI
local S = UI.state
local L = ARC.Loc
local LAYOUT = UI.LAYOUT
local AddBoxedGroup, AddTableGroup, AddMinimapGroup = UI.AddBoxedGroup, UI.AddTableGroup, UI.AddMinimapGroup

function UI.BuildCanvas(host)
  local parent = UI.CreateScrollArea(host)
  local y = -LAYOUT.TOP + 4   -- the title and logo live in the header band; the boxes start close under it
  S.layoutTop = UI.BuildTopStrip(parent, y)

  -- Left: when enabled, what to accept, only when. Right: the table and the minimap button.
  -- While the addon is off, "when disabled" replaces them.
  AddBoxedGroup(parent, L("panel_group_when_enabled"), {
    { key = "DisableWhilstAFK",        label = "panel_label_DisableWhilstAFK",        desc = "panel_desc_DisableWhilstAFK"        },
    { key = "DisableOnce",             label = "panel_label_DisableOnce",             desc = "panel_desc_DisableOnce"             },
    { key = "DisableOnceOnLogin",      label = "panel_label_DisableOnceOnLogin",      desc = "panel_desc_DisableOnceOnLogin"      },
    { key = "DisableOnceOnRoleChange", label = "panel_label_DisableOnceOnRoleChange", desc = "panel_desc_DisableOnceOnRoleChange" },
  }, "c1")
  AddTableGroup(parent)
  AddBoxedGroup(parent, L("panel_group_what"), {
    { key = "AcceptRoleCheck", label = "panel_label_AcceptRoleCheck", desc = "panel_desc_AcceptRoleCheck" },
    { key = "AcceptRolePoll",  label = "panel_label_AcceptRolePoll",  desc = "panel_desc_AcceptRolePoll"  },
    { key = "AcceptInvite",    label = "panel_label_AcceptInvite",    desc = "panel_desc_AcceptInvite"    },
    { key = "AcceptSignUp",    label = "panel_label_AcceptSignUp",    desc = "panel_desc_AcceptSignUp"    },
  }, "c2")
  AddBoxedGroup(parent, L("panel_group_when"), {
    { key = "AcceptTank",   label = "panel_label_AcceptTank",   desc = "panel_desc_AcceptTank"   },
    { key = "AcceptHealer", label = "panel_label_AcceptHealer", desc = "panel_desc_AcceptHealer" },
    { key = "AcceptDamage", label = "panel_label_AcceptDamage", desc = "panel_desc_AcceptDamage" },
    { key = "Scope",        label = "panel_label_Scope",        desc = "panel_desc_Scope",        choices = true },
  }, "c3")
  AddMinimapGroup(parent)
  AddBoxedGroup(parent, L("panel_group_when_disabled"), {
    { key = "EnableOnce", label = "panel_label_EnableOnce", desc = "panel_desc_EnableOnce" },
  }, "left", "disabled")
end
