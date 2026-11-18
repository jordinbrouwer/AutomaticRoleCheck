AutomaticRoleCheck = AutomaticRoleCheck or {}

local locale = GetLocale()

local enUS = {
  settings_category = "AutomaticRoleCheck",
  error_prefix = "Error: ",
  options_not_loaded = "Options are not loaded yet, try again in a moment.",
  status_loading = "Status: loading.",
  status_enabled_disable_next = "Enabled: Will disable for the next role check.",
  status_enabled_remain = "Enabled: Will remain active for the next role check.",
  status_disabled_enable_next = "Disabled: Will enable for the next role check.",
  status_disabled_remain = "Disabled: Will remain disabled for the next role check.",
  cmd_list_header = "List of available commands:",
  cmd_help_root = "show current addon status and list available commands.",
  cmd_help_status = "show current addon status.",
  cmd_help_options = "open addon options.",
  cmd_help_enable = "enable the addon, or enable once for the next role check.",
  cmd_help_disable = "disable the addon, or disable once for the next role check.",
  cmd_help_minimap = "control minimap button visibility.",
  cmd_invalid = "Invalid command.",
  cmd_invalid_enable = "Invalid enable command. Use: /arc enable [once].",
  cmd_invalid_disable = "Invalid disable command. Use: /arc disable [once].",
  cmd_invalid_minimap = "Invalid minimap command. Use: /arc minimap show, hide, or toggle.",
  cmd_enabled_addon = "Enabled the addon.",
  cmd_enabled_once = "Enabled once for the next role check.",
  cmd_disabled_addon = "Disabled the addon.",
  cmd_disabled_once = "Disabled once for the next role check.",
  cmd_minimap_shown = "Minimap button is now shown.",
  cmd_minimap_hidden = "Minimap button is now hidden.",
  minimap_hidden_print = "Minimap button is now hidden. Use /arc minimap show to restore it.",
  minimap_tooltip_title = "AutomaticRoleCheck",
  minimap_hint_toggle = "Left-click: enable/disable.",
  minimap_hint_hide = "Shift + Left-click: hide minimap button.",
  minimap_hint_options = "Right-click: open options.",
  minimap_status_enabled = "Status: enabled",
  minimap_status_disabled = "Status: disabled",
  minimap_status_loading = "Status: loading...",
  panel_label_Enabled = "Enabled",
  panel_desc_Enabled = "Addon enabled status.",
  panel_label_ShowMinimapButton = "Show minimap button",
  panel_desc_ShowMinimapButton = "Toggle minimap icon.",
  panel_group_when_enabled = "When addon is enabled",
  panel_group_when_disabled = "When addon is disabled",
  panel_label_DisableWhilstAFK = "Disable whilst AFK",
  panel_desc_DisableWhilstAFK = "Disable addon while AFK.",
  panel_label_DisableOnce = "Disable once",
  panel_desc_DisableOnce = "Disable for next role check.",
  panel_label_EnableOnce = "Enable once",
  panel_desc_EnableOnce = "Enable for next role check.",
  panel_label_DisableOnceOnLogin = "Disable once on login",
  panel_desc_DisableOnceOnLogin = "Disable on first login check.",
  panel_label_DisableOnceOnRoleChange = "Disable once on role change",
  panel_desc_DisableOnceOnRoleChange = "Disable after role switch.",
  meta_version_unknown = "unknown",
}

local overrides = {}

local merged = {}
for k, v in pairs(enUS) do
  merged[k] = v
end
local over = overrides[locale]
if type(over) == "table" then
  for k, v in pairs(over) do
    merged[k] = v
  end
end

function AutomaticRoleCheck.Loc(key, ...)
  local fmt = merged[key]
  if type(fmt) ~= "string" then
    return tostring(key)
  end
  if select("#", ...) > 0 then
    local ok, result = pcall(string.format, fmt, ...)
    if ok then
      return result
    end
    return fmt
  end
  return fmt
end
