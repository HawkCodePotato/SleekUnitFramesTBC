local ADDON_NAME, SUF = ...

SUF = SUF or {}
_G.SleekUnitFramesTBC = SUF

SUF.DEFAULTS = {
    dbVersion = 83,
    layoutStorageVersion = 1,

    locked = true,
    previewMode = false,

    unlockPanelX = 0,
    unlockPanelY = 180,

    enablePlayer = true,
    enableTarget = true,
    enableTargetTarget = true,
    enableFocus = true,
    enablePet = true,
    enableParty = true,

    playerX = 28,
    playerY = -34,
    targetX = 405,
    targetY = -34,
    targetTargetX = 500,
    targetTargetY = -145,
    focusX = 500,
    focusY = -225,
    petX = 86,
    petY = -156,
    party1X = 28,
    party1Y = -270,
    party2X = 28,
    party2Y = -335,
    party3X = 28,
    party3Y = -400,
    party4X = 28,
    party4Y = -465,

    playerScale = 0.82,
    targetScale = 0.82,
    targetTargetScale = 0.55,
    focusScale = 0.55,
    petScale = 0.64,
    partyScale = 0.55,
    partyVerticalSpacing = 9,

    -- Legacy shared width retained for migration/backward compatibility.
    bodyWidth = 224,
    playerBodyWidth = 224,
    targetBodyWidth = 224,
    targetTargetBodyWidth = 224,
    focusBodyWidth = 224,
    petBodyWidth = 224,
    partyBodyWidth = 224,
    portraitSize = 92,
    nameFontSize = 17,
    barFontSize = 15,
    wrapperOpacity = 42,
    standardFrameBorderOpacity = 70,
    targetHeaderReactionOpacity = 45,
    targetRelationBorderOpacity = 70,
    healthColorMode = "GREEN",
    cornerStyle = "TIGHT",
    showAnimatedPortraits = false,
    animatedPortraitIdleMotion = false,
    portraitRingStyle = "SLEEK",
    restingIndicatorStyle = "RETAIL",
    playerCornerOrnamentStyle = "NONE",
    editModeIntegration = true,

    showLevelBadge = true,
    showCombatIndicator = true,
    showLowHealthPulse = true,
    lowHealthThreshold = 30,
    showPetCombatIndicator = true,
    showPetCombatFeedback = true,
    showRestingIndicator = true,
    showPVPIndicator = true,
    showPVPTimer = true,
    pvpTimerTextColor = "WHITE",
    useCustomPVPIcons = true,
    showTargetAuras = true,
    showComboPoints = true,
    showOwnTargetBuffs = false,
    showTargetClassificationDragon = true,
    emphasizeOwnDebuffs = true,
    showOwnDebuffTimers = true,
    showOwnDotTimers = true,
    showOwnBuffTimers = false,
    showOwnAuraCooldownSwipe = true,
    ownDebuffSize = 36,
    targetAuraSize = 22,
    targetAuraBuffLimit = 8,
    targetAuraDebuffLimit = 8,
    targetAuraDotLimit = 6,
    auraCornerRoundness = 20,

    showPartyAuras = false,
    partyAuraPosition = "RIGHT",
    partyAuraSize = 24,
    partyAuraBuffLimit = 6,
    partyAuraDebuffLimit = 6,
    showPartyPVPIndicator = true,
    showPartyTargets = true,

    -- Preview-only content controls. These let layout mode show realistic
    -- aura/combo density without requiring the corresponding live situation.
    previewTargetBuffs = 5,
    previewTargetDebuffs = 4,
    previewTargetDots = 3,
    previewPartyBuffs = 4,
    previewPartyDebuffs = 3,
    previewComboPoints = 3,

    showTargetCastbar = true,
    smoothBars = true,

    showHealthPercent = true,
    showHealthValue = true,
    centerUnavailableHealthPercent = true,
    showPowerPercent = true,
    showPowerValue = true,
}

local function CopyDefaults(source, target)
    for key, value in pairs(source) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                CopyDefaults(value, target[key])
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            CopyDefaults(value, target[key])
        end
    end
end

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, child in pairs(value) do
        copy[DeepCopy(key)] = DeepCopy(child)
    end
    return copy
end

local function IsFiniteNumber(value)
    value = tonumber(value)
    return value ~= nil and value == value and value > -10000000 and value < 10000000
end

-- Saved profile snapshots are deliberately rebuilt from DEFAULTS rather than
-- blindly cloning arbitrary runtime keys. This guarantees that every supported
-- Sleek Unit Frames option is included, missing fields receive their real
-- default, and stale implementation-only fields cannot leak between characters.
local function BuildCompleteProfileCopy(source)
    source = type(source) == "table" and source or {}
    local copy = {}

    for key, defaultValue in pairs(SUF.DEFAULTS) do
        local value = source[key]
        if value == nil then
            value = defaultValue
        end

        if type(defaultValue) == "number" then
            if IsFiniteNumber(value) then
                copy[key] = tonumber(value)
            else
                copy[key] = defaultValue
            end
        elseif type(defaultValue) == "boolean" then
            copy[key] = type(value) == "boolean" and value or defaultValue
        elseif type(defaultValue) == "string" then
            copy[key] = type(value) == "string" and value or defaultValue
        elseif type(defaultValue) == "table" then
            copy[key] = type(value) == "table" and DeepCopy(value) or DeepCopy(defaultValue)
        else
            copy[key] = DeepCopy(value)
        end
    end

    copy.dbVersion = SUF.DEFAULTS.dbVersion
    copy.layoutStorageVersion = SUF.DEFAULTS.layoutStorageVersion
    return copy
end

local function MigratePlayerCornerOrnamentSetting(profile)
    if type(profile) ~= "table" then
        return
    end

    if profile.playerCornerOrnamentStyle == nil then
        if profile.showPlayerCornerOrnament == true then
            profile.playerCornerOrnamentStyle = "SIMPLE"
        else
            profile.playerCornerOrnamentStyle = "NONE"
        end
    elseif profile.playerCornerOrnamentStyle == "ORNATE" then
        profile.playerCornerOrnamentStyle = "SIMPLE"
    end
end

-- Until v0.20.0 the individual frame mover saved GetTop()/GetLeft() values
-- without converting UIParent coordinates into the moved frame's effective
-- coordinate space. That mostly went unnoticed while the frame remained at
-- its live position, but restoring/copying a profile could send scaled frames
-- (especially Pet and Target of Target) toward the top of the screen.
--
-- For the four individually movable unit frames we can safely repair legacy
-- non-default Y anchors once. Defaults were written directly and therefore
-- were never affected by the bad SavePosition math.
local LEGACY_POSITION_UNITS = {
    { y = "playerY",       scale = "playerScale",       defaultY = "playerY" },
    { y = "targetY",       scale = "targetScale",       defaultY = "targetY" },
    { y = "targetTargetY", scale = "targetTargetScale", defaultY = "targetTargetY" },
    { y = "petY",          scale = "petScale",          defaultY = "petY" },
}

local function RepairLegacyIndividualFramePositions(profile)
    if type(profile) ~= "table" then
        return
    end

    local version = tonumber(profile.dbVersion) or 0
    if version >= 64 then
        return
    end

    local uiTop = UIParent and UIParent:GetTop()
    if not uiTop then
        return
    end

    for _, spec in ipairs(LEGACY_POSITION_UNITS) do
        local savedY = tonumber(profile[spec.y])
        local defaultY = tonumber(SUF.DEFAULTS[spec.defaultY])
        local scale = tonumber(profile[spec.scale]) or tonumber(SUF.DEFAULTS[spec.scale]) or 1

        -- An untouched default anchor is already in the correct SetPoint space.
        -- A non-default legacy anchor came through the old mover/save path.
        if savedY and defaultY and math.abs(savedY - defaultY) > 0.001 and scale > 0 and math.abs(scale - 1) > 0.001 then
            profile[spec.y] = savedY - (uiTop * ((1 / scale) - 1))
        end
    end
end

-- v0.22.28 repairs the position-storage regression introduced in v0.22.12.
-- Pet and Target of Target are deterministic to recover because that migration
-- itself altered those two anchors even when the user did not move them.
local function RepairPositionStorageV79(profile)
    if type(profile) ~= "table" then
        return
    end

    if tonumber(profile.layoutStorageVersion) and tonumber(profile.layoutStorageVersion) >= 1 then
        return
    end

    local version = tonumber(profile.dbVersion) or 0

    -- v0.22.12-v0.22.27 stored individual mover offsets in UIParent visual
    -- units and RestorePosition then scaled those offsets a second time. The
    -- v0.22.12 migration also multiplied existing Pet/Target-of-Target anchors
    -- by their frame scale. Those two units are therefore the only anchors we
    -- can repair deterministically without guessing whether Player/Target were
    -- moved before or after v0.22.12. Undo that known conversion once.
    if version >= 73 and version <= 78 then
        local specs = {
            { x = "targetTargetX", y = "targetTargetY", scale = "targetTargetScale", defaultX = "targetTargetX", defaultY = "targetTargetY" },
            { x = "petX",          y = "petY",          scale = "petScale",          defaultX = "petX",          defaultY = "petY" },
        }

        for _, spec in ipairs(specs) do
            local scale = tonumber(profile[spec.scale]) or tonumber(SUF.DEFAULTS[spec.scale]) or 1
            if scale > 0 and math.abs(scale - 1) > 0.001 then
                local savedX = tonumber(profile[spec.x])
                local savedY = tonumber(profile[spec.y])
                local defaultX = tonumber(SUF.DEFAULTS[spec.defaultX])
                local defaultY = tonumber(SUF.DEFAULTS[spec.defaultY])

                if savedX and defaultX and math.abs(savedX - defaultX) > 0.001 then
                    profile[spec.x] = savedX / scale
                end
                if savedY and defaultY and math.abs(savedY - defaultY) > 0.001 then
                    profile[spec.y] = savedY / scale
                end
            end
        end
    end

    profile.layoutStorageVersion = 1
end

local function GetCharacterProfileKey()
    local name, realm

    if UnitFullName then
        name, realm = UnitFullName("player")
    end
    if not name or name == "" then
        name = UnitName("player")
    end
    if not realm or realm == "" then
        realm = GetRealmName and GetRealmName() or nil
    end

    name = (name and name ~= "") and name or "Unknown Character"
    realm = (realm and realm ~= "") and realm or "Unknown Realm"
    return string.format("%s - %s", name, realm)
end

function SUF:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd9ad45SleekUF:|r " .. tostring(message))
end

function SUF:GetCurrentProfileKey()
    return self.currentProfileKey or GetCharacterProfileKey()
end

function SUF:GetProfileOptions(includeCurrent)
    local options = {}
    local profiles = self.dbRoot and self.dbRoot.savedProfiles
    local current = self:GetCurrentProfileKey()

    if type(profiles) ~= "table" then
        return options
    end

    for key, profile in pairs(profiles) do
        if type(key) == "string" and type(profile) == "table" and (includeCurrent or key ~= current) then
            local label = key
            if key == current then
                label = label .. " (this character)"
            end
            table.insert(options, { value = key, label = label })
        end
    end

    table.sort(options, function(a, b)
        if a.value == current then return true end
        if b.value == current then return false end
        return a.label < b.label
    end)
    return options
end

function SUF:HasSavedProfile(profileKey)
    local root = self.dbRoot
    local saved = root and root.savedProfiles
    return type(saved) == "table" and type(saved[profileKey or self:GetCurrentProfileKey()]) == "table"
end

function SUF:SaveCurrentProfile()
    if not self.db or not self.dbRoot then
        return false
    end
    if not self:IsLayoutChangeAllowed() then
        self:Print("Profiles cannot be saved during combat.")
        return false
    end

    local currentKey = self:GetCurrentProfileKey()
    self.dbRoot.savedProfiles = self.dbRoot.savedProfiles or {}

    -- Flush the live anchors first so a profile snapshot always represents what
    -- is actually on screen, not an older position left in SavedVariables.
    if self.CaptureLiveLayout then
        self:CaptureLiveLayout()
    end

    local snapshot = BuildCompleteProfileCopy(self.db)
    self.dbRoot.savedProfiles[currentKey] = snapshot
    self.selectedProfileKey = currentKey

    self:RefreshSettingsPanel()
    self:Print(string.format("Saved the complete profile for %s. Future changes can be reverted by loading this saved profile.", currentKey))
    return true
end

function SUF:LoadProfileFrom(sourceKey)
    if not self:IsLayoutChangeAllowed() then
        self:Print("Profiles cannot be loaded during combat.")
        return false
    end

    local root = self.dbRoot
    local currentKey = self:GetCurrentProfileKey()
    local savedProfiles = root and root.savedProfiles
    local source = savedProfiles and savedProfiles[sourceKey]

    if not source or type(source) ~= "table" then
        self:Print("That saved profile is no longer available.")
        return false
    end

    -- This is deliberately a full-table copy. Profiles include positions,
    -- dimensions, scales, appearance, aura behavior, portrait options, combat
    -- indicators and every other Sleek Unit Frames setting.
    local copied = DeepCopy(source)
    MigratePlayerCornerOrnamentSetting(copied)
    RepairLegacyIndividualFramePositions(copied)
    RepairPositionStorageV79(copied)
    CopyDefaults(self.DEFAULTS, copied)
    copied = BuildCompleteProfileCopy(copied)

    root.profiles[currentKey] = copied
    self.db = copied
    self.selectedProfileKey = sourceKey

    self:ApplyAppearance()
    self:RestorePositions()
    self:RefreshSettingsPanel()
    self:Print(string.format("Loaded the complete saved profile %s into %s. The saved snapshot itself was not changed.", sourceKey, currentKey))
    return true
end

function SUF:IsLayoutChangeAllowed()
    return not (InCombatLockdown and InCombatLockdown())
end

local unitKeys = {
    player = { x = "playerX", y = "playerY", scale = "playerScale", enabled = "enablePlayer" },
    target = { x = "targetX", y = "targetY", scale = "targetScale", enabled = "enableTarget" },
    targettarget = { x = "targetTargetX", y = "targetTargetY", scale = "targetTargetScale", enabled = "enableTargetTarget" },
    focus = { x = "focusX", y = "focusY", scale = "focusScale", enabled = "enableFocus" },
    pet = { x = "petX", y = "petY", scale = "petScale", enabled = "enablePet" },
    party1 = { x = "party1X", y = "party1Y", scale = "partyScale", enabled = "enableParty" },
    party2 = { x = "party2X", y = "party2Y", scale = "partyScale", enabled = "enableParty" },
    party3 = { x = "party3X", y = "party3Y", scale = "partyScale", enabled = "enableParty" },
    party4 = { x = "party4X", y = "party4Y", scale = "partyScale", enabled = "enableParty" },
}

SUF.UnitKeys = unitKeys

function SUF:GetUnitFrame(unit)
    return self.UnitFrames and self.UnitFrames[unit]
end

function SUF:GetUnitScale(unit)
    local keys = unitKeys[unit]
    return keys and self.db[keys.scale] or 1
end

local unitBodyWidthKeys = {
    player = "playerBodyWidth",
    target = "targetBodyWidth",
    targettarget = "targetTargetBodyWidth",
    focus = "focusBodyWidth",
    pet = "petBodyWidth",
    party1 = "partyBodyWidth",
    party2 = "partyBodyWidth",
    party3 = "partyBodyWidth",
    party4 = "partyBodyWidth",
}

function SUF:GetUnitBodyWidth(unit)
    local db = self.db or self.DEFAULTS
    local key = unitBodyWidthKeys[unit]
    local value = key and tonumber(db[key]) or nil
    if value then
        return value
    end

    -- Profiles from before v0.20.0 used one shared bodyWidth. Keep that as a
    -- final fallback so partially migrated/copied profiles retain their look.
    return tonumber(db.bodyWidth) or tonumber(self.DEFAULTS.bodyWidth) or 224
end

function SUF:SetUnitScale(unit, value, silent)
    if not self:IsLayoutChangeAllowed() then
        self:Print("Frames cannot be scaled during combat.")
        return false
    end

    local keys = unitKeys[unit]
    if not keys then
        return false
    end

    value = tonumber(value)
    if not value then
        return false
    end

    local scaleBounds = {
        player = { 0.50, 1.20 },
        target = { 0.50, 1.20 },
        targettarget = { 0.40, 0.90 },
        focus = { 0.40, 0.90 },
        pet = { 0.45, 1.00 },
        party1 = { 0.40, 0.90 },
        party2 = { 0.40, 0.90 },
        party3 = { 0.40, 0.90 },
        party4 = { 0.40, 0.90 },
    }
    local bounds = scaleBounds[unit] or { 0.45, 1.30 }
    value = math.max(bounds[1], math.min(bounds[2], value))
    self.db[keys.scale] = value

    local frame = self:GetUnitFrame(unit)
    if frame then
        frame:SetScale(value)
    end

    if not silent then
        self:Print(string.format("%s scale set to %.2f.", unit:gsub("^%l", string.upper), value))
    end

    self:RefreshSettingsPanel()
    return true
end

function SUF:SetUnitEnabled(unit, enabled)
    if not self:IsLayoutChangeAllowed() then
        self:Print("Unit frames cannot be enabled or disabled during combat.")
        return false
    end

    local keys = unitKeys[unit]
    if not keys then
        return false
    end

    self.db[keys.enabled] = enabled and true or false
    self:RefreshUnitWatch(unit)
    self:ApplyBlizzardFrameVisibility(unit)
    if type(unit) == "string" and unit:match("^party%d$") then
        self:RefreshPartyGroupMover()
    end
    self:RefreshSettingsPanel()
    return true
end

function SUF:RestorePosition(unit)
    local frame = self:GetUnitFrame(unit)
    local keys = unitKeys[unit]
    if not frame or not keys or not self.db then
        return
    end

    local x = tonumber(self.db[keys.x]) or tonumber(self.DEFAULTS[keys.x]) or 0
    local y = tonumber(self.db[keys.y]) or tonumber(self.DEFAULTS[keys.y]) or 0
    local scale = tonumber(self.db[keys.scale]) or tonumber(self.DEFAULTS[keys.scale]) or 1

    frame:SetScale(scale)
    if frame.SetUserPlaced then
        -- StartMoving() marks named frames as user-placed and WoW can restore
        -- those positions from its own layout cache. SleekUF owns persistence,
        -- so explicitly opt out to prevent two position stores fighting.
        frame:SetUserPlaced(false)
    end
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
    if frame.SetUserPlaced then
        frame:SetUserPlaced(false)
    end
end

function SUF:RestorePositions()
    self:RestorePosition("player")
    self:RestorePosition("target")
    self:RestorePosition("targettarget")
    self:RestorePosition("focus")
    self:RestorePosition("pet")
    self:RestorePosition("party1")
    self:RestorePosition("party2")
    self:RestorePosition("party3")
    self:RestorePosition("party4")

    if self.db and not self.db.locked then
        self:RefreshLockFramesButton()
        self:RefreshPartyGroupMover()
    end
end

function SUF:GetReservedPartyAuraHeight()
    if not self.db or not self.db.showPartyAuras or self.db.partyAuraPosition ~= "BELOW" then
        return 0
    end

    local size = math.max(18, math.min(40, math.floor((tonumber(self.db.partyAuraSize) or 24) + 0.5)))
    local gap = 3
    local rowGap = 4
    local holderWidth = tonumber(self.db.partyBodyWidth) or self.DEFAULTS.partyBodyWidth or 224

    local party1 = self:GetUnitFrame("party1")
    if party1 and party1.Power and party1.Power.GetWidth then
        local actualWidth = party1.Power:GetWidth()
        if actualWidth and actualWidth > 0 then
            holderWidth = actualWidth
        end
    end

    local perLine = math.max(1, math.floor((holderWidth + gap) / (size + gap)))
    local buffLimit = math.max(1, math.min(12, math.floor((tonumber(self.db.partyAuraBuffLimit) or 6) + 0.5)))
    local debuffLimit = math.max(1, math.min(12, math.floor((tonumber(self.db.partyAuraDebuffLimit) or 6) + 0.5)))

    local function CollectionHeight(count)
        if count <= 0 then
            return 0
        end
        local rows = math.max(1, math.ceil(count / perLine))
        return (rows * size) + ((rows - 1) * gap)
    end

    local buffHeight = CollectionHeight(buffLimit)
    local debuffHeight = CollectionHeight(debuffLimit)
    local total = buffHeight + debuffHeight
    if buffHeight > 0 and debuffHeight > 0 then
        total = total + rowGap
    end

    -- Match the visual 5 px gap used when the aura holder is anchored beneath
    -- the mana/power bar so Party 2 never touches Party 1's aura rows.
    if total > 0 then
        total = total + 5
    end
    return total
end

function SUF:ApplyPartyVerticalSpacing(value, silent)
    if not self:IsLayoutChangeAllowed() then
        self:Print("Party spacing cannot be changed during combat.")
        return false
    end

    if not self.db then
        return false
    end

    value = tonumber(value) or self.db.partyVerticalSpacing or self.DEFAULTS.partyVerticalSpacing
    value = math.max(0, math.min(120, value))
    self.db.partyVerticalSpacing = value

    local party1 = self:GetUnitFrame("party1")
    local frameHeight = party1 and party1:GetHeight() or 0
    if not frameHeight or frameHeight <= 0 then
        -- Keep this in sync with the unit-frame layout's portrait-driven minimum
        -- height. This fallback is only used before the frames have been laid out.
        frameHeight = (tonumber(self.db.portraitSize) or self.DEFAULTS.portraitSize) + 10
    end

    local scale = tonumber(self.db.partyScale) or self.DEFAULTS.partyScale
    local auraHeight = self:GetReservedPartyAuraHeight()
    local step = (frameHeight * scale) + (auraHeight * scale) + value
    local baseY = tonumber(self.db.party1Y) or self.DEFAULTS.party1Y

    -- Party 1 remains the anchor. Only the vertical coordinates of Party 2-4
    -- are changed, so any custom horizontal staggering is preserved.
    for i = 2, 4 do
        self.db["party" .. i .. "Y"] = baseY - ((i - 1) * step)
        self:RestorePosition("party" .. i)
    end

    self:RefreshPartyGroupMover()
    if not silent then
        self:RefreshSettingsPanel()
    end
    return true
end

function SUF:SavePosition(unit)
    local frame = self:GetUnitFrame(unit)
    local keys = unitKeys[unit]
    if not frame or not keys or not self.db then
        return false
    end

    -- All SleekUF frames are restored to one canonical anchor family. When the
    -- frame is already canonical, GetPoint gives us the exact SetPoint offsets
    -- directly and is independent of frame scale.
    local point, relativeTo, relativePoint, x, y = frame:GetPoint(1)
    if point == "TOPLEFT" and relativeTo == UIParent and relativePoint == "TOPLEFT" and IsFiniteNumber(x) and IsFiniteNumber(y) then
        self.db[keys.x] = tonumber(x)
        self.db[keys.y] = tonumber(y)
        return true
    end

    -- Defensive fallback for a frame anchored by older StartMoving behavior.
    -- GetLeft/GetTop are expressed in the moved frame's effective coordinate
    -- space, so convert the UIParent edge into those same local units. This is
    -- the scale-safe formula used before the v0.22.12 regression.
    local left = frame:GetLeft()
    local top = frame:GetTop()
    local uiLeft = UIParent:GetLeft() or 0
    local uiTop = UIParent:GetTop() or UIParent:GetHeight()

    if left and top then
        local uiScale = UIParent:GetEffectiveScale()
        if not uiScale or uiScale <= 0 then uiScale = 1 end
        local frameScale = frame:GetEffectiveScale()
        if not frameScale or frameScale <= 0 then frameScale = uiScale end
        local ratio = frameScale / uiScale
        if ratio <= 0 then ratio = 1 end

        local savedX = left - (uiLeft / ratio)
        local savedY = top - (uiTop / ratio)
        if IsFiniteNumber(savedX) and IsFiniteNumber(savedY) then
            self.db[keys.x] = savedX
            self.db[keys.y] = savedY
            return true
        end
    end

    return false
end

function SUF:CaptureLiveLayout()
    if not self.db then
        return
    end

    for _, unit in ipairs({ "player", "target", "targettarget", "focus", "pet", "party1", "party2", "party3", "party4" }) do
        self:SavePosition(unit)
    end
    self:SaveUnlockPanelPosition()
end

local function IsPartyUnitToken(unit)
    return type(unit) == "string" and unit:match("^party%d$") ~= nil
end

local function GetCursorUIPosition()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    if not scale or scale <= 0 then
        scale = 1
    end
    return x / scale, y / scale
end

-- WoW returns region coordinates in that region's own effective coordinate
-- space. Party frames are scaled, while the shared mover lives directly on
-- UIParent. Convert frame geometry into UIParent units before comparing or
-- drawing bounds. This is also the inverse factor we need when translating a
-- cursor delta back into a scaled frame's SetPoint offsets.
local function GetFrameToUIParentScale(frame)
    local uiScale = UIParent:GetEffectiveScale()
    if not uiScale or uiScale <= 0 then
        uiScale = 1
    end

    local frameScale = frame and frame:GetEffectiveScale() or uiScale
    if not frameScale or frameScale <= 0 then
        frameScale = uiScale
    end

    return frameScale / uiScale
end

function SUF:GetCursorUIPosition()
    return GetCursorUIPosition()
end

function SUF:GetFrameToUIParentScale(frame)
    return GetFrameToUIParentScale(frame)
end

local function GetFrameRectInUIParent(frame)
    if not frame then
        return nil
    end

    local left = frame:GetLeft()
    local top = frame:GetTop()
    local width = frame:GetWidth()
    local height = frame:GetHeight()
    if not left or not top or not width or not height then
        return nil
    end

    local ratio = GetFrameToUIParentScale(frame)
    local uiLeft = left * ratio
    local uiTop = top * ratio
    local uiWidth = width * ratio
    local uiHeight = height * ratio

    return uiLeft, uiTop, uiLeft + uiWidth, uiTop - uiHeight, ratio
end

function SUF:EnsurePartyGroupMover()
    if self.PartyGroupMover then
        return self.PartyGroupMover
    end

    local mover = CreateFrame("Frame", "SleekUnitFramesTBC_PartyGroupMover", UIParent)
    mover:SetFrameStrata("DIALOG")
    mover:SetFrameLevel(250)
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    mover:Hide()

    -- One translucent placement surface for the whole party stack. The real
    -- unit frames remain visible underneath while the group is being moved.
    local fill = mover:CreateTexture(nil, "BACKGROUND")
    fill:SetAllPoints()
    fill:SetColorTexture(0.08, 0.75, 0.22, 0.08)

    local function AddEdge(pointA, pointB, horizontal)
        local edge = mover:CreateTexture(nil, "OVERLAY")
        edge:SetPoint(pointA)
        edge:SetPoint(pointB)
        if horizontal then
            edge:SetHeight(3)
        else
            edge:SetWidth(3)
        end
        edge:SetColorTexture(0.18, 1.00, 0.42, 0.95)
        return edge
    end

    AddEdge("TOPLEFT", "TOPRIGHT", true)
    AddEdge("BOTTOMLEFT", "BOTTOMRIGHT", true)
    AddEdge("TOPLEFT", "BOTTOMLEFT", false)
    AddEdge("TOPRIGHT", "BOTTOMRIGHT", false)

    local labelBG = mover:CreateTexture(nil, "OVERLAY")
    labelBG:SetPoint("TOP", mover, "TOP", 0, -8)
    labelBG:SetSize(112, 24)
    labelBG:SetColorTexture(0.015, 0.07, 0.025, 0.92)

    local label = mover:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER", labelBG, "CENTER", 0, 0)
    label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    label:SetTextColor(0.62, 1.00, 0.68, 1)
    label:SetText("Party Group")

    local scaleText = mover:CreateFontString(nil, "OVERLAY")
    scaleText:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT", -6, 6)
    scaleText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    scaleText:SetTextColor(0.78, 1.00, 0.82, 1)
    mover.ScaleText = scaleText

    if mover.EnableMouseWheel then
        mover:EnableMouseWheel(true)
        mover:SetScript("OnMouseWheel", function(self, delta)
            if not SUF.db or SUF.db.locked or (InCombatLockdown and InCombatLockdown()) then
                return
            end
            local current = tonumber(SUF.db.partyScale) or tonumber(SUF.DEFAULTS.partyScale) or 0.55
            local step = IsShiftKeyDown and IsShiftKeyDown() and 0.05 or 0.02
            local value = math.max(0.40, math.min(0.90, current + ((delta or 0) * step)))
            SUF.db.partyScale = value
            for i = 1, 4 do
                local partyFrame = SUF:GetUnitFrame("party" .. i)
                if partyFrame then
                    partyFrame:SetScale(value)
                end
            end
            if self.ScaleText then
                self.ScaleText:SetText(string.format("%.0f%%", value * 100))
            end
            SUF:ApplyPartyVerticalSpacing(SUF.db.partyVerticalSpacing, true)
            SUF:RefreshPartyGroupMover()
            SUF:RefreshSettingsPanel()
        end)
    end

    mover:SetScript("OnShow", function(self)
        if self.ScaleText and SUF.db then
            self.ScaleText:SetText(string.format("%.0f%%", (tonumber(SUF.db.partyScale) or 0.55) * 100))
        end
    end)

    mover:SetScript("OnDragStart", function(self)
        if not SUF.db or SUF.db.locked or (InCombatLockdown and InCombatLockdown()) then
            return
        end

        local cursorX, cursorY = GetCursorUIPosition()
        local left, bottom = self:GetLeft(), self:GetBottom()
        if not cursorX or not cursorY or not left or not bottom then
            return
        end

        self.dragCursorX = cursorX
        self.dragCursorY = cursorY
        self.dragMoverLeft = left
        self.dragMoverBottom = bottom
        self.dragDX = 0
        self.dragDY = 0
        self.partyStart = {}

        for i = 1, 4 do
            local unit = "party" .. i
            local frame = SUF:GetUnitFrame(unit)
            local ratio = frame and GetFrameToUIParentScale(frame) or 1
            if not ratio or ratio <= 0 then
                ratio = 1
            end

            self.partyStart[unit] = {
                x = tonumber(SUF.db[unit .. "X"]) or 0,
                y = tonumber(SUF.db[unit .. "Y"]) or 0,
                ratio = ratio,
            }
        end

        -- The mover itself is in UIParent coordinates, but the Party frames are
        -- scaled. A 100px cursor move must therefore become 100px visually, not
        -- 100 * partyScale. Translate the UIParent delta through each frame's
        -- effective-scale ratio before changing its SetPoint offsets.
        self:SetScript("OnUpdate", function(groupMover)
            local currentX, currentY = GetCursorUIPosition()
            if not currentX or not currentY or not groupMover.dragCursorX or not groupMover.dragCursorY then
                return
            end

            local dx = currentX - groupMover.dragCursorX
            local dy = currentY - groupMover.dragCursorY
            groupMover.dragDX = dx
            groupMover.dragDY = dy

            for i = 1, 4 do
                local unit = "party" .. i
                local frame = SUF:GetUnitFrame(unit)
                local saved = groupMover.partyStart and groupMover.partyStart[unit]
                if frame and saved then
                    local ratio = saved.ratio or 1
                    if ratio <= 0 then
                        ratio = 1
                    end
                    frame:ClearAllPoints()
                    frame:SetPoint(
                        "TOPLEFT",
                        UIParent,
                        "TOPLEFT",
                        saved.x + (dx / ratio),
                        saved.y + (dy / ratio)
                    )
                end
            end

            local uiLeft = UIParent:GetLeft() or 0
            local uiBottom = UIParent:GetBottom() or 0
            groupMover:ClearAllPoints()
            groupMover:SetPoint(
                "BOTTOMLEFT",
                UIParent,
                "BOTTOMLEFT",
                (groupMover.dragMoverLeft - uiLeft) + dx,
                (groupMover.dragMoverBottom - uiBottom) + dy
            )
        end)
    end)

    mover:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)

        if SUF.db and self.partyStart then
            local dx = self.dragDX or 0
            local dy = self.dragDY or 0
            for i = 1, 4 do
                local unit = "party" .. i
                local saved = self.partyStart[unit]
                if saved then
                    local ratio = saved.ratio or 1
                    if ratio <= 0 then
                        ratio = 1
                    end
                    SUF.db[unit .. "X"] = saved.x + (dx / ratio)
                    SUF.db[unit .. "Y"] = saved.y + (dy / ratio)
                    SUF:RestorePosition(unit)
                end
            end
        end

        self.dragCursorX = nil
        self.dragCursorY = nil
        self.dragMoverLeft = nil
        self.dragMoverBottom = nil
        self.dragDX = nil
        self.dragDY = nil
        self.partyStart = nil
        SUF:RefreshPartyGroupMover()
        SUF:RefreshSettingsPanel()
    end)

    self.PartyGroupMover = mover
    return mover
end

function SUF:RefreshPartyGroupMover()
    if not self.db or not self.UnitFrames then
        return
    end

    local mover = self:EnsurePartyGroupMover()
    if self.db.locked or not self.db.enableParty or (InCombatLockdown and InCombatLockdown()) then
        mover:Hide()
        return
    end

    -- Measure the frames where they are actually rendered. GetLeft/GetTop are
    -- expressed in each scaled frame's own coordinate space, so normalize each
    -- rectangle back into UIParent units before building the shared outline.
    -- This keeps the mover glued around the visible party stack at every scale.
    local minLeft, maxRight, maxTop, minBottom

    local function IncludeRegion(region)
        if not region or (region.IsShown and not region:IsShown()) then
            return
        end
        local left, top, right, bottom = GetFrameRectInUIParent(region)
        if left and top and right and bottom then
            minLeft = minLeft and math.min(minLeft, left) or left
            maxRight = maxRight and math.max(maxRight, right) or right
            maxTop = maxTop and math.max(maxTop, top) or top
            minBottom = minBottom and math.min(minBottom, bottom) or bottom
        end
    end

    for i = 1, 4 do
        local frame = self:GetUnitFrame("party" .. i)
        if frame then
            IncludeRegion(frame)
            IncludeRegion(frame.PartyTarget)
            IncludeRegion(frame.PartyAuras)
        end
    end

    if not minLeft or not maxRight or not maxTop or not minBottom then
        mover:Hide()
        return
    end

    local padding = 5
    mover:ClearAllPoints()
    mover:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", minLeft - padding, minBottom - padding)
    mover:SetSize(
        math.max(90, (maxRight - minLeft) + padding * 2),
        math.max(50, (maxTop - minBottom) + padding * 2)
    )
    mover:Show()
end

function SUF:SaveUnlockPanelPosition()
    local panel = self.UnlockPanel
    if not panel or not self.db then
        return
    end

    local x, y = panel:GetCenter()
    local uiX, uiY = UIParent:GetCenter()
    if x and y and uiX and uiY then
        self.db.unlockPanelX = x - uiX
        self.db.unlockPanelY = y - uiY
    end
end

function SUF:EnsureLockFramesButton()
    if self.LockFramesButton and self.UnlockPanel then
        return self.LockFramesButton
    end

    local panel = CreateFrame("Frame", "SleekUnitFramesTBC_UnlockPanel", UIParent)
    panel:SetSize(430, 122)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:Hide()

    -- Keep the mover helper visually in the same family as the unit frames:
    -- flat dark glass, a restrained gold accent and no oversized Blizzard
    -- dialog ornaments.
    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.018, 0.022, 0.030, 0.95)

    local function AddPanelEdge(pointA, pointB, horizontal)
        local edge = panel:CreateTexture(nil, "BORDER")
        edge:SetPoint(pointA)
        edge:SetPoint(pointB)
        if horizontal then
            edge:SetHeight(1)
        else
            edge:SetWidth(1)
        end
        edge:SetColorTexture(0.38, 0.34, 0.25, 0.90)
        return edge
    end

    AddPanelEdge("TOPLEFT", "TOPRIGHT", true)
    AddPanelEdge("BOTTOMLEFT", "BOTTOMRIGHT", true)
    AddPanelEdge("TOPLEFT", "BOTTOMLEFT", false)
    AddPanelEdge("TOPRIGHT", "BOTTOMRIGHT", false)

    local topAccent = panel:CreateTexture(nil, "ARTWORK")
    topAccent:SetColorTexture(0.92, 0.66, 0.12, 0.86)
    topAccent:SetPoint("TOPLEFT", panel, "TOPLEFT", 1, -1)
    topAccent:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -1, -1)
    topAccent:SetHeight(2)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -14)
    title:SetText("Sleek Unit Frames")
    title:SetTextColor(1.0, 0.82, 0.16, 1)

    local statusBG = panel:CreateTexture(nil, "ARTWORK")
    statusBG:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -12)
    statusBG:SetSize(82, 20)
    statusBG:SetColorTexture(0.04, 0.22, 0.09, 0.88)

    local status = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("CENTER", statusBG, "CENTER", 0, 0)
    status:SetText("UNLOCKED")
    status:SetTextColor(0.52, 1.00, 0.63, 1)

    local description = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -42)
    description:SetText("Drag the green handles to reposition your unit frames.")
    description:SetTextColor(0.94, 0.94, 0.94, 1)

    local partyHint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    partyHint:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -61)
    partyHint:SetText("Party members move together as one group.")
    partyHint:SetTextColor(0.66, 0.69, 0.72, 1)

    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.31, 0.29, 0.24, 0.60)
    divider:SetPoint("LEFT", panel, "LEFT", 14, 0)
    divider:SetPoint("RIGHT", panel, "RIGHT", -14, 0)
    divider:SetPoint("BOTTOM", panel, "BOTTOM", 0, 40)
    divider:SetHeight(1)

    local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 17)
    hint:SetText("Drag this panel itself to move it out of the way.")
    hint:SetTextColor(0.52, 0.55, 0.58, 1)

    local button = CreateFrame("Button", "SleekUnitFramesTBC_LockFramesButton", panel, "UIPanelButtonTemplate")
    button:SetSize(124, 27)
    button:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -14, 8)
    button:SetText("Lock Frames")

    panel:SetScript("OnDragStart", function(self)
        if InCombatLockdown and InCombatLockdown() then
            return
        end
        self:StartMoving()
        if self.SetUserPlaced then self:SetUserPlaced(false) end
    end)

    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if self.SetUserPlaced then self:SetUserPlaced(false) end
        SUF:SaveUnlockPanelPosition()
    end)

    button:SetScript("OnClick", function()
        SUF:SetLocked(true)
    end)

    panel:RegisterEvent("PLAYER_REGEN_DISABLED")
    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
    panel:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            button:Disable()
            button:SetText("Lock after combat")
            status:SetText("COMBAT")
            status:SetTextColor(1.00, 0.42, 0.35, 1)
            statusBG:SetColorTexture(0.28, 0.035, 0.025, 0.90)
        else
            button:Enable()
            button:SetText("Lock Frames")
            status:SetText("UNLOCKED")
            status:SetTextColor(0.52, 1.00, 0.63, 1)
            statusBG:SetColorTexture(0.04, 0.22, 0.09, 0.88)
        end
    end)

    panel.StatusText = status
    panel.StatusBackground = statusBG
    self.UnlockPanel = panel
    self.LockFramesButton = button
    return button
end

function SUF:RefreshLockFramesButton()
    if not self.db then
        return
    end

    local button = self:EnsureLockFramesButton()
    local panel = self.UnlockPanel
    if not panel then
        return
    end

    if self.db.locked then
        panel:Hide()
        return
    end

    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "CENTER", self.db.unlockPanelX or 0, self.db.unlockPanelY or 180)

    if InCombatLockdown and InCombatLockdown() then
        button:Disable()
        button:SetText("Lock after combat")
        if panel.StatusText then
            panel.StatusText:SetText("COMBAT")
            panel.StatusText:SetTextColor(1.00, 0.42, 0.35, 1)
        end
        if panel.StatusBackground then
            panel.StatusBackground:SetColorTexture(0.28, 0.035, 0.025, 0.90)
        end
    else
        button:Enable()
        button:SetText("Lock Frames")
        if panel.StatusText then
            panel.StatusText:SetText("UNLOCKED")
            panel.StatusText:SetTextColor(0.52, 1.00, 0.63, 1)
        end
        if panel.StatusBackground then
            panel.StatusBackground:SetColorTexture(0.04, 0.22, 0.09, 0.88)
        end
    end

    panel:Show()
end

function SUF:SetLocked(locked, silent)
    if not self:IsLayoutChangeAllowed() then
        self:Print("Frames cannot be locked or unlocked during combat.")
        return false
    end

    -- Only flush live anchors for an explicit user lock action. ApplyAppearance
    -- calls SetLocked(..., true) while loading profiles; capturing there would
    -- overwrite the newly loaded profile with the previous character's live
    -- frame positions before RestorePositions gets a chance to apply it.
    if locked and not silent and self.CaptureLiveLayout then
        self:CaptureLiveLayout()
    end

    self.db.locked = locked and true or false

    -- Unlocking is layout-edit mode: always preview missing enabled units so
    -- every mover has something visible to drag. Locking returns to live state.
    self.db.previewMode = not self.db.locked
    self:RefreshUnitWatches()
    self:RefreshAllUnitFrames(true)

    if self.UnitFrames then
        for unit, frame in pairs(self.UnitFrames) do
            if frame.Mover then
                -- Party 1-4 deliberately do not get individual movers. The party
                -- stack is positioned through one shared Party Group mover.
                frame.Mover:SetShown(not self.db.locked and not IsPartyUnitToken(unit))
            end
        end
    end

    self:RefreshPartyGroupMover()

    if not silent then
        self:Print(self.db.locked and "Frames locked." or "Frames unlocked. Player, Target, Target of Target, Focus and Pet move individually; Party moves as one group.")
    end

    self:RefreshLockFramesButton()
    self:RefreshSettingsPanel()
    return true
end

local blizzardFrameNames = {
    player = "PlayerFrame",
    target = "TargetFrame",
    focus = "FocusFrame",
    pet = "PetFrame",
    party1 = "PartyMemberFrame1",
    party2 = "PartyMemberFrame2",
    party3 = "PartyMemberFrame3",
    party4 = "PartyMemberFrame4",
}

local blizzardPartyContainerNames = {
    "PartyFrame",
    "PartyMemberBackground",
    "CompactPartyFrame",
    "CompactPartyFrameMember1",
    "CompactPartyFrameMember2",
    "CompactPartyFrameMember3",
    "CompactPartyFrameMember4",
    "CompactPartyFrameMember5",
}

function SUF:GetBlizzardFrame(unit)
    if unit == "targettarget" then
        return _G.TargetFrameToT or _G.TargetofTargetFrame
    end
    local name = blizzardFrameNames[unit]
    return name and _G[name] or nil
end

function SUF:EnsureBlizzardFrameHider()
    if self.BlizzardFrameHider then
        return self.BlizzardFrameHider
    end

    self.BlizzardFrameHider = CreateFrame("Frame", "SleekUnitFramesTBC_BlizzardFrameHider", UIParent)
    self.BlizzardFrameHider:Hide()
    self.BlizzardOriginalParents = self.BlizzardOriginalParents or {}
    self.BlizzardOriginalAlpha = self.BlizzardOriginalAlpha or {}
    self.BlizzardOriginalMouse = self.BlizzardOriginalMouse or {}
    self.BlizzardSuppressionHooks = self.BlizzardSuppressionHooks or setmetatable({}, { __mode = "k" })
    return self.BlizzardFrameHider
end

function SUF:ShouldSuppressBlizzardFrame(cacheKey)
    if not self.db or not cacheKey then
        return false
    end

    if cacheKey:match("^party%-container:") then
        return self.db.enableParty and true or false
    end

    local keys = unitKeys[cacheKey]
    return keys and self.db[keys.enabled] and true or false
end

function SUF:RememberBlizzardFrameState(frame, cacheKey)
    if not frame or not cacheKey then
        return
    end

    self.BlizzardOriginalParents = self.BlizzardOriginalParents or {}
    self.BlizzardOriginalAlpha = self.BlizzardOriginalAlpha or {}
    self.BlizzardOriginalMouse = self.BlizzardOriginalMouse or {}

    if not self.BlizzardOriginalParents[cacheKey] then
        self.BlizzardOriginalParents[cacheKey] = frame:GetParent() or UIParent
    end
    if self.BlizzardOriginalAlpha[cacheKey] == nil and frame.GetAlpha then
        self.BlizzardOriginalAlpha[cacheKey] = frame:GetAlpha()
    end
    if self.BlizzardOriginalMouse[cacheKey] == nil and frame.IsMouseEnabled then
        self.BlizzardOriginalMouse[cacheKey] = frame:IsMouseEnabled() and true or false
    end
end

function SUF:SuppressBlizzardFrame(frame, cacheKey)
    if not frame or not self:ShouldSuppressBlizzardFrame(cacheKey) then
        return
    end

    self:RememberBlizzardFrameState(frame, cacheKey)

    if not self:IsLayoutChangeAllowed() then
        -- Do not mutate protected Blizzard unit-frame state while in combat.
        -- The frame was already made transparent/hidden during the last safe
        -- pass, so simply queue another assertion for combat end.
        self.pendingBlizzardVisibility = true
        return
    end

    -- Alpha zero is intentionally used in addition to the hidden parent. Some
    -- Anniversary UI controllers can re-parent or re-show stock unit frames
    -- after a zoning/loading transition. Keeping the stock frame transparent
    -- prevents the one-frame "ghost" even if Blizzard touches it again.
    if frame.SetAlpha and frame:GetAlpha() ~= 0 then
        frame:SetAlpha(0)
    end
    if frame.EnableMouse then
        frame:EnableMouse(false)
    end

    local hider = self:EnsureBlizzardFrameHider()
    if frame:GetParent() ~= hider then
        frame:SetParent(hider)
    end
    frame:Hide()
end

function SUF:InstallBlizzardSuppressionHook(frame, cacheKey)
    if not frame or not cacheKey then
        return
    end

    self:EnsureBlizzardFrameHider()
    if self.BlizzardSuppressionHooks[frame] then
        return
    end

    self.BlizzardSuppressionHooks[frame] = cacheKey
    frame:HookScript("OnShow", function(shownFrame)
        if SUF and SUF.SuppressBlizzardFrame then
            SUF:SuppressBlizzardFrame(shownFrame, cacheKey)
        end
    end)
end

function SUF:RestoreBlizzardFrameState(frame, cacheKey)
    if not frame or not cacheKey then
        return
    end

    local hider = self:EnsureBlizzardFrameHider()
    local originalParent = self.BlizzardOriginalParents and self.BlizzardOriginalParents[cacheKey] or UIParent
    if frame:GetParent() == hider then
        frame:SetParent(originalParent or UIParent)
    end

    if frame.SetAlpha then
        local originalAlpha = self.BlizzardOriginalAlpha and self.BlizzardOriginalAlpha[cacheKey]
        frame:SetAlpha(originalAlpha == nil and 1 or originalAlpha)
    end
    if frame.EnableMouse then
        local originalMouse = self.BlizzardOriginalMouse and self.BlizzardOriginalMouse[cacheKey]
        if originalMouse ~= nil then
            frame:EnableMouse(originalMouse)
        end
    end
end

function SUF:ApplyBlizzardFrameVisibility(unit)
    if not self.db then
        return
    end

    if not self:IsLayoutChangeAllowed() then
        self.pendingBlizzardVisibility = true
        return
    end

    local frame = self:GetBlizzardFrame(unit)
    local keys = unitKeys[unit]
    if not frame or not keys then
        return
    end

    local shouldHide = self.db[keys.enabled]
    self:InstallBlizzardSuppressionHook(frame, unit)

    if shouldHide then
        self:SuppressBlizzardFrame(frame, unit)
    else
        self:RestoreBlizzardFrameState(frame, unit)
        if unit == "player" or UnitExists(unit) then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

function SUF:ApplyBlizzardPartyContainerVisibility()
    if not self.db then
        return
    end

    if not self:IsLayoutChangeAllowed() then
        self.pendingBlizzardVisibility = true
        return
    end

    local shouldHide = self.db.enableParty
    self:EnsureBlizzardFrameHider()

    for _, name in ipairs(blizzardPartyContainerNames) do
        local frame = _G[name]
        if frame then
            local cacheKey = "party-container:" .. name
            self:InstallBlizzardSuppressionHook(frame, cacheKey)
            if shouldHide then
                self:SuppressBlizzardFrame(frame, cacheKey)
            else
                self:RestoreBlizzardFrameState(frame, cacheKey)
                -- Let Blizzard's own party/compact-frame controller decide the
                -- final shown state. Only provide a sensible fallback when no
                -- controller is available.
                if name == "PartyFrame" and IsInGroup and IsInGroup() and not (IsInRaid and IsInRaid()) then
                    frame:Show()
                end
            end
        end
    end

    if not shouldHide then
        if CompactRaidFrameManager_UpdateShown and CompactRaidFrameManager then
            CompactRaidFrameManager_UpdateShown(CompactRaidFrameManager)
        elseif CompactPartyFrame_Generate then
            CompactPartyFrame_Generate()
        end
    end
end

function SUF:ApplyBlizzardFramesVisibility()
    self.pendingBlizzardVisibility = nil
    self:ApplyBlizzardFrameVisibility("player")
    self:ApplyBlizzardFrameVisibility("target")
    self:ApplyBlizzardFrameVisibility("targettarget")
    self:ApplyBlizzardFrameVisibility("focus")
    self:ApplyBlizzardFrameVisibility("pet")
    self:ApplyBlizzardFrameVisibility("party1")
    self:ApplyBlizzardFrameVisibility("party2")
    self:ApplyBlizzardFrameVisibility("party3")
    self:ApplyBlizzardFrameVisibility("party4")
    self:ApplyBlizzardPartyContainerVisibility()
end

function SUF:ScheduleBlizzardFrameSuppressionPasses()
    if not C_Timer or not C_Timer.After then
        return
    end

    -- Blizzard can rebuild/re-anchor stock unit frames for a short window after
    -- PLAYER_ENTERING_WORLD. Re-assert our replacement state after those late
    -- UI updates as a belt-and-suspenders fallback to the OnShow hooks.
    for _, delay in ipairs({ 0, 0.10, 0.35, 0.80, 1.50 }) do
        C_Timer.After(delay, function()
            if SUF and SUF.db then
                SUF:ApplyBlizzardFramesVisibility()
            end
        end)
    end
end

function SUF:ApplyAppearance()
    if not self.db or not self.UnitFrames then
        return
    end

    if not self:IsLayoutChangeAllowed() then
        self.pendingAppearance = true
        return
    end

    self.pendingAppearance = nil

    for unit, frame in pairs(self.UnitFrames) do
        self:ApplyUnitFrameLayout(frame)
        frame:SetScale(self:GetUnitScale(unit))
    end

    self:SetLocked(self.db.locked, true)
    self:RefreshUnitWatches()
    self:RefreshAllUnitFrames(true)
    if self.UpdateCombatIndicator then self:UpdateCombatIndicator(self.playerInCombat == true) end
    if self.UpdatePetCombatIndicator then self:UpdatePetCombatIndicator(true) end
    if self.UpdateRestingIndicator then self:UpdateRestingIndicator() end
    self:ApplyBlizzardFramesVisibility()
    self:RefreshSettingsPanel()
end

function SUF:ResetPositions()
    if not self:IsLayoutChangeAllowed() then
        self:Print("Frames cannot be reset during combat.")
        return
    end

    self.db.playerX = self.DEFAULTS.playerX
    self.db.playerY = self.DEFAULTS.playerY
    self.db.targetX = self.DEFAULTS.targetX
    self.db.targetY = self.DEFAULTS.targetY
    self.db.targetTargetX = self.DEFAULTS.targetTargetX
    self.db.targetTargetY = self.DEFAULTS.targetTargetY
    self.db.focusX = self.DEFAULTS.focusX
    self.db.focusY = self.DEFAULTS.focusY
    self.db.petX = self.DEFAULTS.petX
    self.db.petY = self.DEFAULTS.petY
    self.db.party1X = self.DEFAULTS.party1X
    self.db.party1Y = self.DEFAULTS.party1Y
    self.db.party2X = self.DEFAULTS.party2X
    self.db.party2Y = self.DEFAULTS.party2Y
    self.db.party3X = self.DEFAULTS.party3X
    self.db.party3Y = self.DEFAULTS.party3Y
    self.db.party4X = self.DEFAULTS.party4X
    self.db.party4Y = self.DEFAULTS.party4Y
    self.db.partyVerticalSpacing = self.DEFAULTS.partyVerticalSpacing
    self:RestorePositions()
    self:Print("Frame positions reset.")
end

function SUF:ResetAppearance()
    if not self:IsLayoutChangeAllowed() then
        self:Print("Appearance cannot be reset during combat.")
        return
    end

    local preserved = {
        playerX = self.db.playerX,
        playerY = self.db.playerY,
        targetX = self.db.targetX,
        targetY = self.db.targetY,
        targetTargetX = self.db.targetTargetX,
        targetTargetY = self.db.targetTargetY,
        focusX = self.db.focusX,
        focusY = self.db.focusY,
        petX = self.db.petX,
        petY = self.db.petY,
        party1X = self.db.party1X,
        party1Y = self.db.party1Y,
        party2X = self.db.party2X,
        party2Y = self.db.party2Y,
        party3X = self.db.party3X,
        party3Y = self.db.party3Y,
        party4X = self.db.party4X,
        party4Y = self.db.party4Y,
        partyVerticalSpacing = self.db.partyVerticalSpacing,
    }

    for key, value in pairs(self.DEFAULTS) do
        self.db[key] = value
    end

    for key, value in pairs(preserved) do
        self.db[key] = value
    end

    self:ApplyAppearance()
    self:RestorePositions()
    self:Print("Appearance reset to defaults.")
end

function SUF:ResetAll()
    if not self:IsLayoutChangeAllowed() then
        self:Print("Frames cannot be reset during combat.")
        return
    end

    for key, value in pairs(self.DEFAULTS) do
        self.db[key] = value
    end

    self:ApplyAppearance()
    self:RestorePositions()
    self:Print("All Sleek Unit Frames settings reset.")
end

function SUF:SetPreviewMode(enabled)
    if not self:IsLayoutChangeAllowed() then
        self:Print("Preview mode cannot be changed during combat.")
        return false
    end

    self.db.previewMode = enabled and true or false
    self:RefreshUnitWatches()
    self:RefreshAllUnitFrames(true)
    self:RefreshSettingsPanel()
    return true
end

local function ShowHelp()
    SUF:Print("Commands:")
    SUF:Print("/suf - open settings")
    SUF:Print("/suf unlock - unlock all custom frames")
    SUF:Print("/suf lock - lock all custom frames")
    SUF:Print("/suf test - toggle Target/ToT/Focus/Pet/Party preview mode")
    SUF:Print("/suf reset - reset all settings")
end

SLASH_SLEEKUNITFRAMESTBC1 = "/suf"
SlashCmdList.SLEEKUNITFRAMESTBC = function(message)
    local command = message:match("^%s*(%S*)") or ""
    command = string.lower(command)

    if command == "" or command == "options" or command == "settings" or command == "config" then
        SUF:OpenSettings()
    elseif command == "unlock" then
        SUF:SetLocked(false)
    elseif command == "lock" then
        SUF:SetLocked(true)
    elseif command == "test" or command == "preview" then
        SUF:SetPreviewMode(not SUF.db.previewMode)
        SUF:Print(SUF.db.previewMode and "Preview mode enabled." or "Preview mode disabled.")
    elseif command == "reset" then
        SUF:ResetAll()
    else
        ShowHelp()
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:RegisterEvent("PLAYER_REGEN_ENABLED")
loader:RegisterEvent("PLAYER_LOGOUT")

loader:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        SleekUnitFramesTBCDB = SleekUnitFramesTBCDB or {}

        local currentProfileKey = GetCharacterProfileKey()
        local root = SleekUnitFramesTBCDB

        -- v0.18.0 changes the SavedVariables layout from one account-wide flat
        -- settings table into an account-wide collection of per-character
        -- profiles. The old flat table is preserved verbatim as the first
        -- profile for whichever character performs the upgrade.
        if type(root.profiles) ~= "table" then
            local legacyProfile = root
            root = {
                profileSchemaVersion = 1,
                profiles = {},
            }

            if type(legacyProfile) == "table" and next(legacyProfile) ~= nil then
                root.profiles[currentProfileKey] = legacyProfile
            end

            SleekUnitFramesTBCDB = root
        end

        -- v0.22.0 separates each character's live working configuration from
        -- explicit saved snapshots. Existing per-character profiles become the
        -- first saved snapshot automatically, so nobody loses the profile they
        -- were already using before the new Save/Load workflow was introduced.
        if (tonumber(root.profileSchemaVersion) or 1) < 2 or type(root.savedProfiles) ~= "table" then
            local savedProfiles = type(root.savedProfiles) == "table" and root.savedProfiles or {}
            for key, profile in pairs(root.profiles) do
                if savedProfiles[key] == nil and type(profile) == "table" then
                    savedProfiles[key] = DeepCopy(profile)
                end
            end
            root.savedProfiles = savedProfiles
            root.profileSchemaVersion = 2
        end

        root.profiles[currentProfileKey] = root.profiles[currentProfileKey] or {}
        local db = root.profiles[currentProfileKey]

        SUF.dbRoot = root
        SUF.currentProfileKey = currentProfileKey
        SUF.selectedProfileKey = SUF.selectedProfileKey or currentProfileKey

        -- v0.3 replaces the single-frame layout with Player, Target and Pet.
        -- Preserve the player's old screen position, but move the visual style
        -- to the new thicker, shorter Retail-inspired proportions.
        if not db.dbVersion or db.dbVersion < 3 then
            db.playerX = db.playerX or db.x or SUF.DEFAULTS.playerX
            db.playerY = db.playerY or db.y or SUF.DEFAULTS.playerY

            db.playerScale = SUF.DEFAULTS.playerScale
            db.targetScale = SUF.DEFAULTS.targetScale
            db.petScale = SUF.DEFAULTS.petScale
            db.bodyWidth = SUF.DEFAULTS.bodyWidth
            db.portraitSize = SUF.DEFAULTS.portraitSize
            db.nameFontSize = SUF.DEFAULTS.nameFontSize
            db.barFontSize = SUF.DEFAULTS.barFontSize
            db.showLevelBadge = SUF.DEFAULTS.showLevelBadge
            db.showTargetAuras = SUF.DEFAULTS.showTargetAuras
            db.showTargetCastbar = SUF.DEFAULTS.showTargetCastbar
            db.smoothBars = SUF.DEFAULTS.smoothBars
            db.enablePlayer = true
            db.enableTarget = true
            db.enablePet = true
            db.previewMode = false
            db.dbVersion = 3
        end

        -- v0.4 introduces the new portrait silhouette, transparent rounded name
        -- header, integrated level badge and player combat indicator. Preserve
        -- positions/scales from v0.3, but enable the two new visual cues.
        if db.dbVersion < 4 then
            db.showLevelBadge = true
            db.showCombatIndicator = true
            db.dbVersion = 4
        end

        -- v0.5 smooths the mask edges, rounds the portrait's top body-facing corner
        -- and refines the outer bar silhouette. Preserve saved positions/scales,
        -- while nudging new installs toward slightly tighter defaults.
        if db.dbVersion < 5 then
            db.dbVersion = 5
        end

        -- v0.6 further refines the silhouette: tighter header, custom top/bottom
        -- trailing bar corners, reduced portrait shadow and closer bar stacking.
        if db.dbVersion < 6 then
            db.dbVersion = 6
        end

        -- v0.7 introduces a soft parent wrapper behind the whole unit cluster,
        -- lowers the stacked bars slightly and removes the portrait/header seam.
        if db.dbVersion < 7 then
            db.dbVersion = 7
        end

        -- v0.8 lets the parent wrapper extend behind the portrait, removes the
        -- header fill background and lowers the entire cluster for a closer fit.
        if db.dbVersion < 8 then
            db.dbVersion = 8
        end

        -- v0.9 adds adjustable wrapper opacity, configurable health colors and
        -- replaces the custom canvas settings UI with Blizzard's native Settings controls.
        if db.dbVersion < 9 then
            if db.wrapperOpacity == nil then
                db.wrapperOpacity = 42
            end
            if db.healthColorMode == nil then
                db.healthColorMode = "GREEN"
            end
            db.dbVersion = 9
        end

        -- v0.10 moves bar rounding to the bar containers, improves combat and
        -- adds difficulty-colored levels plus PvP faction/timer indicators.
        if db.dbVersion < 10 then
            if db.showPVPIndicator == nil then
                db.showPVPIndicator = true
            end
            if db.showPVPTimer == nil then
                db.showPVPTimer = true
            end
            db.dbVersion = 10
        end

        -- v0.11 moves PvP faction badges onto portraits (Player + Target) and
        -- adds a dedicated larger/timed row for player-applied target debuffs.
        if db.dbVersion < 11 then
            if db.emphasizeOwnDebuffs == nil then
                db.emphasizeOwnDebuffs = true
            end
            if db.showOwnDebuffTimers == nil then
                db.showOwnDebuffTimers = true
            end
            if db.ownDebuffSize == nil then
                db.ownDebuffSize = 32
            end
            db.dbVersion = 11
        end

        -- v0.11.1 enlarges the portrait PvP badge and moves the player's PvP
        -- clear timer back to the right side of the name bar.
        if db.dbVersion < 12 then
            db.dbVersion = 12
        end

        -- v0.12 enlarges and repositions the portrait PvP badge, adds optional
        -- raid group indicators and introduces adjustable corner roundness.
        if db.dbVersion < 13 then
            if db.cornerStyle == nil then
                db.cornerStyle = "TIGHT"
            end
            db.dbVersion = 13
        end

        -- v0.12.1 tightens a few visual details: smaller corner masks, fully
        -- transparent header textures and slightly closer portrait/bar alignment.
        if db.dbVersion < 14 then
            db.dbVersion = 14
        end

        -- v0.12.2 removes the remaining right/bottom wrapper padding and left-aligns
        -- target aura rows instead of centering them.
        if db.dbVersion < 15 then
            db.dbVersion = 15
        end

        -- v0.12.3 adds a dedicated combat badge next to the level badge for a
        -- much clearer in-combat state.
        if db.dbVersion < 16 then
            db.dbVersion = 16
        end

        -- v0.12.4 refines the PvP badge placement for both player and mirrored
        -- target frames so it hugs the outer portrait ring more naturally.
        if db.dbVersion < 17 then
            db.dbVersion = 17
        end

        -- v0.12.5 fixes the mirrored target PvP badge placement, refines the
        -- combat badge, improves emphasized debuff styling and shows DEAD on
        -- zero-health units.
        if db.dbVersion < 18 then
            if db.ownDebuffSize == nil then
                db.ownDebuffSize = 36
            else
                db.ownDebuffSize = math.max(tonumber(db.ownDebuffSize) or 36, 36)
            end
            db.dbVersion = 18
        end

        -- v0.12.6 corrects the mirrored target PvP badge anchor so the badge
        -- sits on the outer edge of the target portrait instead of partially
        -- inside the portrait art.
        if db.dbVersion < 19 then
            db.dbVersion = 19
        end

        -- v0.12.7 nudges the mirrored target PvP badge further inward so it
        -- hugs the portrait ring more like the player-side badge.
        if db.dbVersion < 20 then
            db.dbVersion = 20
        end

        -- v0.12.8 moves the combat badge to the lower-right portrait corner,
        -- slims its border, and strengthens the red portrait combat pulse.
        if db.dbVersion < 21 then
            db.dbVersion = 21
        end

        -- v0.12.9 corrects the mirrored target PvP badge again so it hugs the
        -- outer top-right portrait edge instead of drifting back over the face.
        if db.dbVersion < 22 then
            db.dbVersion = 22
        end

        -- v0.13 adds Blizzard-style rare/elite classification dragons around
        -- the custom Target portrait.
        if db.dbVersion < 23 then
            if db.showTargetClassificationDragon == nil then
                db.showTargetClassificationDragon = true
            end
            db.dbVersion = 23
        end

        -- v0.13.2 replaces the Blizzard-derived crop with custom dragon ring
        -- artwork for elite / boss / rare classifications.
        if db.dbVersion < 24 then
            db.dbVersion = 24
        end

        -- v0.13.3 slightly enlarges and re-centers the custom classification
        -- ring so it fits around the target portrait more naturally.
        if db.dbVersion < 25 then
            db.dbVersion = 25
        end

        -- v0.13.4 increases the classification ring again and positions it so
        -- it rides the outer edge of the portrait more clearly.
        if db.dbVersion < 26 then
            db.dbVersion = 26
        end

        -- v0.13.5 nudges the classification ring farther right and enlarges it
        -- slightly so it matches the portrait's outer circle better.
        if db.dbVersion < 27 then
            db.dbVersion = 27
        end

        -- v0.13.6 rebuilds the custom classification textures using their real
        -- sprite bounds so the winged elite artwork is no longer clipped. The
        -- user's hand-tuned dragon position/size is preserved in UnitFrames.lua.
        if db.dbVersion < 28 then
            db.dbVersion = 28
        end

        -- v0.13.7 uses the user's newly split, equal-sized classification ring
        -- images so winged and non-winged variants stay aligned consistently.
        if db.dbVersion < 29 then
            db.dbVersion = 29
        end

        -- v0.13.8 swaps in the corrected 1:1 classification ring images so the
        -- dragon overlays render as proper circles instead of looking squished.
        if db.dbVersion < 30 then
            db.dbVersion = 30
        end

        -- v0.13.9 restores the winged gold dragon for bosses/world bosses,
        -- shows Blizzard's skull icon instead of ?? for boss-level targets,
        -- and preserves the user's final tuned dragon position/size.
        if db.dbVersion < 31 then
            db.dbVersion = 31
        end

        -- v0.14.0 keeps the boss skull inside the normal level tablet and
        -- allows PvP-flagged NPC targets to display the same PvP badge.
        if db.dbVersion < 32 then
            db.dbVersion = 32
        end

        -- v0.14.1 stops displaying Classic's normalized 0-100 health value as
        -- fake absolute HP for non-group player targets.
        if db.dbVersion < 33 then
            db.dbVersion = 33
        end

        -- v0.15.0 adds a secure Target of Target unit frame with its own saved
        -- position, scale, preview support and native settings controls.
        if db.dbVersion < 34 then
            if db.enableTargetTarget == nil then db.enableTargetTarget = true end
            if db.targetTargetX == nil then db.targetTargetX = SUF.DEFAULTS.targetTargetX end
            if db.targetTargetY == nil then db.targetTargetY = SUF.DEFAULTS.targetTargetY end
            if db.targetTargetScale == nil then db.targetTargetScale = SUF.DEFAULTS.targetTargetScale end
            db.dbVersion = 34
        end

        -- v0.15.1 adds radial cooldown swipes and broadens the player's target-
        -- aura timer treatment to helpful auras applied by the player/pet too.
        if db.dbVersion < 35 then
            if db.showOwnAuraCooldownSwipe == nil then
                db.showOwnAuraCooldownSwipe = true
            end
            db.dbVersion = 35
        end

        -- v0.15.2 filters target aura rows to effects applied by the player or
        -- their pet only; other players' buffs/debuffs are no longer displayed.
        if db.dbVersion < 36 then
            db.dbVersion = 36
        end

        -- v0.15.3 formats long aura timers as minutes:seconds while retaining
        -- whole seconds under one minute and tenths for the final five seconds.
        if db.dbVersion < 37 then
            db.dbVersion = 37
        end

        -- v0.15.4 makes long aura timers more compact: >5 minutes shows whole
        -- minutes, 1-5 minutes shows m:ss, under 60 seconds shows seconds.
        if db.dbVersion < 38 then
            db.dbVersion = 38
        end

        -- v0.15.5 centers the health percentage when Classic hides a player's
        -- absolute HP, and widens the target cast bar to the health/power width.
        if db.dbVersion < 39 then
            if db.centerUnavailableHealthPercent == nil then
                db.centerUnavailableHealthPercent = true
            end
            db.dbVersion = 39
        end

        -- v0.15.6 adds a native resting-status indicator to the custom player
        -- frame, including the original-style rest icon and layered gold pulse.
        if db.dbVersion < 40 then
            if db.showRestingIndicator == nil then
                db.showRestingIndicator = true
            end
            db.dbVersion = 40
        end

        -- v0.16.0 replaces the old one-control-per-row Vertical Layout settings
        -- page with a native Canvas Layout organized into two grouped columns.
        if db.dbVersion < 41 then
            db.dbVersion = 41
        end

        -- v0.16.1 fixes the Canvas settings geometry on Anniversary and makes
        -- the resting state substantially more visible.
        if db.dbVersion < 42 then
            db.dbVersion = 42
        end

        -- v0.16.2 replaces the small frame-attached lock button with a movable
        -- unlock control panel and makes unlocked mover overlays much clearer.
        if db.dbVersion < 43 then
            if db.unlockPanelX == nil then db.unlockPanelX = SUF.DEFAULTS.unlockPanelX end
            if db.unlockPanelY == nil then db.unlockPanelY = SUF.DEFAULTS.unlockPanelY end
            db.dbVersion = 43
        end

        -- v0.16.3 restructures the native settings canvas into full-width card
        -- wrappers. Each card may contain at most two internal control columns.
        if db.dbVersion < 44 then
            db.dbVersion = 44
        end

        -- v0.16.4 makes the settings cards responsive to the real Blizzard
        -- scroll viewport width and reserves the native scrollbar gutter.
        if db.dbVersion < 45 then
            db.dbVersion = 45
        end

        -- v0.16.5 separates helpful-buff visibility/timers from DoT/debuff
        -- timers and centers aura timer text directly on the icon.
        if db.dbVersion < 46 then
            if db.showOwnTargetBuffs == nil then
                db.showOwnTargetBuffs = false
            end
            if db.showOwnBuffTimers == nil then
                db.showOwnBuffTimers = false
            end
            db.dbVersion = 46
        end

        -- v0.16.6 restores normal target-aura visibility (all buffs/debuffs),
        -- while keeping duration text/clock wipes exclusive to the player's
        -- own effects. Buff, debuff and DoT timers can be toggled separately.
        if db.dbVersion < 47 then
            if db.showOwnDotTimers == nil then
                db.showOwnDotTimers = true
            end
            if db.showOwnDebuffTimers == nil then
                db.showOwnDebuffTimers = true
            end
            if db.showOwnBuffTimers == nil then
                db.showOwnBuffTimers = false
            end
            db.dbVersion = 47
        end

        -- v0.16.7 increases aura corner rounding and uses the same rounded
        -- alpha texture for the cooldown swipe where the client supports it.
        if db.dbVersion < 48 then
            db.dbVersion = 48
        end

        -- v0.16.8 adds pet/demon combat state feedback: a red portrait glow
        -- while the pet is fighting or being targeted, plus Blizzard-style
        -- UNIT_COMBAT feedback text for damage, dodge, parry, block, etc.
        if db.dbVersion < 49 then
            if db.showPetCombatIndicator == nil then
                db.showPetCombatIndicator = true
            end
            if db.showPetCombatFeedback == nil then
                db.showPetCombatFeedback = true
            end
            db.dbVersion = 49
        end

        -- v0.16.9 scales target aura countdown text with the actual icon size
        -- so larger prioritized auras get proportionally larger, clearer timers.
        if db.dbVersion < 50 then
            db.dbVersion = 50
        end

        -- v0.17.0 adds a separate scale for normal target buffs/debuffs and
        -- wraps aura rows automatically when larger icons no longer fit.
        if db.dbVersion < 51 then
            if db.targetAuraSize == nil then
                db.targetAuraSize = 22
            end
            db.dbVersion = 51
        end

        -- v0.17.1 colors NPC target names by reaction: green friendly,
        -- yellow neutral and red hostile/unfriendly.
        if db.dbVersion < 52 then
            db.dbVersion = 52
        end

        -- v0.17.2 grays NPC names when UnitIsTapDenied reports that the
        -- player/group is not eligible for that mob's tap.
        if db.dbVersion < 53 then
            db.dbVersion = 53
        end

        -- v0.17.3 adds a subtle red low-health pulse around the player frame,
        -- with a configurable health threshold.
        if db.dbVersion < 54 then
            if db.showLowHealthPulse == nil then
                db.showLowHealthPulse = true
            end
            if db.lowHealthThreshold == nil then
                db.lowHealthThreshold = 30
            end
            db.dbVersion = 54
        end

        -- v0.17.4 prioritizes live hostility for NPC name coloring so neutral
        -- NPCs turn red as soon as they become enemies after being attacked.
        if db.dbVersion < 55 then
            db.dbVersion = 55
        end

        -- v0.17.5 brightens Hunter and Shaman class-health colors so they
        -- are easier to distinguish from the default green health and blue mana bars.
        if db.dbVersion < 56 then
            db.dbVersion = 56
        end

        -- v0.17.6 adds player/target group-leader portrait markers and
        -- Blizzard-style offline state handling for disconnected target players.
        if db.dbVersion < 57 then
            db.dbVersion = 57
        end

        -- v0.18.0 stores settings per character. Account-wide SavedVariables
        -- now contain a profile table keyed by Character - Realm, while the
        -- active character still exposes SUF.db as a normal settings table.
        if db.dbVersion < 58 then
            db.dbVersion = 58
        end

        -- v0.19.0 adds matching secure Party 1-4 unit frames with individual
        -- positions, a shared scale, preview support and Blizzard-party-frame
        -- replacement. Existing character profiles inherit sensible defaults.
        if db.dbVersion < 59 then
            if db.enableParty == nil then db.enableParty = true end
            if db.partyScale == nil then db.partyScale = SUF.DEFAULTS.partyScale end
            for i = 1, 4 do
                local xKey, yKey = "party" .. i .. "X", "party" .. i .. "Y"
                if db[xKey] == nil then db[xKey] = SUF.DEFAULTS[xKey] end
                if db[yKey] == nil then db[yKey] = SUF.DEFAULTS[yKey] end
            end
            db.dbVersion = 59
        end

        -- v0.19.2 adds a shared vertical-gap control for the custom party
        -- frames. For existing profiles, derive a sensible starting value from
        -- the current Party 1 -> Party 2 distance so updating does not suddenly
        -- rearrange a layout that was already tuned by hand.
        if db.dbVersion < 60 then
            if db.partyVerticalSpacing == nil then
                local p1y = tonumber(db.party1Y)
                local p2y = tonumber(db.party2Y)
                local scale = tonumber(db.partyScale) or SUF.DEFAULTS.partyScale
                local portrait = tonumber(db.portraitSize) or SUF.DEFAULTS.portraitSize
                local estimatedFrameHeight = portrait + 10
                if p1y and p2y then
                    local currentStep = math.abs(p2y - p1y)
                    db.partyVerticalSpacing = math.max(0, math.min(120, currentStep - (estimatedFrameHeight * scale)))
                else
                    db.partyVerticalSpacing = SUF.DEFAULTS.partyVerticalSpacing
                end
            end
            db.dbVersion = 60
        end

        -- v0.19.3 makes Party 1-4 a single draggable group, expands the party
        -- vertical-gap range, and rebuilds the unlock helper panel layout.
        if db.dbVersion < 61 then
            db.dbVersion = 61
        end

        -- v0.19.4 fixes the Party Group mover's scaled-coordinate bug by
        -- deriving bounds from saved UIParent anchors and dragging via cursor
        -- deltas. It also replaces the unlock helper with a compact clean panel.
        if db.dbVersion < 62 then
            db.dbVersion = 62
        end

        -- v0.20.0 replaces the old shared bar width with independent widths for
        -- Player, Target, Target of Target, Pet and the shared Party frames.
        -- Existing profiles inherit their previous bodyWidth for every type so
        -- the visual layout is unchanged until the user adjusts a slider.
        if db.dbVersion < 63 then
            local legacyWidth = tonumber(db.bodyWidth) or SUF.DEFAULTS.bodyWidth
            if db.playerBodyWidth == nil then db.playerBodyWidth = legacyWidth end
            if db.targetBodyWidth == nil then db.targetBodyWidth = legacyWidth end
            if db.targetTargetBodyWidth == nil then db.targetTargetBodyWidth = legacyWidth end
            if db.petBodyWidth == nil then db.petBodyWidth = legacyWidth end
            if db.partyBodyWidth == nil then db.partyBodyWidth = legacyWidth end
            db.dbVersion = 63
        end

        -- v0.20.1 fixes the coordinate-space math used when individual frame
        -- movers save their positions. This also repairs legacy non-default
        -- Player/Target/Target-of-Target/Pet anchors so profile copies restore
        -- the same locations instead of scaled frames jumping toward the top.
        if db.dbVersion < 64 then
            RepairLegacyIndividualFramePositions(db)
            db.dbVersion = 64
        end

        -- v0.21.0 adds optional live 3D portraits. Keep it opt-in so existing
        -- profiles preserve their static portrait behavior until enabled.
        if db.dbVersion < 65 then
            if db.showAnimatedPortraits == nil then
                db.showAnimatedPortraits = false
            end
            db.dbVersion = 65
        end

        -- v0.21.1 defaults 3D portraits to a neutral frozen pose. Motion can
        -- still be enabled explicitly for players who prefer idle/fidgeting.
        if db.dbVersion < 66 then
            if db.animatedPortraitIdleMotion == nil then
                db.animatedPortraitIdleMotion = false
            end
            db.dbVersion = 66
        end

        -- v0.22.0 adds explicit profile snapshots, configurable target aura
        -- limits/roundness, and optional party-member aura displays.
        if db.dbVersion < 67 then
            db.dbVersion = 67
        end
        if db.dbVersion < 68 then
            if db.targetAuraBuffLimit == nil then db.targetAuraBuffLimit = 8 end
            if db.targetAuraDebuffLimit == nil then db.targetAuraDebuffLimit = 8 end
            if db.targetAuraDotLimit == nil then db.targetAuraDotLimit = 6 end
            if db.auraCornerRoundness == nil then db.auraCornerRoundness = 20 end
            db.dbVersion = 68
        end
        if db.dbVersion < 69 then
            if db.showPartyAuras == nil then db.showPartyAuras = false end
            if db.partyAuraSize == nil then db.partyAuraSize = 24 end
            if db.partyAuraBuffLimit == nil then db.partyAuraBuffLimit = 6 end
            if db.partyAuraDebuffLimit == nil then db.partyAuraDebuffLimit = 6 end
            db.dbVersion = 69
        end
        if db.dbVersion < 70 then
            db.dbVersion = 70
        end

        if db.dbVersion < 71 then
            if db.useCustomPVPIcons == nil then db.useCustomPVPIcons = true end
            db.dbVersion = 71
        end

        -- v0.22.9 fixes the actual live PvP texture assignment.
        if db.dbVersion < 72 then
            if db.useCustomPVPIcons == nil then db.useCustomPVPIcons = true end
            db.dbVersion = 72
        end

        -- v0.22.12 attempted a scaled-frame position repair that later proved
        -- to convert canonical SetPoint offsets into visual UIParent units.
        -- Profiles that have not yet crossed that migration still contain the
        -- older canonical offsets, so preserve them exactly.
        if db.dbVersion < 73 then
            db.layoutStorageVersion = 1
            db.dbVersion = 73
        end

        -- v0.22.13 adds a selectable PvP timer text color. Existing profiles
        -- default to the new soft-white treatment for better crest contrast.
        if db.dbVersion < 74 then
            if db.pvpTimerTextColor == nil then db.pvpTimerTextColor = "WHITE" end
            db.dbVersion = 74
        end

        -- v0.22.17 replaces the old pill-shaped target reaction strip with a
        -- full-width subtle header tint and adds a user-controlled opacity.
        if db.dbVersion < 75 then
            if db.targetHeaderReactionOpacity == nil then db.targetHeaderReactionOpacity = 45 end
            db.dbVersion = 75
        end
        if db.dbVersion < 76 then
            if db.targetRelationBorderOpacity == nil then db.targetRelationBorderOpacity = 70 end
            db.dbVersion = 76
        end

        -- v0.22.22 expands Party frames with optional PvP crests, party-member
        -- target portraits, and selectable right/below aura layouts.
        if db.dbVersion < 77 then
            if db.partyAuraPosition == nil then db.partyAuraPosition = "RIGHT" end
            if db.showPartyPVPIndicator == nil then db.showPartyPVPIndicator = true end
            if db.showPartyTargets == nil then db.showPartyTargets = true end
            db.dbVersion = 77
        end

        -- v0.22.24 adds the neutral wrapper border control for Player/Pet/Party.
        if db.dbVersion < 78 then
            if db.standardFrameBorderOpacity == nil then db.standardFrameBorderOpacity = 70 end
            db.dbVersion = 78
        end

        -- v0.22.28 hardens frame/profile persistence. Undo the deterministic
        -- Pet/Target-of-Target coordinate corruption introduced in v0.22.12,
        -- then mark positions as canonical TOPLEFT/UIParent offsets.
        if db.dbVersion < 79 then
            RepairPositionStorageV79(db)
            db.layoutStorageVersion = 1
            db.dbVersion = 79
        end

        -- v0.22.30 adds the safe Blizzard Edit Mode bridge, Retail-inspired
        -- resting Z animation, portrait-ring style presets and an optional
        -- Player-only corner ornament. Existing profiles preserve the current
        -- dark portrait treatment while gaining the Edit Mode bridge by default.
        if db.dbVersion < 80 then
            if db.portraitRingStyle == nil then db.portraitRingStyle = "SLEEK" end
            if db.restingIndicatorStyle == nil then db.restingIndicatorStyle = "RETAIL" end
            if db.showPlayerCornerOrnament == nil then db.showPlayerCornerOrnament = false end
            if db.editModeIntegration == nil then db.editModeIntegration = true end
            db.dbVersion = 80
        end

        -- v0.22.31 turns the Player corner ornament into a three-style option.
        -- Migrate the v0.22.30 boolean without changing what existing users see.
        if db.dbVersion < 81 then
            MigratePlayerCornerOrnamentSetting(db)
            db.dbVersion = 81
        end

        -- v0.22.34 retires the larger image ornament and normalizes any old
        -- saved ORNATE selections back to the cleaner SIMPLE variant.
        if db.dbVersion < 82 then
            MigratePlayerCornerOrnamentSetting(db)
            db.dbVersion = 82
        end

        -- v0.22.41 adds the Focus unit frame, target combo points and richer
        -- preview-content controls. CopyDefaults below fills all new fields;
        -- bumping the schema version makes the migration explicit in profiles.
        if db.dbVersion < 83 then
            db.dbVersion = 83
        end

        CopyDefaults(SUF.DEFAULTS, db)
        -- Normalize the live per-character profile through the same complete
        -- schema used for explicit snapshots. This guarantees every supported
        -- setting has a valid stored value before any frame is created.
        db = BuildCompleteProfileCopy(db)
        root.profiles[currentProfileKey] = db
        SUF.db = db

        SUF:CreateUnitFrames()
        SUF:CreateSettingsPanel()
        SUF:ApplyAppearance()
        SUF:RestorePositions()
        if SUF.InitializeEditModeIntegration then
            SUF:InitializeEditModeIntegration()
        end
    elseif event == "PLAYER_ENTERING_WORLD" and SUF.db then
        -- Reassert SavedVariables anchors after the login/world transition.
        -- This is intentionally redundant with ADDON_LOADED: named movable
        -- frames can otherwise be touched by WoW's layout-cache/login pass.
        if SUF:IsLayoutChangeAllowed() then
            SUF:RestorePositions()
        end
        SUF:RefreshUnitWatches()
        SUF:ApplyBlizzardFrameVisibility()
        SUF:ScheduleBlizzardFrameSuppressionPasses()
        SUF:RefreshAllUnitFrames(true)
    elseif event == "PLAYER_LOGOUT" and SUF.db then
        -- Last-chance persistence flush. Normal dragging commits immediately,
        -- but this also captures any legitimate anchor change from elsewhere.
        SUF:CaptureLiveLayout()
    elseif event == "PLAYER_REGEN_ENABLED" and SUF.db then
        if SUF.pendingBlizzardVisibility then
            SUF:ApplyBlizzardFramesVisibility()
        end
        if SUF.pendingAppearance then
            SUF:ApplyAppearance()
        end
    end
end)

-- v0.13.1 migration
