local ADDON_NAME, SUF = ...

local ADDON_ICON = "Interface\\AddOns\\SleekUnitFramesTBC\\Media\\AddonIcon"

local function GetAddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "?"
    elseif GetAddOnMetadata then
        return GetAddOnMetadata(ADDON_NAME, "Version") or "?"
    end
    return "?"
end

--[[
    v0.16 settings UI

    Blizzard's Vertical Layout settings API is intentionally single-column.
    That was convenient when Sleek Unit Frames only had a handful of options,
    but it became increasingly awkward as the addon grew.

    This panel uses Blizzard's Canvas Layout category instead. The canvas still
    lives inside the native TBC Anniversary Settings window, while letting us
    arrange native WoW controls into logical two-column groups.
]]

local HEALTH_COLOR_OPTIONS = {
    { value = "GREEN",   label = "Classic green" },
    { value = "CLASS",   label = "Automatic unit class color" },
    { value = "WARRIOR", label = "Warrior" },
    { value = "PALADIN", label = "Paladin" },
    { value = "HUNTER",  label = "Hunter" },
    { value = "ROGUE",   label = "Rogue" },
    { value = "PRIEST",  label = "Priest" },
    { value = "SHAMAN",  label = "Shaman" },
    { value = "MAGE",    label = "Mage" },
    { value = "WARLOCK", label = "Warlock" },
    { value = "DRUID",   label = "Druid" },
}

local CORNER_OPTIONS = {
    { value = "SOFT",   label = "Soft" },
    { value = "MEDIUM", label = "Medium" },
    { value = "TIGHT",  label = "Tight" },
}

local PVP_TIMER_COLOR_OPTIONS = {
    { value = "WHITE", label = "Soft white" },
    { value = "GOLD",  label = "Gold" },
}

local PARTY_AURA_POSITION_OPTIONS = {
    { value = "RIGHT", label = "Right of frame" },
    { value = "BELOW", label = "Below power bar" },
}

local PORTRAIT_RING_STYLE_OPTIONS = {
    { value = "SLEEK",  label = "Sleek dark" },
    { value = "GOLD",   label = "Retail gold" },
    { value = "SILVER", label = "Cool silver" },
}

local RESTING_STYLE_OPTIONS = {
    { value = "RETAIL",  label = "Retail floating Zs" },
    { value = "CLASSIC", label = "Classic resting icon" },
}

local PLAYER_CORNER_ORNAMENT_OPTIONS = {
    { value = "NONE",   label = "None" },
    { value = "SIMPLE", label = "Simple" },
}

local function FindOption(options, value)
    for _, option in ipairs(options) do
        if option.value == value then
            return option
        end
    end
    return options[1]
end

local function AddTooltip(widget, title, description)
    if not widget or not description or description == "" then
        return
    end

    widget:EnableMouse(true)
    widget:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title or "", 1.00, 0.82, 0.00)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    widget:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function CreateBackdropFrame(parent)
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", nil, parent, template)

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0.02, 0.025, 0.035, 0.56)
        frame:SetBackdropBorderColor(0.36, 0.39, 0.44, 0.62)
    else
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.02, 0.025, 0.035, 0.56)
    end

    return frame
end

local function CreateGroup(parent, title)
    local group = CreateBackdropFrame(parent)
    group.cursorY = -34

    local heading = group:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", group, "TOPLEFT", 14, -10)
    heading:SetText(title)

    local line = group:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -5)
    line:SetPoint("TOPRIGHT", group, "TOPRIGHT", -14, -5)
    line:SetHeight(1)
    line:SetColorTexture(0.48, 0.48, 0.48, 0.34)

    return group
end

local function FinishGroup(group, extraBottom)
    group:SetHeight(math.max(70, -group.cursorY + (extraBottom or 10)))
end

local function RegisterControl(key, refresh)
    SUF.SettingsControls = SUF.SettingsControls or {}
    SUF.SettingsControls[key] = SUF.SettingsControls[key] or {}
    table.insert(SUF.SettingsControls[key], refresh)
end

local function SetDBValue(key, value, callback)
    if SUF._refreshingSettingsPanel or not SUF.db then
        return
    end

    SUF.db[key] = value
    if callback then
        callback(value)
    end
end

local function AddCheckbox(group, key, label, description, callback)
    local y = group.cursorY
    group.cursorY = group.cursorY - 28

    local check = CreateFrame("CheckButton", nil, group, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check:SetPoint("TOPLEFT", group, "TOPLEFT", 10, y + 4)

    local text = group:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 3, 0)
    text:SetPoint("RIGHT", group, "RIGHT", -12, 0)
    text:SetJustifyH("LEFT")
    text:SetText(label)

    check:SetScript("OnClick", function(self)
        SetDBValue(key, self:GetChecked() and true or false, callback)
    end)

    AddTooltip(check, label, description)

    RegisterControl(key, function()
        check:SetChecked(SUF.db and SUF.db[key] and true or false)
    end)

    return check
end

local sliderCounter = 0
local function CreateNativeSlider(parent)
    sliderCounter = sliderCounter + 1
    local name = "SleekUnitFramesOptionsSlider" .. sliderCounter
    local slider

    local ok = pcall(function()
        slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    end)

    if not ok or not slider then
        slider = CreateFrame("Slider", name, parent)
        slider:SetOrientation("HORIZONTAL")
        local bg = slider:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("LEFT", slider, "LEFT", 0, 0)
        bg:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
        bg:SetHeight(6)
        bg:SetColorTexture(0.10, 0.12, 0.16, 1)
        local thumb = slider:CreateTexture(nil, "OVERLAY")
        thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        thumb:SetSize(32, 32)
        slider:SetThumbTexture(thumb)
    else
        local low = _G[name .. "Low"]
        local high = _G[name .. "High"]
        local title = _G[name .. "Text"]
        if low then low:SetText("") end
        if high then high:SetText("") end
        if title then title:SetText("") end
    end

    return slider
end

local function RoundToStep(value, step)
    if not step or step <= 0 then
        return value
    end
    return math.floor((value / step) + 0.5) * step
end

local function AddSlider(group, key, label, description, minValue, maxValue, step, formatter, callback)
    local y = group.cursorY
    group.cursorY = group.cursorY - 52

    local title = group:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOPLEFT", group, "TOPLEFT", 14, y)
    title:SetText(label)

    local valueText = group:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("TOPRIGHT", group, "TOPRIGHT", -14, y)
    valueText:SetJustifyH("RIGHT")

    local slider = CreateNativeSlider(group)
    slider:SetPoint("TOPLEFT", group, "TOPLEFT", 18, y - 19)
    slider:SetPoint("TOPRIGHT", group, "TOPRIGHT", -18, y - 19)
    slider:SetHeight(18)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end

    local function ShowValue(value)
        if formatter then
            valueText:SetText(formatter(value))
        elseif step and step < 1 then
            valueText:SetText(string.format("%.2f", value))
        else
            valueText:SetText(tostring(math.floor(value + 0.5)))
        end
    end

    slider:SetScript("OnValueChanged", function(self, value)
        value = RoundToStep(value, step)
        ShowValue(value)
        if SUF._refreshingSettingsPanel then
            return
        end
        SUF.db[key] = value
        if callback then
            callback(value)
        end
    end)

    AddTooltip(slider, label, description)

    RegisterControl(key, function()
        local value = SUF.db and SUF.db[key] or SUF.DEFAULTS[key]
        slider:SetValue(value)
        ShowValue(value)
    end)

    return slider
end

local dropdownCounter = 0
local function AddDropdown(group, key, label, description, options, callback)
    local y = group.cursorY
    group.cursorY = group.cursorY - 54

    local title = group:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOPLEFT", group, "TOPLEFT", 14, y)
    title:SetText(label)

    dropdownCounter = dropdownCounter + 1
    local name = "SleekUnitFramesOptionsDropdown" .. dropdownCounter
    local dropdown = CreateFrame("Frame", name, group, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", group, "TOPLEFT", -2, y - 17)
    UIDropDownMenu_SetWidth(dropdown, 225)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = option.value
            info.checked = SUF.db and SUF.db[key] == option.value
            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, option.value)
                UIDropDownMenu_SetText(dropdown, option.label)
                SetDBValue(key, option.value, callback)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    AddTooltip(dropdown, label, description)

    RegisterControl(key, function()
        local value = SUF.db and SUF.db[key] or SUF.DEFAULTS[key]
        local option = FindOption(options, value)
        UIDropDownMenu_SetSelectedValue(dropdown, option.value)
        UIDropDownMenu_SetText(dropdown, option.label)
    end)

    return dropdown
end

local function AddReadOnlyProfileValue(group, label, valueGetter)
    local y = group.cursorY
    group.cursorY = group.cursorY - 48

    local title = group:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOPLEFT", group, "TOPLEFT", 14, y)
    title:SetText(label)

    local value = group:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    value:SetPoint("TOPLEFT", group, "TOPLEFT", 14, y - 20)
    value:SetPoint("TOPRIGHT", group, "TOPRIGHT", -14, y - 20)
    value:SetJustifyH("LEFT")
    value:SetTextColor(1.00, 0.82, 0.16, 1)

    RegisterControl("__profiles", function()
        value:SetText(valueGetter and valueGetter() or "")
    end)

    return value
end

local function AddProfileDropdown(group, label, description)
    local y = group.cursorY
    group.cursorY = group.cursorY - 54

    local title = group:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOPLEFT", group, "TOPLEFT", 14, y)
    title:SetText(label)

    dropdownCounter = dropdownCounter + 1
    local name = "SleekUnitFramesProfileDropdown" .. dropdownCounter
    local dropdown = CreateFrame("Frame", name, group, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", group, "TOPLEFT", -2, y - 17)
    UIDropDownMenu_SetWidth(dropdown, 225)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    local function GetOptions()
        return SUF:GetProfileOptions(true)
    end

    UIDropDownMenu_Initialize(dropdown, function(_, level)
        local options = GetOptions()
        if #options == 0 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = "No saved profiles yet"
            info.disabled = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            return
        end

        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.label
            info.value = option.value
            info.checked = SUF.selectedProfileKey == option.value
            info.func = function()
                SUF.selectedProfileKey = option.value
                UIDropDownMenu_SetSelectedValue(dropdown, option.value)
                UIDropDownMenu_SetText(dropdown, option.label)
                SUF:RefreshSettingsPanel()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    AddTooltip(dropdown, label, description)

    RegisterControl("__profiles", function()
        local options = GetOptions()
        local selected = SUF.selectedProfileKey
        local selectedLabel

        for _, option in ipairs(options) do
            if option.value == selected then
                selectedLabel = option.label
                break
            end
        end

        if not selectedLabel then
            selected = options[1] and options[1].value or nil
            selectedLabel = options[1] and options[1].label or nil
            SUF.selectedProfileKey = selected
        end

        UIDropDownMenu_SetSelectedValue(dropdown, selected)
        UIDropDownMenu_SetText(dropdown, selectedLabel or "No saved profiles yet")
    end)

    return dropdown
end

local function AddActionButton(group, label, description, callback, row, column, columns)
    columns = columns or 2
    local gap = 8
    local leftPad = 14
    local rightPad = 14
    local button = CreateFrame("Button", nil, group, "UIPanelButtonTemplate")
    button:SetHeight(24)

    if columns == 1 then
        button:SetPoint("TOPLEFT", group, "TOPLEFT", leftPad, row)
        button:SetPoint("TOPRIGHT", group, "TOPRIGHT", -rightPad, row)
    elseif column == 1 then
        button:SetPoint("TOPLEFT", group, "TOPLEFT", leftPad, row)
        button:SetPoint("TOPRIGHT", group, "TOP", -(gap / 2), row)
    else
        button:SetPoint("TOPLEFT", group, "TOP", gap / 2, row)
        button:SetPoint("TOPRIGHT", group, "TOPRIGHT", -rightPad, row)
    end

    button:SetText(label)
    button:SetScript("OnClick", callback)
    AddTooltip(button, label, description)
    return button
end

local function PlaceGroup(column, group)
    local y = column.cursorY or -6
    group:SetPoint("TOPLEFT", column, "TOPLEFT", 0, y)
    group:SetPoint("TOPRIGHT", column, "TOPRIGHT", 0, y)
    column.cursorY = y - group:GetHeight() - 14
end

local function CreateSettingsCard(parent, title)
    local card = CreateBackdropFrame(parent)

    local heading = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -12)
    heading:SetText(title)

    local line = card:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -6)
    line:SetPoint("TOPRIGHT", card, "TOPRIGHT", -16, -6)
    line:SetHeight(1)
    line:SetColorTexture(0.48, 0.48, 0.48, 0.30)

    -- Important: cards are always full-width. Only the controls *inside* a
    -- card may use two columns. This prevents the whole settings page from
    -- becoming two competing columns that overflow the native Options canvas.
    local left = CreateFrame("Frame", nil, card)
    left:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -42)
    left:SetPoint("TOPRIGHT", card, "TOP", -8, -42)
    left:SetHeight(1)
    left.cursorY = -2

    local right = CreateFrame("Frame", nil, card)
    right:SetPoint("TOPLEFT", card, "TOP", 8, -42)
    right:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -42)
    right:SetHeight(1)
    right.cursorY = -2

    card.Left = left
    card.Right = right
    return card
end

local function FinishSettingsCard(card, extraBottom)
    local leftHeight = math.max(0, -(card.Left.cursorY or 0))
    local rightHeight = math.max(0, -(card.Right.cursorY or 0))
    local contentHeight = math.max(leftHeight, rightHeight, 24)

    card.Left:SetHeight(math.max(1, contentHeight))
    card.Right:SetHeight(math.max(1, contentHeight))
    card:SetHeight(44 + contentHeight + (extraBottom or 12))
end

local function PlaceSettingsCard(content, card)
    local y = content.cursorY or 0
    -- Keep the card inside the actual visible scroll viewport. A small inset on
    -- both sides prevents the card border and right-column controls from being
    -- clipped by Blizzard's scroll frame / scrollbar gutter.
    card:SetPoint("TOPLEFT", content, "TOPLEFT", 6, y)
    card:SetPoint("TOPRIGHT", content, "TOPRIGHT", -6, y)
    content.cursorY = y - card:GetHeight() - 14
end

if StaticPopupDialogs and not StaticPopupDialogs["SLEEKUF_LOAD_SAVED_PROFILE"] then
    StaticPopupDialogs["SLEEKUF_LOAD_SAVED_PROFILE"] = {
        text = "Load the complete saved Sleek Unit Frames profile |cffffd200%s|r into |cffffd200%s|r?\n\nThis replaces ALL current settings: positions, sizes, appearance, aura options, portrait options and behavior. The saved snapshot is not changed.",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function(_, sourceKey)
            if sourceKey then
                SUF:LoadProfileFrom(sourceKey)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

if StaticPopupDialogs and not StaticPopupDialogs["SLEEKUF_SAVE_CURRENT_PROFILE"] then
    StaticPopupDialogs["SLEEKUF_SAVE_CURRENT_PROFILE"] = {
        text = "Overwrite the saved Sleek Unit Frames profile for |cffffd200%s|r?\n\nThe snapshot will be replaced with your CURRENT complete setup. You can then make temporary changes and load this saved profile later to return here.",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function()
            SUF:SaveCurrentProfile()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

local function BuildPanel(panel)
    local addonIcon = panel:CreateTexture(nil, "ARTWORK")
    addonIcon:SetSize(40, 40)
    addonIcon:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -11)
    addonIcon:SetTexture(ADDON_ICON)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 72, -16)
    title:SetText("Sleek Unit Frames")

    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText(string.format("TBC Anniversary  •  Player / Target / Target of Target / Pet / Party  •  v%s", GetAddonVersion()))
    subtitle:SetTextColor(0.70, 0.72, 0.76)

    local defaults = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    defaults:SetSize(116, 24)
    defaults:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -28, -18)
    defaults:SetText("Reset all")
    defaults:SetScript("OnClick", function()
        SUF:ResetAll()
        SUF:RefreshSettingsPanel()
    end)
    AddTooltip(defaults, "Reset all", "Restore every Sleek Unit Frames option and frame position to its default value.")

    local separator = panel:CreateTexture(nil, "ARTWORK")
    separator:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -58)
    separator:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -24, -58)
    separator:SetHeight(1)
    separator:SetColorTexture(0.45, 0.45, 0.45, 0.42)

    local scroll = CreateFrame("ScrollFrame", "SleekUnitFramesSettingsScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 18, -70)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 14)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    content:SetSize(560, 1200)
    content.cursorY = -4
    scroll:SetScrollChild(content)

    local function UpdateContentWidth(width)
        width = tonumber(width) or scroll:GetWidth() or 0
        if width <= 0 then
            return
        end

        -- The scroll child must be NARROWER than the ScrollFrame viewport.
        -- UIPanelScrollFrameTemplate reserves space on the right for its native
        -- scrollbar, so using the full reported width caused our cards to sit
        -- underneath that gutter and appear clipped / out of bounds.
        -- Do not impose a large minimum here: the Settings canvas can vary with
        -- resolution/UI scale and should remain responsive.
        local scrollbarGutter = 30
        local usable = math.max(360, width - scrollbarGutter)
        content:SetWidth(usable)
    end

    scroll:SetScript("OnSizeChanged", function(_, width)
        if width and width > 100 then
            UpdateContentWidth(width)
        end
    end)
    panel._UpdateContentWidth = UpdateContentWidth

    ---------------------------------------------------------------------------
    -- PROFILES
    ---------------------------------------------------------------------------
    local profiles = CreateSettingsCard(content, "Profiles")
    AddReadOnlyProfileValue(profiles.Left, "Current character", function()
        return SUF:GetCurrentProfileKey()
    end)
    AddReadOnlyProfileValue(profiles.Left, "Saved snapshot", function()
        return SUF:HasSavedProfile(SUF:GetCurrentProfileKey()) and "Saved profile available" or "Not saved yet"
    end)

    local profileHint = profiles.Left:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    profileHint:SetPoint("TOPLEFT", profiles.Left, "TOPLEFT", 14, profiles.Left.cursorY + 3)
    profileHint:SetPoint("TOPRIGHT", profiles.Left, "TOPRIGHT", -14, profiles.Left.cursorY + 3)
    profileHint:SetJustifyH("LEFT")
    profileHint:SetJustifyV("TOP")
    profileHint:SetText("Your character keeps a live working setup automatically. Save creates an explicit snapshot you can return to later, even after moving or resizing frames.")
    profiles.Left.cursorY = profiles.Left.cursorY - 54

    local saveRow = profiles.Left.cursorY
    AddActionButton(profiles.Left, "Save current profile", "Save the CURRENT complete setup for this character. If a saved snapshot already exists, this overwrites it after confirmation.", function()
        local currentKey = SUF:GetCurrentProfileKey()
        if SUF:HasSavedProfile(currentKey) and StaticPopup_Show and StaticPopupDialogs and StaticPopupDialogs["SLEEKUF_SAVE_CURRENT_PROFILE"] then
            StaticPopup_Show("SLEEKUF_SAVE_CURRENT_PROFILE", currentKey)
        else
            SUF:SaveCurrentProfile()
        end
    end, saveRow, 1, 1)
    profiles.Left.cursorY = saveRow - 34

    AddProfileDropdown(profiles.Right, "Saved profile to load", "Choose any explicitly saved character profile, including this character's own snapshot.")
    local loadRow = profiles.Right.cursorY
    local loadButton = AddActionButton(profiles.Right, "Load selected profile", "Replace the current character's COMPLETE live setup with the selected saved snapshot. This copies every Sleek Unit Frames setting, not just frame positions and sizing.", function()
        local sourceKey = SUF.selectedProfileKey
        if not sourceKey then
            SUF:Print("No saved profile is available yet.")
            return
        end

        if StaticPopup_Show and StaticPopupDialogs and StaticPopupDialogs["SLEEKUF_LOAD_SAVED_PROFILE"] then
            StaticPopup_Show("SLEEKUF_LOAD_SAVED_PROFILE", sourceKey, SUF:GetCurrentProfileKey(), sourceKey)
        else
            SUF:LoadProfileFrom(sourceKey)
        end
    end, loadRow, 1, 1)
    profiles.Right.cursorY = loadRow - 34

    RegisterControl("__profiles", function()
        if SUF.selectedProfileKey and SUF:HasSavedProfile(SUF.selectedProfileKey) then
            loadButton:Enable()
        else
            loadButton:Disable()
        end
    end)

    FinishSettingsCard(profiles)
    PlaceSettingsCard(content, profiles)

    ---------------------------------------------------------------------------
    -- FRAMES
    ---------------------------------------------------------------------------
    local frames = CreateSettingsCard(content, "Frames")
    AddCheckbox(frames.Left, "enablePlayer", "Player frame", "Replace Blizzard's player unit frame.", function() SUF:ApplyAppearance() end)
    AddCheckbox(frames.Left, "enableTarget", "Target frame", "Replace Blizzard's target unit frame.", function() SUF:ApplyAppearance() end)
    AddCheckbox(frames.Left, "enableTargetTarget", "Target of Target frame", "Show a matching frame for the unit your current target is targeting.", function() SUF:ApplyAppearance() end)
    AddCheckbox(frames.Left, "enableFocus", "Focus frame", "Show a matching Target-of-Target-style frame for your current /focus unit.", function() SUF:ApplyAppearance() end)
    AddCheckbox(frames.Left, "enablePet", "Pet frame", "Replace Blizzard's pet unit frame.", function() SUF:ApplyAppearance() end)
    AddCheckbox(frames.Left, "enableParty", "Party frames", "Replace Blizzard's party frames with matching Sleek Unit Frames for Party 1-4.", function() SUF:ApplyAppearance() end)

    AddCheckbox(frames.Right, "locked", "Lock frames", "Lock the custom unit frames in place. Disable this to drag them.", function() SUF:SetLocked(SUF.db.locked, true) end)
    AddCheckbox(frames.Right, "previewMode", "Preview missing units", "Show placeholder Target, Target of Target, Focus, Pet and Party frames while arranging the layout.", function() SUF:ApplyAppearance() end)
    AddCheckbox(frames.Right, "editModeIntegration", "Blizzard Edit Mode integration", "When Blizzard Edit Mode opens, automatically expose Sleek Unit Frames for moving and mouse-wheel scaling. Closing Edit Mode restores your previous lock/preview state. Uses the public Edit Mode lifecycle instead of registering a taint-prone custom Blizzard system.", function(value)
        if not value and SUF.editModeBridgeActive then
            SUF:ExitBlizzardEditMode()
        elseif value and EditModeManagerFrame and EditModeManagerFrame.IsShown and EditModeManagerFrame:IsShown() then
            SUF:EnterBlizzardEditMode()
        end
    end)
    FinishSettingsCard(frames)
    PlaceSettingsCard(content, frames)

    ---------------------------------------------------------------------------
    -- PREVIEW CONTENT
    ---------------------------------------------------------------------------
    local preview = CreateSettingsCard(content, "Preview content")
    AddSlider(preview.Left, "previewTargetBuffs", "Preview target buffs", "Number of sample target buffs shown when Preview missing units is active and no live target exists.", 0, 12, 1, function(value) return tostring(value) end, function() SUF:UpdateTargetAuras() end)
    AddSlider(preview.Left, "previewTargetDebuffs", "Preview target debuffs", "Number of sample regular target debuffs shown in preview mode.", 0, 12, 1, function(value) return tostring(value) end, function() SUF:UpdateTargetAuras() end)
    AddSlider(preview.Left, "previewTargetDots", "Preview prioritized DoTs", "Number of sample emphasized personal DoTs shown in preview mode when My DoTs emphasis is enabled.", 0, 6, 1, function(value) return tostring(value) end, function() SUF:UpdateTargetAuras() end)

    AddSlider(preview.Right, "previewPartyBuffs", "Preview party buffs", "Number of sample buffs shown on each missing Party frame while preview mode is active.", 0, 8, 1, function(value) return tostring(value) end, function() SUF:UpdateAllPartyAuras(); SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true) end)
    AddSlider(preview.Right, "previewPartyDebuffs", "Preview party debuffs", "Number of sample debuffs shown on each missing Party frame while preview mode is active.", 0, 8, 1, function(value) return tostring(value) end, function() SUF:UpdateAllPartyAuras(); SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true) end)
    AddSlider(preview.Right, "previewComboPoints", "Preview combo points", "Number of combo points displayed on the sample Target while preview mode is active.", 0, 5, 1, function(value) return tostring(value) end, function() if SUF.UpdateComboPoints then SUF:UpdateComboPoints() end end)
    FinishSettingsCard(preview)
    PlaceSettingsCard(content, preview)

    ---------------------------------------------------------------------------
    -- STATUS & BEHAVIOR
    ---------------------------------------------------------------------------
    local status = CreateSettingsCard(content, "Status & behavior")
    AddCheckbox(status.Left, "smoothBars", "Smooth health / power animation", "Animate health and power changes instead of snapping immediately.", function() SUF:RefreshAllUnitFrames(true) end)
    AddCheckbox(status.Left, "showLevelBadge", "Level badge", "Show the unit level badge beside the portrait.", function() SUF:ApplyAppearance() end)
    AddCheckbox(status.Left, "showCombatIndicator", "Combat indicator", "Pulse the red portrait border and show the combat badge while the player is in combat.", function(value) SUF:UpdateCombatIndicator(value and InCombatLockdown and InCombatLockdown()) end)
    AddCheckbox(status.Left, "showLowHealthPulse", "Low health pulse", "Show a subtle pulsing red glow around the player frame when health drops below the configured threshold.", function() SUF:UpdateLowHealthIndicator() end)
    AddSlider(status.Left, "lowHealthThreshold", "Low health threshold", "Choose when the low-health pulse should begin.", 10, 60, 5, function(value) return string.format("%d%%", value) end, function() SUF:UpdateLowHealthIndicator() end)
    AddCheckbox(status.Left, "showRestingIndicator", "Resting indicator", "Show the gold resting treatment while resting in an inn or city.", function() SUF:UpdateRestingIndicator() end)
    AddDropdown(status.Left, "restingIndicatorStyle", "Resting indicator style", "Choose the Retail-inspired floating Z animation or the original compact resting icon.", RESTING_STYLE_OPTIONS, function() SUF:UpdateRestingIndicator() end)

    AddCheckbox(status.Right, "showPVPIndicator", "PvP faction icon", "Show the Alliance, Horde or free-for-all PvP badge on PvP-flagged units.", function() SUF:UpdatePVPStatuses() end)
    AddCheckbox(status.Right, "useCustomPVPIcons", "Custom PvP icon style", "Use Sleek Unit Frames custom Alliance, Horde and free-for-all PvP badges instead of the original in-game icons.", function() SUF:UpdatePVPStatuses() end)
    AddCheckbox(status.Right, "showPVPTimer", "PvP clear timer", "Show the local player's PvP clear countdown centered over the PvP faction icon.", function() SUF:UpdatePVPStatus("player") end)
    AddDropdown(status.Right, "pvpTimerTextColor", "PvP timer text color", "Choose the countdown text color drawn over the PvP crest.", PVP_TIMER_COLOR_OPTIONS, function() SUF:UpdatePVPStatus("player") end)
    AddCheckbox(status.Right, "showPetCombatIndicator", "Pet combat indicator", "Pulse the pet/demon portrait red and show the combat badge while it is in combat or your current target is targeting it.", function() SUF:UpdatePetCombatIndicator(true) end)
    AddCheckbox(status.Right, "showPetCombatFeedback", "Pet combat feedback", "Show damage, healing, dodge, parry, block, miss and similar combat feedback over the pet portrait.", function(value)
        if not value then
            local petFrame = SUF:GetUnitFrame("pet")
            if petFrame and petFrame.PetCombatFeedback and petFrame.PetCombatFeedback.feedbackText then
                petFrame.PetCombatFeedback.feedbackText:Hide()
            end
        end
    end)
    FinishSettingsCard(status)
    PlaceSettingsCard(content, status)

    ---------------------------------------------------------------------------
    -- APPEARANCE
    ---------------------------------------------------------------------------
    local appearance = CreateSettingsCard(content, "Appearance")
    AddSlider(appearance.Left, "wrapperOpacity", "Wrapper opacity", "Transparency of the dark parent wrapper behind the name, health and power bars.", 0, 100, 5, function(value) return string.format("%d%%", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(appearance.Right, "standardFrameBorderOpacity", "Player / Pet / Party border opacity", "Opacity of the subtle dark 1-2 px wrapper border on Player, Pet and Party frames. Target and Target of Target keep their own relation-border opacity.", 0, 100, 5, function(value) return string.format("%d%%", value) end, function() SUF:RefreshAllUnitFrames(true) end)
    AddDropdown(appearance.Left, "cornerStyle", "Corner roundness", "Choose how rounded the wrapper and bar corners should be.", CORNER_OPTIONS, function() SUF:ApplyAppearance() end)
    AddDropdown(appearance.Left, "portraitRingStyle", "Portrait ring style", "Color treatment for the asymmetric portrait frame. Sleek dark preserves the current look; Retail gold gives the portrait a more dominant warm metallic ring; Cool silver offers a neutral alternative.", PORTRAIT_RING_STYLE_OPTIONS, function() SUF:ApplyAppearance() end)
    AddDropdown(appearance.Left, "playerCornerOrnamentStyle", "Player portrait corner ornament", "Choose no ornament or a small Retail-inspired corner detail on the Player portrait only.", PLAYER_CORNER_ORNAMENT_OPTIONS, function() SUF:ApplyAppearance() end)
    AddDropdown(appearance.Left, "healthColorMode", "Health bar color", "Classic green, automatic class coloring, or a fixed class color.", HEALTH_COLOR_OPTIONS, function() SUF:RefreshAllUnitFrames(true) end)
    AddCheckbox(appearance.Left, "showAnimatedPortraits", "Animated 3D portraits", "Use live 3D unit models when the unit is available to the local game client. The addon automatically falls back to the normal static portrait when the model cannot be loaded, the player is offline, or the unit is not locally visible.", function() SUF:RefreshAllUnitFrames(true) end)
    AddCheckbox(appearance.Left, "animatedPortraitIdleMotion", "3D portrait idle movement", "Allow the 3D portrait to play its normal idle/fidget animation. Disable this for a calm neutral pose with the model frozen in place.", function() SUF:RefreshAllUnitFrames(true) end)
    AddSlider(appearance.Right, "portraitSize", "Portrait size", "Size of the unit portrait.", 76, 118, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(appearance.Right, "nameFontSize", "Name font size", "Font size used for unit names.", 12, 21, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(appearance.Right, "barFontSize", "Bar font size", "Font size used for health and power values.", 11, 19, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    FinishSettingsCard(appearance)
    PlaceSettingsCard(content, appearance)

    ---------------------------------------------------------------------------
    -- FRAME DIMENSIONS
    ---------------------------------------------------------------------------
    local dimensions = CreateSettingsCard(content, "Frame dimensions")

    AddSlider(dimensions.Left, "playerBodyWidth", "Player width", "Width of the Player name, health and power area. Portrait size is controlled separately under Appearance.", 150, 420, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(dimensions.Left, "playerScale", "Player scale", "Scale the complete custom Player frame.", 0.50, 1.20, 0.01, function(value) return string.format("%.2f", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(dimensions.Left, "petBodyWidth", "Pet width", "Width of the Pet name, health and power area.", 150, 420, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(dimensions.Left, "petScale", "Pet scale", "Scale the complete custom Pet frame.", 0.45, 1.00, 0.01, function(value) return string.format("%.2f", value) end, function() SUF:ApplyAppearance() end)

    AddSlider(dimensions.Right, "targetBodyWidth", "Target width", "Width of the Target name, health and power area. Target auras and the cast bar automatically follow this width.", 150, 420, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(dimensions.Right, "targetScale", "Target scale", "Scale the complete custom Target frame.", 0.50, 1.20, 0.01, function(value) return string.format("%.2f", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(dimensions.Right, "targetTargetBodyWidth", "Target of Target width", "Width of the Target of Target name, health and power area.", 150, 420, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(dimensions.Right, "targetTargetScale", "Target of Target scale", "Scale the complete custom Target of Target frame.", 0.40, 0.90, 0.01, function(value) return string.format("%.2f", value) end, function() SUF:ApplyAppearance() end)

    FinishSettingsCard(dimensions)
    PlaceSettingsCard(content, dimensions)

    ---------------------------------------------------------------------------
    -- FOCUS FRAME
    ---------------------------------------------------------------------------
    local focusFrame = CreateSettingsCard(content, "Focus frame")
    AddSlider(focusFrame.Left, "focusBodyWidth", "Focus width", "Width of the Focus name, health and power area.", 150, 420, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance() end)
    AddSlider(focusFrame.Left, "focusScale", "Focus scale", "Scale the complete Focus frame independently of Target of Target.", 0.40, 0.90, 0.01, function(value) return string.format("%.2f", value) end, function() SUF:ApplyAppearance() end)

    local focusHint = focusFrame.Right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    focusHint:SetPoint("TOPLEFT", focusFrame.Right, "TOPLEFT", 14, focusFrame.Right.cursorY + 1)
    focusHint:SetPoint("TOPRIGHT", focusFrame.Right, "TOPRIGHT", -14, focusFrame.Right.cursorY + 1)
    focusHint:SetJustifyH("LEFT")
    focusHint:SetJustifyV("TOP")
    focusHint:SetText("The Focus frame follows the same compact visual language as Target of Target, including level, raid marker and relation styling. Position it through Unlock + move or Blizzard Edit Mode.")
    focusFrame.Right.cursorY = focusFrame.Right.cursorY - 74
    FinishSettingsCard(focusFrame)
    PlaceSettingsCard(content, focusFrame)

    ---------------------------------------------------------------------------
    -- PARTY LAYOUT
    ---------------------------------------------------------------------------
    local partyLayout = CreateSettingsCard(content, "Party layout")
    AddSlider(partyLayout.Left, "partyBodyWidth", "Party frame width", "Shared width of the name, health and power area for Party 1-4.", 150, 420, 1, function(value) return string.format("%d px", value) end, function() SUF:ApplyAppearance(); SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true) end)
    AddSlider(partyLayout.Left, "partyScale", "Party frame scale", "Scale all four custom Party member frames together.", 0.40, 0.90, 0.01, function(value) return string.format("%.2f", value) end, function() SUF:ApplyAppearance(); SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true) end)
    AddSlider(partyLayout.Left, "partyVerticalSpacing", "Vertical gap", "Set the visible vertical gap between Party 1-4.", 0, 120, 1, function(value) return string.format("%d px", value) end, function(value) SUF:ApplyPartyVerticalSpacing(value) end)

    local partyLayoutHint = partyLayout.Right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    partyLayoutHint:SetPoint("TOPLEFT", partyLayout.Right, "TOPLEFT", 14, partyLayout.Right.cursorY + 1)
    partyLayoutHint:SetPoint("TOPRIGHT", partyLayout.Right, "TOPRIGHT", -14, partyLayout.Right.cursorY + 1)
    partyLayoutHint:SetJustifyH("LEFT")
    partyLayoutHint:SetJustifyV("TOP")
    partyLayoutHint:SetText("Party 1-4 share one width and scale, and move together as a single Party Group when frames are unlocked. The vertical gap only changes the spacing inside that group.")
    partyLayout.Right.cursorY = partyLayout.Right.cursorY - 62

    FinishSettingsCard(partyLayout)
    PlaceSettingsCard(content, partyLayout)

    ---------------------------------------------------------------------------
    -- PARTY INDICATORS
    ---------------------------------------------------------------------------
    local partyIndicators = CreateSettingsCard(content, "Party indicators")
    AddCheckbox(partyIndicators.Left, "showPartyPVPIndicator", "Party PvP crests", "Show the PvP faction crest on PvP-flagged Party 1-4 members. The existing custom/default PvP icon style setting is reused.", function()
        if SUF.UpdatePVPStatuses then SUF:UpdatePVPStatuses() end
    end)
    AddCheckbox(partyIndicators.Left, "showPartyTargets", "Party member targets", "Show a compact clickable unit frame for each party member's current target, including animated portrait, name, health and power.", function()
        SUF:ApplyAppearance()
    end)

    local partyIndicatorsHint = partyIndicators.Right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    partyIndicatorsHint:SetPoint("TOPLEFT", partyIndicators.Right, "TOPLEFT", 14, partyIndicators.Right.cursorY + 1)
    partyIndicatorsHint:SetPoint("TOPRIGHT", partyIndicators.Right, "TOPRIGHT", -14, partyIndicators.Right.cursorY + 1)
    partyIndicatorsHint:SetJustifyH("LEFT")
    partyIndicatorsHint:SetJustifyV("TOP")
    partyIndicatorsHint:SetText("Party targets use secure party1target-party4target unit frames: left-clicking them targets that unit, animated portraits follow the global 3D portrait setting, and right-side auras automatically leave room for the complete mini frame.")
    partyIndicators.Right.cursorY = partyIndicators.Right.cursorY - 74
    FinishSettingsCard(partyIndicators)
    PlaceSettingsCard(content, partyIndicators)

    ---------------------------------------------------------------------------
    -- TARGET AURAS
    ---------------------------------------------------------------------------
    local targetAuras = CreateSettingsCard(content, "Target auras")
    AddCheckbox(targetAuras.Left, "showTargetAuras", "Show buffs / debuffs", "Show the target's normal buffs and debuffs, regardless of who applied them. Timer overlays remain exclusive to your own effects.", function()
        SUF:UpdateTargetAuras()
    end)
    AddCheckbox(targetAuras.Left, "emphasizeOwnDebuffs", "Emphasize my DoTs", "Move damage-over-time effects applied by you or your pet into the dedicated larger priority row.", function() SUF:UpdateTargetAuras() end)
    AddSlider(targetAuras.Left, "targetAuraSize", "Regular aura icon size", "Scale normal target buffs, debuffs and non-prioritized DoTs.", 18, 40, 1, function(value) return string.format("%d px", value) end, function()
        local frame = SUF:GetUnitFrame("target")
        if frame then SUF:ApplyTargetExtrasLayout(frame) end
        SUF:UpdateTargetAuras()
    end)
    AddSlider(targetAuras.Left, "ownDebuffSize", "Prioritized DoT icon size", "Size of your emphasized target DoT icons.", 28, 60, 1, function(value) return string.format("%d px", value) end, function()
        local frame = SUF:GetUnitFrame("target")
        if frame then SUF:ApplyTargetExtrasLayout(frame) end
        SUF:UpdateTargetAuras()
    end)
    AddSlider(targetAuras.Left, "auraCornerRoundness", "Aura corner roundness", "Adjust the corner radius used by target and party aura icons. 0% is square; 50% is fully rounded.", 0, 50, 5, function(value) return string.format("%d%%", value) end, function()
        if SUF.RefreshAuraMasks then SUF:RefreshAuraMasks() end
        SUF:UpdateTargetAuras()
        if SUF.UpdateAllPartyAuras then SUF:UpdateAllPartyAuras() end
    end)

    AddCheckbox(targetAuras.Right, "showOwnBuffTimers", "Timers on my buffs", "Show remaining-duration text on helpful buffs applied by you or your pet.", function() SUF:RefreshAllAuras() end)
    AddCheckbox(targetAuras.Right, "showOwnDebuffTimers", "Timers on my debuffs", "Show remaining-duration text on your non-DoT harmful effects.", function() SUF:RefreshAllAuras() end)
    AddCheckbox(targetAuras.Right, "showOwnDotTimers", "Timers on my DoTs", "Show remaining-duration text on your damage-over-time effects.", function() SUF:RefreshAllAuras() end)
    AddCheckbox(targetAuras.Right, "showOwnAuraCooldownSwipe", "Clock wipe on enabled timers", "Show the radial cooldown wipe only on your own effects whose timer category is enabled.", function() SUF:RefreshAllAuras() end)
    AddSlider(targetAuras.Right, "targetAuraBuffLimit", "Max target buffs", "Maximum number of helpful target auras to display.", 1, 24, 1, function(value) return tostring(value) end, function() SUF:UpdateTargetAuras() end)
    AddSlider(targetAuras.Right, "targetAuraDebuffLimit", "Max target debuffs", "Maximum number of regular harmful target auras to display.", 1, 24, 1, function(value) return tostring(value) end, function() SUF:UpdateTargetAuras() end)
    AddSlider(targetAuras.Right, "targetAuraDotLimit", "Max prioritized DoTs", "Maximum number of your emphasized DoTs in the large priority row.", 1, 12, 1, function(value) return tostring(value) end, function() SUF:UpdateTargetAuras() end)
    FinishSettingsCard(targetAuras)
    PlaceSettingsCard(content, targetAuras)

    ---------------------------------------------------------------------------
    -- PARTY AURAS
    ---------------------------------------------------------------------------
    local partyAuras = CreateSettingsCard(content, "Party auras")
    AddCheckbox(partyAuras.Left, "showPartyAuras", "Show party buffs / debuffs", "Show helpful and harmful auras on each custom Party 1-4 frame. Timers follow the same 'my buffs/debuffs/DoTs' rules used for the target.", function()
        if SUF.UpdateAllPartyAuras then SUF:UpdateAllPartyAuras() end
        if SUF.ApplyAllPartyAuraLayouts then SUF:ApplyAllPartyAuraLayouts() end
        SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true)
    end)
    AddDropdown(partyAuras.Left, "partyAuraPosition", "Party aura position", "Place party buffs/debuffs to the right of the frame or in rows directly below the power bar.", PARTY_AURA_POSITION_OPTIONS, function()
        if SUF.ApplyAllPartyAuraLayouts then SUF:ApplyAllPartyAuraLayouts() end
        if SUF.UpdateAllPartyAuras then SUF:UpdateAllPartyAuras() end
        SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true)
    end)
    AddSlider(partyAuras.Left, "partyAuraSize", "Party aura icon size", "Size of buffs and debuffs shown for each party member.", 18, 40, 1, function(value) return string.format("%d px", value) end, function()
        if SUF.ApplyAllPartyAuraLayouts then SUF:ApplyAllPartyAuraLayouts() end
        if SUF.UpdateAllPartyAuras then SUF:UpdateAllPartyAuras() end
        SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true)
    end)

    AddSlider(partyAuras.Right, "partyAuraBuffLimit", "Max party buffs", "Maximum number of helpful auras shown for each party member.", 1, 12, 1, function(value) return tostring(value) end, function()
        SUF:UpdateAllPartyAuras()
        SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true)
    end)
    AddSlider(partyAuras.Right, "partyAuraDebuffLimit", "Max party debuffs", "Maximum number of harmful auras shown for each party member.", 1, 12, 1, function(value) return tostring(value) end, function()
        SUF:UpdateAllPartyAuras()
        SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true)
    end)

    local partyAuraHint = partyAuras.Left:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    partyAuraHint:SetPoint("TOPLEFT", partyAuras.Left, "TOPLEFT", 14, partyAuras.Left.cursorY + 4)
    partyAuraHint:SetPoint("TOPRIGHT", partyAuras.Left, "TOPRIGHT", -14, partyAuras.Left.cursorY + 4)
    partyAuraHint:SetJustifyH("LEFT")
    partyAuraHint:SetJustifyV("TOP")
    partyAuraHint:SetText("When placed below the power bar, the Party Group spacing automatically reserves enough room for the configured buff/debuff limits so adjacent party frames do not overlap the aura rows.")
    partyAuras.Left.cursorY = partyAuras.Left.cursorY - 60
    FinishSettingsCard(partyAuras)
    PlaceSettingsCard(content, partyAuras)

    ---------------------------------------------------------------------------
    -- TARGET EXTRAS
    ---------------------------------------------------------------------------
    local target = CreateSettingsCard(content, "Target extras")
    AddCheckbox(target.Left, "showTargetClassificationDragon", "Rare / elite dragon", "Show the custom elite / boss / rare dragon ring around classified NPC target portraits.", function() SUF:UpdateTargetClassification() end)
    AddCheckbox(target.Left, "showTargetCastbar", "Target cast bar", "Show the target's cast or channel bar.", function() SUF:UpdateTargetCastbar() end)
    AddCheckbox(target.Left, "showComboPoints", "Target combo points", "Show the player's current Rogue/Feral combo points on the Target frame when combo points exist.", function() if SUF.UpdateComboPoints then SUF:UpdateComboPoints() end end)
    AddSlider(target.Right, "targetHeaderReactionOpacity", "Target relation tint opacity", "Opacity of the friendly / neutral / hostile background tint on the Target, Target of Target and Focus wrappers. This does not affect the border. Set to 0% to disable only the background tint.", 0, 100, 5, function(value) return string.format("%d%%", value) end, function() SUF:RefreshAllUnitFrames(true) end)
    AddSlider(target.Right, "targetRelationBorderOpacity", "Target relation border opacity", "Opacity of the darker friendly / neutral / hostile border around the Target, Target of Target and Focus wrappers. This does not affect the background tint. Set to 0% to disable only the relation border.", 0, 100, 5, function(value) return string.format("%d%%", value) end, function() SUF:RefreshAllUnitFrames(true) end)
    FinishSettingsCard(target)
    PlaceSettingsCard(content, target)

    ---------------------------------------------------------------------------
    -- BAR TEXT
    ---------------------------------------------------------------------------
    local barText = CreateSettingsCard(content, "Bar text")
    AddCheckbox(barText.Left, "showHealthPercent", "Health percentage", "Show current health as a percentage.", function() SUF:RefreshAllUnitFrames(true) end)
    AddCheckbox(barText.Left, "showHealthValue", "Health value", "Show the exact health value whenever TBC exposes it.", function() SUF:RefreshAllUnitFrames(true) end)
    AddCheckbox(barText.Left, "centerUnavailableHealthPercent", "Center % when exact HP is hidden", "For non-group players where TBC hides exact HP, center the percentage instead of showing a dash.", function() SUF:RefreshAllUnitFrames(true) end)

    AddCheckbox(barText.Right, "showPowerPercent", "Power percentage", "Show current mana, rage or energy percentage.", function() SUF:RefreshAllUnitFrames(true) end)
    AddCheckbox(barText.Right, "showPowerValue", "Power value", "Show the current mana, rage or energy value.", function() SUF:RefreshAllUnitFrames(true) end)
    FinishSettingsCard(barText)
    PlaceSettingsCard(content, barText)

    ---------------------------------------------------------------------------
    -- ACTIONS
    ---------------------------------------------------------------------------
    local actions = CreateSettingsCard(content, "Actions")
    AddActionButton(actions.Left, "Unlock + move", "Unlock all custom frames and automatically preview missing units while arranging the layout.", function()
        SUF:SetLocked(false, true)
        SUF:RefreshSettingsPanel()
    end, -2, 1, 1)
    AddActionButton(actions.Left, "Reset positions", "Restore only the unit-frame screen positions.", function()
        SUF:ResetPositions()
        SUF:RefreshSettingsPanel()
    end, -34, 1, 1)
    actions.Left.cursorY = -66

    AddActionButton(actions.Right, "Toggle preview", "Show or hide placeholder Target, Target of Target, Focus, Pet and Party frames.", function()
        SUF.db.previewMode = not SUF.db.previewMode
        SUF:ApplyAppearance()
        SUF:RefreshSettingsPanel()
    end, -2, 1, 1)
    AddActionButton(actions.Right, "Reset appearance", "Restore appearance settings while preserving current positions.", function()
        SUF:ResetAppearance()
        SUF:RefreshSettingsPanel()
    end, -34, 1, 1)
    actions.Right.cursorY = -66
    FinishSettingsCard(actions, 6)
    PlaceSettingsCard(content, actions)

    content:SetHeight(math.max(900, -(content.cursorY or -900) + 6))

    panel.SettingsScrollFrame = scroll
    panel.SettingsContent = content
end

function SUF:CreateSettingsPanel()
    if self.SettingsCategory then
        return
    end

    if not Settings or not Settings.RegisterCanvasLayoutCategory then
        self:Print("The native Settings Canvas API is unavailable on this client.")
        return
    end

    self.SettingsControls = {}

    local panel = CreateFrame("Frame", "SleekUnitFramesSettingsPanel")
    panel.name = "Sleek Unit Frames"
    panel:SetSize(900, 720)
    BuildPanel(panel)

    -- Use Blizzard's documented Canvas signature for maximum Anniversary
    -- compatibility. The previous extra argument could leave the category
    -- selectable while its actual canvas failed to render.
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)

    self.SettingsPanel = panel
    self.SettingsCategory = category
    self.SettingsCategoryID = category:GetID()

    panel.OnCommit = function()
        -- Controls write immediately to the saved DB.
    end

    panel.OnDefault = function()
        SUF:ResetAll()
        SUF:RefreshSettingsPanel()
    end

    panel.OnRefresh = function()
        if panel._UpdateContentWidth then
            panel._UpdateContentWidth()
        end
        SUF:RefreshSettingsPanel()
    end

    panel:SetScript("OnShow", function()
        panel.OnRefresh()

        -- The native Settings canvas may finish sizing one frame after OnShow.
        -- Re-read the real viewport width on the next frame so UI scale and
        -- different window sizes cannot leave stale card dimensions behind.
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if panel:IsShown() and panel._UpdateContentWidth then
                    panel._UpdateContentWidth()
                end
            end)
        end
    end)
end

function SUF:RefreshSettingsPanel()
    if not self.SettingsControls or not self.db then
        return
    end

    self._refreshingSettingsPanel = true
    for _, refreshers in pairs(self.SettingsControls) do
        for _, refresh in ipairs(refreshers) do
            refresh()
        end
    end
    self._refreshingSettingsPanel = false
end

function SUF:OpenSettings()
    self:RefreshSettingsPanel()

    if self.SettingsCategoryID and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(self.SettingsCategoryID)
    else
        self:Print("Settings are not available yet. Try /reload.")
    end
end
