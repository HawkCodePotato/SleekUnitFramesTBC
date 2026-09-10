local ADDON_NAME, SUF = ...

local ADDON_MEDIA = "Interface\\AddOns\\SleekUnitFramesTBC\\Media\\"
local HEADER_MASK = ADDON_MEDIA .. "RoundedHeaderMask.tga"
local LEVEL_MASK = ADDON_MEDIA .. "LevelPillMask.tga"
local HEALTH_RIGHT_MASK = ADDON_MEDIA .. "HealthRightMask.tga"
local HEALTH_LEFT_MASK = ADDON_MEDIA .. "HealthLeftMask.tga"
local POWER_RIGHT_MASK = ADDON_MEDIA .. "PowerRightMask.tga"
local POWER_LEFT_MASK = ADDON_MEDIA .. "PowerLeftMask.tga"
local BODY_RIGHT_MASK = ADDON_MEDIA .. "BodyRightMask.tga"
local BODY_LEFT_MASK = ADDON_MEDIA .. "BodyLeftMask.tga"
local PORTRAIT_LEFT_MASK = ADDON_MEDIA .. "PortraitLeftMask.tga"
local PORTRAIT_RIGHT_MASK = ADDON_MEDIA .. "PortraitRightMask.tga"
local CUSTOM_PVP_ALLIANCE = ADDON_MEDIA .. "PVPAllianceCustom.tga"
local CUSTOM_PVP_HORDE = ADDON_MEDIA .. "PVPHordeCustom.tga"
local CUSTOM_PVP_FFA = ADDON_MEDIA .. "PVPFFACustom.tga"
local COMBAT_BADGE_MASK = ADDON_MEDIA .. "CombatBadgeMask.tga"
local REST_SPARK_MASK = ADDON_MEDIA .. "RestSparkMask.tga"
local PLAYER_CORNER_ORNAMENT = ADDON_MEDIA .. "PlayerCornerOrnament.tga"
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local FONT_NORMAL = "Fonts\\FRIZQT__.TTF"

-- Custom PvP crest layout tuning. The custom faction crests have a denser
-- silhouette than Blizzard's stock PvP flags, so they read better at
-- roughly 75% of the previous size and slightly outside the portrait ring.
local CUSTOM_PVP_ICON_TUNING = {
    holderSize = 52,
    iconSize = 48,
    playerX = -15,
    playerY = 0,
    targetX = 15,
    targetY = 0,
    timerX = 2,
    timerY = 0,
}

local PARTY_PVP_ICON_TUNING = {
    holderSize = 38,
    iconSize = 34,
    x = -8,
    y = 3,
}

local PARTY_TARGET_TUNING = {
    portraitScale = 0.65,
    bodyWidthScale = 0.62,
    minPortraitSize = 52,
    minBodyWidth = 124,
    gap = 7,
    topPad = 3,
    bottomPad = 1,
    headerHeight = 16,
    headerGap = 2,
    healthHeight = 24,
    powerHeight = 20,
    healthPowerOverlap = 1,
}

local function GetPartyTargetDimensions()
    local db = SUF.db or SUF.DEFAULTS or {}
    local basePortrait = tonumber(db.portraitSize) or 92
    local baseBodyWidth = 224
    if SUF.GetUnitBodyWidth then
        baseBodyWidth = tonumber(SUF:GetUnitBodyWidth("party1")) or baseBodyWidth
    end

    local portraitSize = math.max(PARTY_TARGET_TUNING.minPortraitSize, math.floor((basePortrait * PARTY_TARGET_TUNING.portraitScale) + 0.5))
    local barWidth = math.max(PARTY_TARGET_TUNING.minBodyWidth, math.floor((baseBodyWidth * PARTY_TARGET_TUNING.bodyWidthScale) + 0.5))
    local overlap = math.floor(portraitSize * 0.20)
    local wrapperWidth = barWidth + overlap + 3
    local wrapperHeight = PARTY_TARGET_TUNING.topPad
        + PARTY_TARGET_TUNING.headerHeight
        + PARTY_TARGET_TUNING.headerGap
        + PARTY_TARGET_TUNING.healthHeight
        + PARTY_TARGET_TUNING.powerHeight
        - PARTY_TARGET_TUNING.healthPowerOverlap
        + PARTY_TARGET_TUNING.bottomPad
    local frameWidth = portraitSize + barWidth + 8
    local frameHeight = math.max(portraitSize + 8, wrapperHeight + 4)

    return portraitSize, barWidth, overlap, wrapperWidth, wrapperHeight, frameWidth, frameHeight
end


-- Animated portrait viewport tuning. These four values are intentionally kept
-- together so the 3D portrait can be fine-tuned in-game without touching the
-- rest of the frame layout. Positive X moves right; positive Y moves up.
-- Width/height inset are subtracted from portraitSize. The defaults match the
-- static portrait's inner square (portraitSize - 8).
local ANIMATED_PORTRAIT_TUNING = {
    widthInset = 8,
    heightInset = 8,
    xOffset = 0,
    yOffset = 0,
}

local COLORS = {
    shadow = { 0.00, 0.00, 0.00, 0.30 },
    frameOuter = { 0.020, 0.028, 0.040, 1.00 },
    frameEdge = { 0.10, 0.15, 0.22, 0.68 },
    frameInner = { 0.025, 0.045, 0.075, 0.34 },

    headerBottom = { 0.020, 0.045, 0.090, 0.02 },
    headerTop = { 0.075, 0.150, 0.255, 0.11 },

    healthBottom = { 0.34, 0.34, 0.50, 1.00 },
    healthTop = { 0.59, 0.59, 0.78, 1.00 },
    healthBackgroundBottom = { 0.045, 0.045, 0.070, 1.00 },
    healthBackgroundTop = { 0.085, 0.085, 0.125, 1.00 },

    powerBackgroundBottom = { 0.012, 0.025, 0.060, 1.00 },
    powerBackgroundTop = { 0.025, 0.060, 0.120, 1.00 },

    portraitOuter = { 0.010, 0.014, 0.021, 1.00 },
    portraitAccent = { 0.10, 0.16, 0.24, 1.00 },
    portraitInner = { 0.020, 0.030, 0.045, 1.00 },

    gold = { 1.00, 0.80, 0.05, 1.00 },
    text = { 0.98, 0.98, 0.98, 1.00 },
    muted = { 0.72, 0.75, 0.80, 1.00 },

    levelOuter = { 0.62, 0.43, 0.06, 1.00 },
    levelInner = { 0.030, 0.040, 0.055, 1.00 },

    castBottom = { 0.52, 0.36, 0.04, 1.00 },
    castTop = { 0.95, 0.72, 0.12, 1.00 },
    castNoInterruptBottom = { 0.32, 0.32, 0.34, 1.00 },
    castNoInterruptTop = { 0.56, 0.56, 0.60, 1.00 },

    combat = { 0.92, 0.12, 0.08, 1.00 },
    combatSoft = { 0.92, 0.12, 0.08, 0.38 },
}

local PORTRAIT_RING_STYLES = {
    SLEEK = {
        outer = { 0.010, 0.014, 0.021, 1.00 },
        accent = { 0.10, 0.16, 0.24, 1.00 },
        inner = { 0.020, 0.030, 0.045, 1.00 },
    },
    GOLD = {
        outer = { 0.105, 0.055, 0.010, 1.00 },
        accent = { 0.92, 0.60, 0.075, 1.00 },
        inner = { 0.235, 0.115, 0.018, 1.00 },
    },
    SILVER = {
        outer = { 0.035, 0.045, 0.060, 1.00 },
        accent = { 0.46, 0.52, 0.61, 1.00 },
        inner = { 0.105, 0.125, 0.155, 1.00 },
    },
}

-- Keep the visible portrait-ring accent in the same visual weight family as
-- the Simple player-corner ornament. Thickness is radial, so a 3px ring means
-- the inner diameter is reduced by 6px from the accent texture.
local PORTRAIT_RING_ACCENT_THICKNESS = 3

-- SleekUF-owned difficulty palette. We still ask Blizzard for the *difficulty
-- category* via GetQuestDifficultyColor so TBC's dynamic green/gray thresholds
-- stay correct, but we remap the stock hues into our UI palette. In particular,
-- yellow deliberately equals COLORS.gold so friendly/safe and attackable
-- yellow levels can never drift into two different yellows again.
local LEVEL_DIFFICULTY_PALETTE = {
    impossible = { 0.96, 0.16, 0.12, 1.00 },
    verydifficult = { 1.00, 0.46, 0.14, 1.00 },
    difficult = COLORS.gold,
    standard = { 0.30, 0.78, 0.28, 1.00 },
    trivial = { 0.52, 0.55, 0.60, 1.00 },
}

local LEVEL_DIFFICULTY_REFERENCE = {
    impossible = { 1.00, 0.10, 0.10 },
    verydifficult = { 1.00, 0.50, 0.25 },
    difficult = { 1.00, 1.00, 0.00 },
    standard = { 0.25, 0.75, 0.25 },
    trivial = { 0.50, 0.50, 0.50 },
}

local POWER_COLORS = {
    MANA = { 0.02, 0.48, 1.00 },
    RAGE = { 0.82, 0.10, 0.10 },
    FOCUS = { 1.00, 0.48, 0.22 },
    ENERGY = { 0.94, 0.80, 0.08 },
    HAPPINESS = { 0.00, 0.74, 1.00 },
    RUNIC_POWER = { 0.00, 0.80, 1.00 },
}

local HEALTH_GREEN = { 0.10, 0.78, 0.18, 1.00 }

local BODY_WRAPPER_BASE_OUTER = { 0.015, 0.022, 0.032, 1.00 }
local BODY_WRAPPER_BASE_EDGE = { 0.090, 0.140, 0.200, 1.00 }
local BODY_WRAPPER_BASE_INNER = { 0.020, 0.038, 0.060, 1.00 }

local function BlendColor(baseColor, tintColor, amount)
    amount = math.max(0, math.min(1, amount or 0))
    return {
        baseColor[1] + ((tintColor[1] - baseColor[1]) * amount),
        baseColor[2] + ((tintColor[2] - baseColor[2]) * amount),
        baseColor[3] + ((tintColor[3] - baseColor[3]) * amount),
        baseColor[4] or 1,
    }
end


local NPC_NAME_COLORS = {
    friendly = { 0.20, 1.00, 0.20, 1.00 },
    neutral = { 1.00, 0.82, 0.00, 1.00 },
    hostile = { 1.00, 0.18, 0.18, 1.00 },
}

local CLASS_COLOR_FALLBACK = {
    WARRIOR = { 0.78, 0.61, 0.43, 1.00 },
    PALADIN = { 0.96, 0.55, 0.73, 1.00 },
    HUNTER = { 0.67, 0.83, 0.45, 1.00 },
    ROGUE = { 1.00, 0.96, 0.41, 1.00 },
    PRIEST = { 1.00, 1.00, 1.00, 1.00 },
    SHAMAN = { 0.00, 0.44, 0.87, 1.00 },
    MAGE = { 0.25, 0.78, 0.92, 1.00 },
    WARLOCK = { 0.58, 0.51, 0.79, 1.00 },
    DRUID = { 1.00, 0.49, 0.04, 1.00 },
}

-- Deliberately separated class-health shades for the three classes that sit
-- closest to our resource-bar palette. Hunter is pushed toward an earthy
-- yellow-green, Rogue toward a warm cream-gold, and Shaman toward a deeper
-- royal blue. This keeps the class identity while making the health bar easier
-- to distinguish from generic green health, yellow energy and blue mana.
local CLASS_COLOR_OVERRIDES = {
    HUNTER = { 0.52, 0.74, 0.30, 1.00 },
    ROGUE  = { 1.00, 0.91, 0.42, 1.00 },
    SHAMAN = { 0.10, 0.30, 0.78, 1.00 },
}

local FRAME_CONFIG = {
    player = { mirror = false, label = "PLAYER" },
    target = { mirror = true, label = "TARGET" },
    targettarget = { mirror = false, label = "TARGET OF TARGET" },
    focus = { mirror = false, label = "FOCUS" },
    pet = { mirror = false, label = "PET" },
    party1 = { mirror = false, label = "PARTY 1" },
    party2 = { mirror = false, label = "PARTY 2" },
    party3 = { mirror = false, label = "PARTY 3" },
    party4 = { mirror = false, label = "PARTY 4" },
}

local CLASSIFICATION_DRAGON_TEXTURES = {
    worldboss = ADDON_MEDIA .. "CustomEliteGold.tga",
    elite = ADDON_MEDIA .. "CustomEliteGold.tga",
    rareelite = ADDON_MEDIA .. "CustomEliteSilver.tga",
    rare = ADDON_MEDIA .. "CustomRareSilver.tga",
}

local function CreateColorObject(color)
    if CreateColor then
        return CreateColor(color[1], color[2], color[3], color[4] or 1)
    end
    return nil
end

local function SetSolid(texture, color)
    texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
end

local function SetGradient(texture, bottomColor, topColor)
    texture:SetTexture(WHITE_TEXTURE)

    if texture.SetGradient and CreateColor then
        texture:SetGradient("VERTICAL", CreateColorObject(bottomColor), CreateColorObject(topColor))
    else
        local r = (bottomColor[1] + topColor[1]) * 0.5
        local g = (bottomColor[2] + topColor[2]) * 0.5
        local b = (bottomColor[3] + topColor[3]) * 0.5
        local a = ((bottomColor[4] or 1) + (topColor[4] or 1)) * 0.5
        texture:SetVertexColor(r, g, b, a)
    end
end

local function Brighten(color, amount)
    return {
        math.min(1, color[1] + amount),
        math.min(1, color[2] + amount),
        math.min(1, color[3] + amount),
        color[4] or 1,
    }
end

local function Darken(color, amount)
    return {
        math.max(0, color[1] - amount),
        math.max(0, color[2] - amount),
        math.max(0, color[3] - amount),
        color[4] or 1,
    }
end

local function CreateSolid(parent, layer, color, subLevel)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND", nil, subLevel or 0)
    SetSolid(texture, color)
    return texture
end

local function ApplyPortraitRingStyle(portraitFrame)
    if not portraitFrame then
        return
    end
    local styleKey = SUF.db and SUF.db.portraitRingStyle or "SLEEK"
    local style = PORTRAIT_RING_STYLES[styleKey] or PORTRAIT_RING_STYLES.SLEEK
    if portraitFrame.Outer then SetSolid(portraitFrame.Outer, style.outer) end
    if portraitFrame.Accent then SetSolid(portraitFrame.Accent, style.accent) end
    -- Keep the interior portrait backing stable across styles. The ring-style
    -- setting should recolor the ring only, not the background behind the
    -- avatar image itself.
    if portraitFrame.Inner then SetSolid(portraitFrame.Inner, COLORS.portraitInner) end
end

local function ApplyLevelBadgeFrameStyle(badge)
    if not badge then
        return
    end

    -- Reuse the portrait ring's *outer* tone as the level-pill separation
    -- border. This keeps the badge visually tied to Sleek/Gold/Silver without
    -- adding another bright glow around an already color-coded indicator.
    local styleKey = SUF.db and SUF.db.portraitRingStyle or "SLEEK"
    local style = PORTRAIT_RING_STYLES[styleKey] or PORTRAIT_RING_STYLES.SLEEK
    local outer = style.outer or COLORS.portraitOuter

    if badge.Shadow then
        badge.Shadow:SetColorTexture(outer[1], outer[2], outer[3], 0.88)
        badge.Shadow:SetAlpha(0.88)
    end
    if badge.SoftShadow then
        badge.SoftShadow:SetColorTexture(outer[1], outer[2], outer[3], 0.10)
        badge.SoftShadow:SetAlpha(0.10)
    end
end

local function ApplyPlayerCornerOrnamentStyle(portraitFrame, accentOverride)
    if not portraitFrame then
        return
    end

    local owner = portraitFrame:GetParent()
    local ornament = owner and owner.PlayerCornerOrnament
    if not ornament or not ornament.Simple then
        return
    end

    local styleKey = SUF.db and SUF.db.portraitRingStyle or "SLEEK"
    local style = PORTRAIT_RING_STYLES[styleKey] or PORTRAIT_RING_STYLES.SLEEK
    local accent = accentOverride or style.accent
    local shadow = Darken(style.inner or style.outer, 0.02)
    local line = Brighten(accent, 0.05)

    local parts = {
        ornament.SimpleShadowH,
        ornament.SimpleShadowV,
    }
    for _, tex in ipairs(parts) do
        if tex then
            tex:SetVertexColor(shadow[1], shadow[2], shadow[3], 0.98)
        end
    end

    parts = {
        ornament.SimpleMainH,
        ornament.SimpleMainV,
    }
    for _, tex in ipairs(parts) do
        if tex then
            tex:SetVertexColor(line[1], line[2], line[3], 1.0)
        end
    end
end

local function AddShapeMask(parent, texture, maskPath)
    if not parent.CreateMaskTexture or not texture.AddMaskTexture then
        return nil
    end

    local mask = parent:CreateMaskTexture()
    mask:SetTexture(maskPath, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(texture)
    texture:AddMaskTexture(mask)
    return mask
end

local function SetMaskPath(mask, path)
    if mask then
        mask:SetTexture(path, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    end
end

-- Aura corner roundness is exposed as a 0-50% setting. WoW mask textures are
-- static assets, so we quantize the slider to matching 5% mask steps. This
-- keeps target and party aura borders/icons/cooldown swipes perfectly aligned.
local function GetAuraMaskPath()
    local roundness = tonumber(SUF.db and SUF.db.auraCornerRoundness) or 20
    roundness = math.max(0, math.min(50, math.floor((roundness + 2.5) / 5) * 5))
    return ADDON_MEDIA .. string.format("AuraMask%02d.tga", roundness)
end

local function ApplyAuraMaskToButton(button)
    if not button then
        return
    end

    local path = GetAuraMaskPath()
    SetMaskPath(button.BorderMask, path)
    SetMaskPath(button.IconMask, path)
    if button.Cooldown and button.Cooldown.SetSwipeTexture then
        button.Cooldown:SetSwipeTexture(path)
    end
end

local function NormalizeCornerStyle(style)
    style = tostring(style or "TIGHT"):upper()
    if style ~= "SOFT" and style ~= "MEDIUM" and style ~= "TIGHT" then
        style = "TIGHT"
    end
    return style
end

local function GetCornerMask(kind, mirrored, style)
    style = NormalizeCornerStyle(style)
    local side = mirrored and "Left" or "Right"
    local suffix = style:sub(1,1) .. style:sub(2):lower()
    return string.format("%s%s%s%s.tga", ADDON_MEDIA, kind, side, suffix)
end

local function GetBodyReactionBorderMask(mirrored, style)
    style = NormalizeCornerStyle(style)
    local side = mirrored and "Left" or "Right"
    local suffix = style:sub(1,1) .. style:sub(2):lower()
    return string.format("%sBody%s%sBorder.tga", ADDON_MEDIA, side, suffix)
end

local function FormatValue(value)
    value = tonumber(value) or 0

    if value >= 1000000 then
        local shown = value / 1000000
        if shown >= 100 then
            return string.format("%.0f M", shown)
        end
        return string.format("%.1f M", shown):gsub("%.0 M", " M")
    elseif value >= 10000 then
        local shown = value / 1000
        if shown >= 100 then
            return string.format("%.0f K", shown)
        end
        return string.format("%.1f K", shown):gsub("%.0 K", " K")
    end

    return tostring(math.floor(value + 0.5))
end

local function Percent(current, maximum)
    if not maximum or maximum <= 0 then
        return 0
    end

    return math.floor((current / maximum) * 100 + 0.5)
end

local function FormatLevel(unit)
    local level = UnitLevel(unit)
    if not level then
        return ""
    elseif level < 0 then
        return "??"
    end
    return tostring(level)
end

local function CopyColor(color)
    return { color[1], color[2], color[3], color[4] or 1 }
end

local function GetClassColor(classToken)
    if not classToken then
        return nil
    end

    local override = CLASS_COLOR_OVERRIDES[classToken]
    if override then
        return CopyColor(override)
    end

    local source = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
    local color = source and source[classToken]
    if color then
        return { color.r or color[1], color.g or color[2], color.b or color[3], 1 }
    end

    local fallback = CLASS_COLOR_FALLBACK[classToken]
    return fallback and CopyColor(fallback) or nil
end

function SUF:GetHealthBarColor(unit)
    local mode = self.db and self.db.healthColorMode or "GREEN"

    if mode == "GREEN" then
        return CopyColor(HEALTH_GREEN)
    end

    if mode == "CLASS" then
        if unit and UnitExists(unit) and UnitIsPlayer(unit) then
            local _, classToken = UnitClass(unit)
            return GetClassColor(classToken) or CopyColor(HEALTH_GREEN)
        end
        return CopyColor(HEALTH_GREEN)
    end

    return GetClassColor(mode) or CopyColor(HEALTH_GREEN)
end

local function IsSafeLevelColorArea()
    local pvpType

    if C_PvP and C_PvP.GetZonePVPInfo then
        local ok, value = pcall(C_PvP.GetZonePVPInfo)
        if ok then
            pvpType = value
        end
    elseif GetZonePVPInfo then
        local ok, value = pcall(GetZonePVPInfo)
        if ok then
            pvpType = value
        end
    end

    -- Shattrath and similar sanctuary zones are explicitly PvP-free. Major
    -- faction cities are normally represented by the resting state instead,
    -- so use both signals to match the calm Blizzard-style level treatment.
    if pvpType == "sanctuary" then
        return true
    end

    return IsResting and IsResting() or false
end

local PVP_TIMER_TEXT_COLORS = {
    WHITE = { 0.94, 0.95, 0.92, 1.00 },
    GOLD = { 1.00, 0.72, 0.20, 1.00 },
}

local function ApplyPVPTimerTextColor(timer, db)
    if not timer then
        return
    end

    local key = db and db.pvpTimerTextColor or "WHITE"
    local color = PVP_TIMER_TEXT_COLORS[key] or PVP_TIMER_TEXT_COLORS.WHITE
    timer:SetTextColor(color[1], color[2], color[3], color[4])
end

local function IsFriendlyLevelUnit(unit)
    if not unit or not UnitExists(unit) then
        return false
    end

    if UnitIsFriend then
        return UnitIsFriend("player", unit) and true or false
    end

    -- Defensive Classic fallback. Reaction 5+ is Friendly/Honored/Revered/
    -- Exalted, which should use the same calm gold level treatment as party
    -- members and other units the player cannot attack.
    if UnitReaction then
        local reaction = UnitReaction(unit, "player")
        return reaction and reaction >= 5 or false
    end

    return false
end

local function MapBlizzardDifficultyColor(color)
    if not color then
        return CopyColor(LEVEL_DIFFICULTY_PALETTE.difficult)
    end

    local r = color.r or color[1] or 1
    local g = color.g or color[2] or 1
    local b = color.b or color[3] or 0
    local bestKey = "difficult"
    local bestDistance = math.huge

    for key, reference in pairs(LEVEL_DIFFICULTY_REFERENCE) do
        local dr = r - reference[1]
        local dg = g - reference[2]
        local db = b - reference[3]
        local distance = (dr * dr) + (dg * dg) + (db * db)
        if distance < bestDistance then
            bestDistance = distance
            bestKey = key
        end
    end

    return CopyColor(LEVEL_DIFFICULTY_PALETTE[bestKey] or LEVEL_DIFFICULTY_PALETTE.difficult)
end

local function GetLevelDifficultyColor(unit, explicitLevel)
    if unit == "player" or unit == "pet" or (type(unit) == "string" and unit:match("^party%d$")) then
        return CopyColor(COLORS.gold)
    end

    if unit == "target" or unit == "targettarget" or unit == "focus" then
        -- Mirror Blizzard's target-frame behavior: friendly units use the
        -- normal gold level color. Difficulty colors are reserved for units
        -- that are neutral/unfriendly/hostile to the player. This must be
        -- evaluated against the actual unit token so Target of Target follows
        -- its own friendliness rather than inheriting the Target's reaction.
        if IsFriendlyLevelUnit(unit) then
            return CopyColor(COLORS.gold)
        end

        -- In a city/resting area or sanctuary, suppress difficulty colors for
        -- non-friendly units too, matching the calm safe-area treatment we use.
        if IsSafeLevelColorArea() then
            return CopyColor(COLORS.gold)
        end
    end

    local level = explicitLevel or (unit and UnitExists(unit) and UnitLevel(unit))
    if not level then
        return CopyColor(COLORS.gold)
    end

    if level < 0 then
        return CopyColor(LEVEL_DIFFICULTY_PALETTE.impossible)
    end

    if GetQuestDifficultyColor then
        local color = GetQuestDifficultyColor(level)
        if color then
            return MapBlizzardDifficultyColor(color)
        end
    end

    -- Conservative fallback matching the familiar Classic difficulty steps.
    -- The exact green/gray break varies by player level, which is why the
    -- Blizzard helper above is preferred whenever available.
    local playerLevel = UnitLevel("player") or level
    local difference = level - playerLevel
    if difference >= 5 then
        return CopyColor(LEVEL_DIFFICULTY_PALETTE.impossible)
    elseif difference >= 3 then
        return CopyColor(LEVEL_DIFFICULTY_PALETTE.verydifficult)
    elseif difference >= -2 then
        return CopyColor(LEVEL_DIFFICULTY_PALETTE.difficult)
    elseif difference >= -5 then
        return CopyColor(LEVEL_DIFFICULTY_PALETTE.standard)
    end

    return CopyColor(LEVEL_DIFFICULTY_PALETTE.trivial)
end

local function ApplyLevelBadgeColor(frame, unit, explicitLevel)
    if not frame or not frame.LevelBadge then
        return
    end

    local color = GetLevelDifficultyColor(unit, explicitLevel)
    local outer = { color[1] * 0.70, color[2] * 0.70, color[3] * 0.70, 0.96 }
    frame.LevelBadge.Outer:SetColorTexture(outer[1], outer[2], outer[3], outer[4])
    if frame.LevelBadge.Accent then
        -- Keep this intentionally restrained. The top carries a faint hint of
        -- the difficulty color while the bottom sinks back toward the dark
        -- badge base for a more modern, inset-like gradient.
        local topTint = { color[1], color[2], color[3], 0.085 }
        local bottomTint = { color[1] * 0.28, color[2] * 0.28, color[3] * 0.28, 0.025 }
        SetGradient(frame.LevelBadge.Accent, bottomTint, topTint)
        frame.LevelBadge.Accent:SetAlpha(1.00)
    end
    frame.LevelBadge.Text:SetTextColor(color[1], color[2], color[3], 1)
end

local function GetRaidGroupText(unit)
    if not unit or not IsInRaid or not IsInRaid() or not UnitInRaid or not GetRaidRosterInfo then
        return ""
    end

    local raidIndex = UnitInRaid(unit)
    if not raidIndex then
        return ""
    end

    local _, _, subgroup = GetRaidRosterInfo(raidIndex)
    if subgroup and subgroup > 0 then
        return "G" .. tostring(subgroup)
    end

    return ""
end

local function UnitLeadsPlayerGroup(unit)
    if not unit or not UnitExists(unit) then
        return false
    end

    -- Newer Classic branches expose UnitIsGroupLeader directly. Keep the
    -- raid-rank and legacy party-leader fallbacks for TBC-era compatibility.
    if UnitIsGroupLeader and UnitIsGroupLeader(unit) then
        return true
    end

    if UnitInRaid and GetRaidRosterInfo then
        local raidIndex = UnitInRaid(unit)
        if raidIndex then
            local _, rank = GetRaidRosterInfo(raidIndex)
            return rank == 2
        end
    end

    if UnitIsPartyLeader and UnitIsPartyLeader(unit) then
        return true
    end

    return false
end

local function IsUnitOffline(unit)
    if not unit or not UnitExists(unit) or not UnitIsPlayer or not UnitIsPlayer(unit) or not UnitIsConnected then
        return false
    end

    return UnitIsConnected(unit) == false
end

local function CreateLowHealthGlow(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 1)
    holder:Hide()

    local glow = holder:CreateTexture(nil, "BACKGROUND", nil, -7)
    glow:SetAllPoints()
    glow:SetColorTexture(1.00, 0.06, 0.03, 1.00)
    glow:SetBlendMode("ADD")
    glow:SetAlpha(0)

    holder.Glow = glow
    holder.Mask = AddShapeMask(holder, glow, BODY_RIGHT_MASK)
    holder.pulseElapsed = 0
    return holder
end

local function CreateBar(parent)
    local outer = CreateFrame("Frame", nil, parent)

    -- The outer widget owns the shape. The actual StatusBar fill is allowed to
    -- stay rectangular while partially filled, so the moving edge never grows
    -- a fake rounded end-cap.
    local outerBg = CreateSolid(outer, "BACKGROUND", COLORS.frameOuter)
    outerBg:SetAllPoints()

    local edge = CreateSolid(outer, "BORDER", COLORS.frameEdge)
    edge:SetPoint("TOPLEFT", 1, -1)
    edge:SetPoint("BOTTOMRIGHT", -1, 1)

    local bar = CreateFrame("StatusBar", nil, outer)
    bar:SetPoint("TOPLEFT", 2, -2)
    bar:SetPoint("BOTTOMRIGHT", -2, 2)
    bar:SetStatusBarTexture(WHITE_TEXTURE)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)

    local fill = bar:GetStatusBarTexture()
    SetGradient(fill, COLORS.healthBottom, COLORS.healthTop)

    local background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    SetGradient(background, COLORS.healthBackgroundBottom, COLORS.healthBackgroundTop)

    -- Keep a very soft highlight on the fixed outer edge, but no moving spark.
    local sideGloss = bar:CreateTexture(nil, "OVERLAY", nil, 1)
    sideGloss:SetWidth(5)
    sideGloss:SetBlendMode("ADD")
    if sideGloss.SetGradient and CreateColor then
        sideGloss:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.00), CreateColor(1, 1, 1, 0.10))
    else
        sideGloss:SetColorTexture(1, 1, 1, 0.08)
    end

    local leftText = bar:CreateFontString(nil, "OVERLAY")
    leftText:SetFont(FONT_NORMAL, 15, "OUTLINE")
    leftText:SetTextColor(unpack(COLORS.text))
    leftText:SetShadowColor(0, 0, 0, 1)
    leftText:SetShadowOffset(1, -1)
    leftText:SetJustifyH("LEFT")

    local rightText = bar:CreateFontString(nil, "OVERLAY")
    rightText:SetFont(FONT_NORMAL, 15, "OUTLINE")
    rightText:SetTextColor(unpack(COLORS.text))
    rightText:SetShadowColor(0, 0, 0, 1)
    rightText:SetShadowOffset(1, -1)
    rightText:SetJustifyH("RIGHT")

    outer.OuterBg = outerBg
    outer.Edge = edge
    outer.Bar = bar
    outer.Fill = fill
    outer.Background = background
    outer.OuterMask = AddShapeMask(outer, outerBg, HEALTH_RIGHT_MASK)
    outer.EdgeMask = AddShapeMask(outer, edge, HEALTH_RIGHT_MASK)
    outer.BackgroundMask = AddShapeMask(bar, background, HEALTH_RIGHT_MASK)

    -- Create the fill mask once, then detach it. Player/Pet only attach it at
    -- 100%; mirrored Target keeps it attached because its rounded side is the
    -- fixed outer edge rather than the moving fill edge.
    outer.FillMask = AddShapeMask(bar, fill, HEALTH_RIGHT_MASK)
    outer.FillMaskAttached = outer.FillMask ~= nil
    if outer.FillMask and fill.RemoveMaskTexture then
        fill:RemoveMaskTexture(outer.FillMask)
        outer.FillMaskAttached = false
    end

    outer.SideGloss = sideGloss
    outer.SideGlossMask = AddShapeMask(bar, sideGloss, HEALTH_RIGHT_MASK)
    outer.LeftText = leftText
    outer.RightText = rightText
    outer.displayValue = 0
    outer.targetValue = 0
    outer.maximum = 1
    outer.AlwaysMaskFill = false

    return outer
end

local function ApplyBarFillGradient(barWidget, baseColor)
    local bottom = Darken(baseColor, 0.11)
    local top = Brighten(baseColor, 0.10)
    SetGradient(barWidget.Fill, bottom, top)
end

local function ApplyBarBackgroundGradient(barWidget, bottomColor, topColor)
    SetGradient(barWidget.Background, bottomColor, topColor)
end

function SUF:UpdateBarFillMask(widget, displayedValue, maximum)
    if not widget or not widget.FillMask or not widget.Fill then
        return
    end

    maximum = math.max(1, tonumber(maximum) or widget.maximum or 1)
    displayedValue = math.max(0, tonumber(displayedValue) or 0)

    local shouldAttach = widget.AlwaysMaskFill or displayedValue >= (maximum - 0.25)
    if shouldAttach and not widget.FillMaskAttached and widget.Fill.AddMaskTexture then
        widget.Fill:AddMaskTexture(widget.FillMask)
        widget.FillMaskAttached = true
    elseif not shouldAttach and widget.FillMaskAttached and widget.Fill.RemoveMaskTexture then
        widget.Fill:RemoveMaskTexture(widget.FillMask)
        widget.FillMaskAttached = false
    end
end

function SUF:EnsureBarAnimator()
    if self.BarAnimator then
        return
    end

    self.ActiveSmoothBars = self.ActiveSmoothBars or {}
    local animator = CreateFrame("Frame")
    animator:Hide()

    animator:SetScript("OnUpdate", function(self, elapsed)
        local active = false
        local factor = math.min(1, elapsed * 14)

        for widget in pairs(SUF.ActiveSmoothBars) do
            local current = widget.displayValue or 0
            local target = widget.targetValue or 0
            local difference = target - current

            if math.abs(difference) <= 0.25 then
                widget.displayValue = target
                widget.Bar:SetValue(target)
                SUF:UpdateBarFillMask(widget, target, widget.maximum)
                SUF.ActiveSmoothBars[widget] = nil
            else
                current = current + difference * factor
                widget.displayValue = current
                widget.Bar:SetValue(current)
                SUF:UpdateBarFillMask(widget, current, widget.maximum)
                active = true
            end
        end

        if not active and not next(SUF.ActiveSmoothBars) then
            self:Hide()
        end
    end)

    self.BarAnimator = animator
end

function SUF:SetBarValue(widget, value, maximum, immediate)
    maximum = math.max(1, tonumber(maximum) or 1)
    value = math.max(0, math.min(maximum, tonumber(value) or 0))

    widget.Bar:SetMinMaxValues(0, maximum)
    widget.targetValue = value
    widget.maximum = maximum

    if immediate or not self.db.smoothBars then
        widget.displayValue = value
        widget.Bar:SetValue(value)
        self:UpdateBarFillMask(widget, value, maximum)
        if self.ActiveSmoothBars then
            self.ActiveSmoothBars[widget] = nil
        end
    else
        self:EnsureBarAnimator()
        if widget.displayValue == nil then
            widget.displayValue = widget.Bar:GetValue() or value
        end
        self:UpdateBarFillMask(widget, widget.displayValue, maximum)
        self.ActiveSmoothBars[widget] = true
        self.BarAnimator:Show()
    end
end

local function CreateMover(frame, unit, label)
    local mover = CreateFrame("Frame", nil, frame)
    mover:SetAllPoints(frame)
    mover:SetFrameLevel(frame:GetFrameLevel() + 50)
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    mover:Hide()

    -- Stronger green placement overlay, similar to action-bar unlock modes.
    -- The real unit frame remains visible underneath while the tint makes the
    -- draggable area unmistakable.
    local bg = mover:CreateTexture(nil, "OVERLAY", nil, 0)
    bg:SetAllPoints()
    bg:SetColorTexture(0.10, 0.88, 0.30, 0.28)

    local top = mover:CreateTexture(nil, "OVERLAY", nil, 1)
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(2)
    top:SetColorTexture(0.18, 1.00, 0.42, 0.88)

    local bottom = mover:CreateTexture(nil, "OVERLAY", nil, 1)
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(2)
    bottom:SetColorTexture(0.18, 1.00, 0.42, 0.88)

    local left = mover:CreateTexture(nil, "OVERLAY", nil, 1)
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(2)
    left:SetColorTexture(0.18, 1.00, 0.42, 0.88)

    local right = mover:CreateTexture(nil, "OVERLAY", nil, 1)
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(2)
    right:SetColorTexture(0.18, 1.00, 0.42, 0.88)

    local labelBG = mover:CreateTexture(nil, "OVERLAY", nil, 2)
    labelBG:SetPoint("CENTER")
    labelBG:SetSize(82, 24)
    labelBG:SetColorTexture(0.015, 0.07, 0.025, 0.82)

    local labelText = mover:CreateFontString(nil, "OVERLAY", nil, 3)
    labelText:SetPoint("CENTER")
    labelText:SetFont(FONT_NORMAL, 12, "OUTLINE")
    labelText:SetTextColor(0.62, 1.00, 0.68, 1)
    labelText:SetText(label)

    local scaleText = mover:CreateFontString(nil, "OVERLAY", nil, 3)
    scaleText:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT", -5, 5)
    scaleText:SetFont(FONT_NORMAL, 10, "OUTLINE")
    scaleText:SetTextColor(0.78, 1.00, 0.82, 1)
    scaleText:SetText(string.format("%.0f%%", (SUF:GetUnitScale(unit) or 1) * 100))
    mover.ScaleText = scaleText

    if mover.EnableMouseWheel then
        mover:EnableMouseWheel(true)
        mover:SetScript("OnMouseWheel", function(self, delta)
            if not SUF.db or SUF.db.locked or (InCombatLockdown and InCombatLockdown()) then
                return
            end
            local current = SUF:GetUnitScale(unit) or 1
            local step = IsShiftKeyDown and IsShiftKeyDown() and 0.05 or 0.02
            if SUF:SetUnitScale(unit, current + ((delta or 0) * step), true) then
                self.ScaleText:SetText(string.format("%.0f%%", (SUF:GetUnitScale(unit) or 1) * 100))
                SUF:RefreshSettingsPanel()
            end
        end)
    end

    mover:SetScript("OnShow", function(self)
        if self.ScaleText then
            self.ScaleText:SetText(string.format("%.0f%%", (SUF:GetUnitScale(unit) or 1) * 100))
        end
    end)

    mover:SetScript("OnDragStart", function(self)
        if InCombatLockdown and InCombatLockdown() then
            return
        end
        if not SUF.db or SUF.db.locked then
            return
        end

        -- Use Blizzard's native mover for the secure unit button itself. This
        -- is reliable for Player/Target/ToT/Pet in BCC Anniversary and keeps
        -- dragging responsive. StartMoving() marks named frames user-placed,
        -- so clear that flag immediately to prevent layout-local.wtf from
        -- becoming a second persistence system alongside SavedVariables.
        frame:StartMoving()
        if frame.SetUserPlaced then
            frame:SetUserPlaced(false)
        end
        self.draggingFrame = true
    end)

    mover:SetScript("OnDragStop", function(self)
        if not self.draggingFrame then
            return
        end
        self.draggingFrame = nil

        frame:StopMovingOrSizing()
        if frame.SetUserPlaced then
            frame:SetUserPlaced(false)
        end

        -- StartMoving() replaces the normal TOPLEFT anchor with a temporary
        -- screen-relative anchor. SavePosition() deliberately understands that
        -- geometry and converts it back to our canonical SavedVariables offset.
        -- Restore immediately afterwards so every frame always ends the drag as
        -- TOPLEFT -> UIParent TOPLEFT, independent of frame scale.
        SUF:SavePosition(unit)
        SUF:RestorePosition(unit)
        SUF:RefreshSettingsPanel()
    end)

    return mover
end

local function CreatePortrait(frame)
    local portraitFrame = CreateFrame("Frame", nil, frame)
    portraitFrame:SetFrameLevel(frame:GetFrameLevel() + 8)

    local combatGlow = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, -5)
    combatGlow:SetColorTexture(unpack(COLORS.combat))
    combatGlow:SetAlpha(0)
    local combatMask = AddShapeMask(portraitFrame, combatGlow, PORTRAIT_LEFT_MASK)

    local shadow = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, -4)
    shadow:SetColorTexture(0, 0, 0, 0.0)
    local shadowMask = AddShapeMask(portraitFrame, shadow, PORTRAIT_LEFT_MASK)

    local outer = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, -3)
    SetSolid(outer, COLORS.portraitOuter)
    local outerMask = AddShapeMask(portraitFrame, outer, PORTRAIT_LEFT_MASK)

    local accent = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, -2)
    SetSolid(accent, COLORS.portraitAccent)
    local accentMask = AddShapeMask(portraitFrame, accent, PORTRAIT_LEFT_MASK)

    local inner = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 0)
    SetSolid(inner, COLORS.portraitInner)
    local innerMask = AddShapeMask(portraitFrame, inner, PORTRAIT_LEFT_MASK)

    local portrait = portraitFrame:CreateTexture(nil, "ARTWORK", nil, 2)
    portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local portraitMask = AddShapeMask(portraitFrame, portrait, PORTRAIT_LEFT_MASK)

    local glass = portraitFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    glass:SetTexture(WHITE_TEXTURE)
    if glass.SetGradient and CreateColor then
        glass:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.00), CreateColor(1, 1, 1, 0.10))
    else
        glass:SetColorTexture(1, 1, 1, 0.04)
    end
    local glassMask = AddShapeMask(portraitFrame, glass, PORTRAIT_LEFT_MASK)

    -- Optional live model. The normal portrait stays populated behind it so
    -- fallback is immediate if the client cannot actually load the unit model.
    local animatedModel = CreateFrame("PlayerModel", nil, portraitFrame)
    animatedModel:SetFrameLevel(portraitFrame:GetFrameLevel() + 1)
    animatedModel:EnableMouse(false)
    animatedModel:Hide()
    animatedModel.modelReady = false
    animatedModel.requestedGUID = nil
    animatedModel.requestedUnit = nil
    animatedModel.lastVisible = nil

    if animatedModel.SetKeepModelOnHide then
        pcall(animatedModel.SetKeepModelOnHide, animatedModel, true)
    end

    -- PlayerModel widgets are rectangular and WoW does not expose texture-mask
    -- clipping for the model render itself. An opaque inverse cover simply
    -- paints a square over the game world, which is the black-box artifact we
    -- want to avoid. Instead the model viewport is fitted *inside* the round
    -- portrait in ApplyUnitFrameLayout; the normal portrait ring/glass remains
    -- above it and no model pixels can reach the circular outside corners.
    local modelOverlay = CreateFrame("Frame", nil, portraitFrame)
    modelOverlay:SetFrameLevel(portraitFrame:GetFrameLevel() + 2)
    modelOverlay:EnableMouse(false)
    modelOverlay:Show()

    -- Do not add a rectangular glass/background texture over PlayerModel.
    -- The normal portrait glass is already shape-masked and remains above the
    -- model. A full-size modelGlass was the faint square visible outside the
    -- portrait ring on transparent-background 3D portraits.
    local modelGlass = modelOverlay:CreateTexture(nil, "OVERLAY", nil, 5)
    modelGlass:SetColorTexture(1, 1, 1, 0)
    modelGlass:Hide()

    local modelSeparator = modelOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
    modelSeparator:SetColorTexture(0.08, 0.12, 0.18, 0.88)
    modelSeparator:Hide()

    -- The straight body-facing edge is an intentional part of the silhouette.
    local separator = portraitFrame:CreateTexture(nil, "OVERLAY", nil, 5)
    separator:SetColorTexture(0.08, 0.12, 0.18, 0)

    portraitFrame.CombatGlow = combatGlow
    portraitFrame.Shadow = shadow
    portraitFrame.Outer = outer
    portraitFrame.Accent = accent
    portraitFrame.Inner = inner
    portraitFrame.Portrait = portrait
    portraitFrame.Glass = glass
    portraitFrame.Separator = separator
    portraitFrame.AnimatedModel = animatedModel
    portraitFrame.ModelOverlay = modelOverlay
    portraitFrame.ModelGlass = modelGlass
    portraitFrame.ModelSeparator = modelSeparator
    portraitFrame.ShapeMasks = { combatMask, shadowMask, outerMask, accentMask, innerMask, portraitMask, glassMask }

    local function ShowModelIfStillValid(model)
        local unit = model.requestedUnit
        if not unit or not SUF.db or not SUF.db.showAnimatedPortraits then
            return
        end
        if not UnitExists(unit) then
            return
        end
        if UnitIsPlayer and UnitIsPlayer(unit) and UnitIsConnected and not UnitIsConnected(unit) then
            return
        end
        if unit ~= "player" and UnitIsVisible and not UnitIsVisible(unit) then
            return
        end
        if model.requestedGUID and UnitGUID and UnitGUID(unit) ~= model.requestedGUID then
            return
        end

        model.modelReady = true
        portrait:Hide()
        model:Show()
        modelGlass:Hide()
        modelSeparator:Hide()

        SUF:ApplyAnimatedPortraitMotion(model)
    end

    if animatedModel.HasScript and animatedModel:HasScript("OnModelLoaded") then
        animatedModel:SetScript("OnModelLoaded", ShowModelIfStillValid)
    end

    return portraitFrame
end

local function CreateLevelBadge(parent)
    local badge = CreateFrame("Frame", nil, parent)
    badge:SetFrameLevel(parent:GetFrameLevel() + 10)

    -- Match the portrait-frame treatment instead of surrounding the pill with
    -- a visible black glow. Shadow becomes the compact style-aware outer edge;
    -- SoftShadow is only a whisper of ambient separation behind it.
    local softShadow = badge:CreateTexture(nil, "BACKGROUND", nil, -3)
    softShadow:SetColorTexture(0, 0, 0, 0.10)
    local softShadowMask = AddShapeMask(badge, softShadow, LEVEL_MASK)

    local shadow = badge:CreateTexture(nil, "BACKGROUND", nil, -2)
    shadow:SetColorTexture(0, 0, 0, 0.88)
    local shadowMask = AddShapeMask(badge, shadow, LEVEL_MASK)

    local outer = badge:CreateTexture(nil, "BACKGROUND")
    outer:SetColorTexture(0.56, 0.39, 0.05, 0.95)
    local outerMask = AddShapeMask(badge, outer, LEVEL_MASK)

    local inner = badge:CreateTexture(nil, "ARTWORK")
    inner:SetColorTexture(0.025, 0.035, 0.050, 0.94)
    local innerMask = AddShapeMask(badge, inner, LEVEL_MASK)

    -- A faint color-tinted interior layer helps the badge feel slightly more
    -- integrated with its difficulty color without becoming flashy.
    local accent = badge:CreateTexture(nil, "ARTWORK", nil, 1)
    accent:SetColorTexture(1, 1, 1, 0.10)
    local accentMask = AddShapeMask(badge, accent, LEVEL_MASK)

    local text = badge:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", 0, 0)
    text:SetFont(FONT_NORMAL, 12, "OUTLINE")
    text:SetTextColor(unpack(COLORS.gold))
    text:SetShadowColor(0, 0, 0, 1)
    text:SetShadowOffset(1, -1)

    local skull = badge:CreateTexture(nil, "OVERLAY")
    skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    -- Keep the skull inside the normal level tablet, but let it protrude slightly vertically.
    skull:SetSize(28, 28)
    skull:SetPoint("CENTER", badge, "CENTER", 0, 1)
    skull:Hide()

    badge.SoftShadow = softShadow
    badge.Shadow = shadow
    badge.Outer = outer
    badge.Inner = inner
    badge.Accent = accent
    badge.Text = text
    badge.Skull = skull
    badge.ShapeMasks = { softShadowMask, shadowMask, outerMask, innerMask, accentMask }
    return badge
end

local function CreateLeaderIcon(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 16)
    holder:SetSize(21, 21)
    holder:EnableMouse(false)
    holder:Hide()

    local icon = holder:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints(holder)
    icon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    icon:SetTexCoord(0, 1, 0, 1)

    holder.Icon = icon
    return holder
end

local function CreateRaidTargetIcon(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 18)
    holder:SetSize(28, 28)
    holder:EnableMouse(false)
    holder:Hide()

    local icon = holder:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints(holder)
    icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

    holder.Icon = icon
    return holder
end

local RAID_TARGET_TEX_COORDS = {
    [1] = { 0.00, 0.25, 0.00, 0.25 }, -- Star
    [2] = { 0.25, 0.50, 0.00, 0.25 }, -- Circle
    [3] = { 0.50, 0.75, 0.00, 0.25 }, -- Diamond
    [4] = { 0.75, 1.00, 0.00, 0.25 }, -- Triangle
    [5] = { 0.00, 0.25, 0.25, 0.50 }, -- Moon
    [6] = { 0.25, 0.50, 0.25, 0.50 }, -- Square
    [7] = { 0.50, 0.75, 0.25, 0.50 }, -- Cross
    [8] = { 0.75, 1.00, 0.25, 0.50 }, -- Skull
}

local function SetRaidTargetTexture(texture, index)
    if not texture or not index then
        return
    end

    if SetRaidTargetIconTexture then
        SetRaidTargetIconTexture(texture, index)
        return
    end

    -- Fallback for Classic branches where the FrameXML helper is unavailable.
    texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    local coords = RAID_TARGET_TEX_COORDS[index]
    if coords then
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end
end

local function CreateCombatBadge(parent)
    local badge = CreateFrame("Frame", nil, parent)
    badge:SetFrameLevel(parent:GetFrameLevel() + 11)
    badge:SetSize(26, 26)
    badge:Hide()

    local pulse = badge:CreateTexture(nil, "BACKGROUND", nil, -4)
    pulse:SetColorTexture(0.82, 0.08, 0.055, 1.00)
    pulse:SetAlpha(0)
    local pulseMask = AddShapeMask(badge, pulse, COMBAT_BADGE_MASK)

    local outer = badge:CreateTexture(nil, "BACKGROUND", nil, -3)
    outer:SetColorTexture(0.56, 0.055, 0.035, 0.96)
    local outerMask = AddShapeMask(badge, outer, COMBAT_BADGE_MASK)

    local inner = badge:CreateTexture(nil, "ARTWORK", nil, -2)
    inner:SetColorTexture(0.025, 0.028, 0.038, 0.98)
    local innerMask = AddShapeMask(badge, inner, COMBAT_BADGE_MASK)

    local ring = badge:CreateTexture(nil, "ARTWORK", nil, -1)
    ring:SetColorTexture(0.88, 0.16, 0.10, 0.72)
    local ringMask = AddShapeMask(badge, ring, COMBAT_BADGE_MASK)

    local icon = badge:CreateTexture(nil, "OVERLAY")
    icon:SetTexture("Interface\\Icons\\Ability_DualWield")
    icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)

    badge.Pulse = pulse
    badge.Outer = outer
    badge.Inner = inner
    badge.Ring = ring
    badge.Icon = icon
    badge.ShapeMasks = { pulseMask, outerMask, innerMask, ringMask }

    return badge
end

local COMBAT_REST_SPARK_LAYOUT = {
    { point = "TOPLEFT",     relPoint = "TOPLEFT",     x = 6,   y = 5,  size = 31 },
    { point = "TOP",         relPoint = "TOP",         x = -10, y = 10, size = 36 },
    { point = "TOPRIGHT",    relPoint = "TOPRIGHT",    x = 1,   y = 4,  size = 30 },
    { point = "RIGHT",       relPoint = "RIGHT",       x = 8,   y = 9,  size = 33 },
    { point = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", x = 4,   y = -2, size = 29 },
    { point = "BOTTOM",      relPoint = "BOTTOM",      x = -10, y = -8, size = 34 },
    { point = "BOTTOMLEFT",  relPoint = "BOTTOMLEFT",  x = -1,  y = 0,  size = 28 },
    { point = "LEFT",        relPoint = "LEFT",        x = -7,  y = 8,  size = 32 },
}

-- Combat gets the same layered glow/spark language as the resting state, but
-- in a restrained red palette. This is intentionally separate from the combat
-- badge so the icon can remain crisp while the portrait gets the richer glow.
local function CreateCombatFlair(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 10)
    holder:EnableMouse(false)
    holder:Hide()

    local outerGlow = parent:CreateTexture(nil, "BACKGROUND", nil, -8)
    outerGlow:SetColorTexture(0.92, 0.025, 0.015, 1.00)
    outerGlow:SetBlendMode("ADD")
    outerGlow:SetAlpha(0)
    local outerGlowMask = AddShapeMask(parent, outerGlow, PORTRAIT_LEFT_MASK)

    local innerGlow = parent:CreateTexture(nil, "BACKGROUND", nil, -7)
    innerGlow:SetColorTexture(1.00, 0.12, 0.055, 1.00)
    innerGlow:SetBlendMode("ADD")
    innerGlow:SetAlpha(0)
    local innerGlowMask = AddShapeMask(parent, innerGlow, PORTRAIT_LEFT_MASK)

    local sparks = {}
    for i = 1, 8 do
        local spark = holder:CreateTexture(nil, "OVERLAY", nil, 1)
        spark:SetColorTexture(1.00, 0.10, 0.045, 1.00)
        spark:SetBlendMode("ADD")
        spark:SetAlpha(0)
        local mask = AddShapeMask(holder, spark, REST_SPARK_MASK)
        sparks[i] = { texture = spark, mask = mask }
    end

    holder.Sparks = sparks
    holder.OuterGlow = outerGlow
    holder.InnerGlow = innerGlow
    holder.OuterGlowMask = outerGlowMask
    holder.InnerGlowMask = innerGlowMask

    return holder
end

local function CreateRestingIndicator(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 10)
    holder:EnableMouse(false)
    holder:Hide()

    local outerGlow = parent:CreateTexture(nil, "BACKGROUND", nil, -7)
    outerGlow:SetColorTexture(1.00, 0.68, 0.05, 1.00)
    outerGlow:SetBlendMode("ADD")
    outerGlow:SetAlpha(0)
    local outerGlowMask = AddShapeMask(parent, outerGlow, PORTRAIT_LEFT_MASK)

    local innerGlow = parent:CreateTexture(nil, "BACKGROUND", nil, -6)
    innerGlow:SetColorTexture(1.00, 0.88, 0.18, 1.00)
    innerGlow:SetBlendMode("ADD")
    innerGlow:SetAlpha(0)
    local innerGlowMask = AddShapeMask(parent, innerGlow, PORTRAIT_LEFT_MASK)

    local icon = holder:CreateTexture(nil, "OVERLAY", nil, 4)
    icon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    icon:SetTexCoord(0.0625, 0.4375, 0.0625, 0.4375)
    icon:SetBlendMode("BLEND")

    local zs = {}
    local zSizes = { 13, 16, 22 }
    for i = 1, 3 do
        local z = holder:CreateFontString(nil, "OVERLAY", nil, 5)
        z:SetFont(FONT_NORMAL, zSizes[i], "THICKOUTLINE")
        z:SetText("Z")
        z:SetTextColor(1.00, 0.78, 0.08, 1.00)
        z:SetShadowColor(0.08, 0.04, 0.00, 1.00)
        z:SetShadowOffset(2, -2)
        z:Hide()
        zs[i] = z
    end

    local sparks = {}
    for i = 1, 8 do
        local spark = holder:CreateTexture(nil, "OVERLAY", nil, 1)
        spark:SetColorTexture(1.00, 0.82, 0.12, 1.00)
        spark:SetBlendMode("ADD")
        spark:SetAlpha(0)
        local mask = AddShapeMask(holder, spark, REST_SPARK_MASK)
        sparks[i] = { texture = spark, mask = mask }
    end

    holder.Icon = icon
    holder.Zs = zs
    holder.Sparks = sparks
    holder.OuterGlow = outerGlow
    holder.InnerGlow = innerGlow
    holder.OuterGlowMask = outerGlowMask
    holder.InnerGlowMask = innerGlowMask
    holder.elapsed = 0

    return holder
end

local function CreatePlayerCornerOrnament(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 5)
    holder:SetAllPoints(parent)
    holder:EnableMouse(false)
    holder:Hide()

    -- v0.22.34 simplifies the player corner detail down to the cleaner
    -- Retail-inspired L-shape only. The larger image ornament is retired.
    local simple = CreateFrame("Frame", nil, holder)
    simple:SetAllPoints(parent)
    simple:EnableMouse(false)
    simple:Hide()

    local function CreateRect(w, h, point, relPoint, x, y, subLevel)
        local tex = simple:CreateTexture(nil, "OVERLAY", nil, subLevel or 4)
        tex:SetColorTexture(1, 1, 1, 1)
        tex:SetSize(w, h)
        tex:SetPoint(point, parent, relPoint, x, y)
        return tex
    end

    -- Push the ornament slightly inward so it breathes away from the corner.
    -- Keep both arms perfectly matched in length and thickness so the corner
    -- reads as one clean L-shape, just a hair thicker than before.
    local shadowH = CreateRect(18, 5, "BOTTOMRIGHT", "BOTTOMRIGHT", -10, 11, 4)
    local shadowV = CreateRect(5, 18, "BOTTOMRIGHT", "BOTTOMRIGHT", -10, 11, 4)
    local mainH = CreateRect(16, 3, "BOTTOMRIGHT", "BOTTOMRIGHT", -11, 12, 5)
    local mainV = CreateRect(3, 16, "BOTTOMRIGHT", "BOTTOMRIGHT", -11, 12, 5)

    holder.Simple = simple
    holder.SimpleShadowH = shadowH
    holder.SimpleShadowV = shadowV
    holder.SimpleMainH = mainH
    holder.SimpleMainV = mainV
    return holder
end

local function CreateClassificationDragon(parent)
    -- Keep the dragon above both the static portrait and the optional 3D model.
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 4)
    holder:SetAllPoints(parent)
    holder:EnableMouse(false)

    local texture = holder:CreateTexture(nil, "ARTWORK", nil, 4)
    texture:Hide()
    texture:SetAlpha(0.98)
    texture:SetBlendMode("BLEND")
    return texture
end

local function CreatePVPStatus(parent, unit)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 12)
    holder:SetSize(44, 40)
    holder:EnableMouse(false)
    holder.unit = unit
    holder:Hide()

    local icon = holder:CreateTexture(nil, "OVERLAY")
    icon:SetSize(36, 36)
    icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)

    local timer = holder:CreateFontString(nil, "OVERLAY")
    timer:SetFont(FONT_NORMAL, 12, "THICKOUTLINE")
    ApplyPVPTimerTextColor(timer, SUF and SUF.db)
    timer:SetShadowColor(0, 0, 0, 1)
    timer:SetShadowOffset(2, -2)
    timer:SetText("")

    holder.Icon = icon
    holder.TimerText = timer
    holder.elapsed = 0

    return holder
end

local function CreatePartyTargetIndicator(parent, ownerUnit)
    local targetUnit = ownerUnit .. "target"
    local globalName = "SleekUnitFramesTBC_" .. ownerUnit:gsub("^%l", string.upper) .. "TargetFrame"
    local holder = CreateFrame("Button", globalName, parent, "SecureUnitButtonTemplate")
    holder:SetFrameLevel(parent:GetFrameLevel() + 11)
    holder:EnableMouse(true)
    holder:RegisterForClicks("AnyUp")
    holder:SetAttribute("unit", targetUnit)
    holder:SetAttribute("*type1", "target")
    holder:SetAttribute("*type2", "togglemenu")
    holder.ownerUnit = ownerUnit
    holder.targetUnit = targetUnit
    holder.unit = targetUnit
    holder.isMirrored = false
    holder:Hide()

    holder:SetScript("OnEnter", function(self)
        if UnitFrame_OnEnter then
            UnitFrame_OnEnter(self)
        end
    end)
    holder:SetScript("OnLeave", function(self)
        if UnitFrame_OnLeave then
            UnitFrame_OnLeave(self)
        else
            GameTooltip:Hide()
        end
    end)

    local body = CreateFrame("Frame", nil, holder)
    body:SetFrameLevel(holder:GetFrameLevel() + 2)

    local outer = CreateSolid(body, "BACKGROUND", BODY_WRAPPER_BASE_OUTER)
    outer:SetAllPoints()
    local outerMask = AddShapeMask(body, outer, BODY_RIGHT_MASK)

    local edge = CreateSolid(body, "BORDER", BODY_WRAPPER_BASE_EDGE)
    edge:SetPoint("TOPLEFT", 1, -1)
    edge:SetPoint("BOTTOMRIGHT", -1, 1)
    local edgeMask = AddShapeMask(body, edge, BODY_RIGHT_MASK)

    local inner = CreateSolid(body, "ARTWORK", BODY_WRAPPER_BASE_INNER, -1)
    inner:SetPoint("TOPLEFT", 2, -2)
    inner:SetPoint("BOTTOMRIGHT", -2, 2)
    local innerMask = AddShapeMask(body, inner, BODY_RIGHT_MASK)

    local header = CreateFrame("Frame", nil, body)
    local nameText = header:CreateFontString(nil, "OVERLAY")
    nameText:SetFont(FONT_NORMAL, 17, "OUTLINE")
    nameText:SetTextColor(unpack(COLORS.gold))
    nameText:SetShadowColor(0, 0, 0, 1)
    nameText:SetShadowOffset(1, -1)
    nameText:SetJustifyH("CENTER")
    if nameText.SetWordWrap then nameText:SetWordWrap(false) end
    if nameText.SetMaxLines then nameText:SetMaxLines(1) end

    local health = CreateBar(body)
    ApplyBarFillGradient(health, HEALTH_GREEN)
    ApplyBarBackgroundGradient(health, COLORS.healthBackgroundBottom, COLORS.healthBackgroundTop)

    local power = CreateBar(body)
    ApplyBarFillGradient(power, POWER_COLORS.MANA)
    ApplyBarBackgroundGradient(power, COLORS.powerBackgroundBottom, COLORS.powerBackgroundTop)

    local portraitFrame = CreatePortrait(holder)

    holder.Body = body
    holder.BodyOuter = outer
    holder.BodyOuterMask = outerMask
    holder.BodyEdge = edge
    holder.BodyEdgeMask = edgeMask
    holder.BodyInner = inner
    holder.BodyInnerMask = innerMask
    holder.Header = header
    holder.NameText = nameText
    holder.Health = health
    holder.Power = power
    holder.PortraitFrame = portraitFrame

    return holder
end

local function GetPVPIconTexture(unit, isFFA)
    local db = SUF and SUF.db
    local useCustom = db and db.useCustomPVPIcons

    if useCustom then
        if isFFA then
            return CUSTOM_PVP_FFA
        end

        local factionGroup = UnitFactionGroup and UnitFactionGroup(unit)
        if factionGroup == "Alliance" then
            return CUSTOM_PVP_ALLIANCE
        elseif factionGroup == "Horde" then
            return CUSTOM_PVP_HORDE
        end

        return CUSTOM_PVP_FFA
    end

    if isFFA then
        return "Interface\\TargetingFrame\\UI-PVP-FFA"
    end

    local factionGroup = UnitFactionGroup and UnitFactionGroup(unit)
    if factionGroup == "Alliance" or factionGroup == "Horde" then
        return "Interface\\TargetingFrame\\UI-PVP-" .. factionGroup
    end

    return "Interface\\TargetingFrame\\UI-PVP-FFA"
end

local function FormatPVPClearTimer(milliseconds)
    local seconds = math.max(0, math.ceil((tonumber(milliseconds) or 0) / 1000))
    local minutes = math.floor(seconds / 60)
    return string.format("%d:%02d", minutes, seconds % 60)
end

local function CreatePetCombatFeedback(portraitFrame)
    local controller = CreateFrame("Frame", nil, portraitFrame)
    controller:SetFrameLevel(portraitFrame:GetFrameLevel() + 20)
    controller:SetAllPoints(portraitFrame)

    local text = controller:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", portraitFrame, "CENTER", 0, 0)
    text:SetFont(FONT_NORMAL, 23, "OUTLINE")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetShadowColor(0, 0, 0, 1)
    text:SetShadowOffset(1, -1)
    text:Hide()

    controller.feedbackText = text
    controller.feedbackFontHeight = 23

    if CombatFeedback_Initialize then
        CombatFeedback_Initialize(controller, text, 23)
    end

    controller:SetScript("OnUpdate", function(self, elapsed)
        if self.feedbackText and self.feedbackText:IsShown() and CombatFeedback_OnUpdate then
            CombatFeedback_OnUpdate(self, elapsed)
        end
    end)

    return controller
end

local function CreateUnitFrame(unit)
    local config = FRAME_CONFIG[unit]
    local globalName = "SleekUnitFramesTBC_" .. unit:gsub("^%l", string.upper) .. "Frame"
    local frame = CreateFrame("Button", globalName, UIParent, "SecureUnitButtonTemplate")

    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    if frame.SetUserPlaced then frame:SetUserPlaced(false) end
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyUp")
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame.unit = unit
    frame.isMirrored = config.mirror

    local bodyShadow = CreateSolid(frame, "BACKGROUND", COLORS.shadow, -8)

    local body = CreateFrame("Frame", nil, frame)
    body:SetFrameLevel(frame:GetFrameLevel() + 2)
    local lowHealthGlow = (unit == "player") and CreateLowHealthGlow(frame) or nil

    -- Body acts as a soft parent wrapper behind the header, health and power,
    -- closer to the Retail reference where the top plate visually contains the
    -- whole frame cluster.
    local outer = CreateSolid(body, "BACKGROUND", BODY_WRAPPER_BASE_OUTER)
    outer:SetAllPoints()
    local outerMask = AddShapeMask(body, outer, BODY_RIGHT_MASK)

    local edge = CreateSolid(body, "BORDER", BODY_WRAPPER_BASE_EDGE)
    edge:SetPoint("TOPLEFT", 1, -1)
    edge:SetPoint("BOTTOMRIGHT", -1, 1)
    local edgeMask = AddShapeMask(body, edge, BODY_RIGHT_MASK)

    local inner = CreateSolid(body, "ARTWORK", BODY_WRAPPER_BASE_INNER, -1)
    inner:SetPoint("TOPLEFT", 2, -2)
    inner:SetPoint("BOTTOMRIGHT", -2, 2)
    local innerMask = AddShapeMask(body, inner, BODY_RIGHT_MASK)

    -- Target relation visuals live on their own independent overlays. This is
    -- important: BodyEdge is a full rectangle underneath BodyInner, so tinting
    -- BodyEdge also tints the card interior through BodyInner's transparency.
    -- Dedicated layers make background opacity and border opacity truly
    -- independent controls.
    local relationTint = CreateSolid(body, "ARTWORK", { 0, 0, 0, 1 }, 0)
    relationTint:SetAllPoints(body)
    relationTint:SetAlpha(0)
    relationTint:Hide()
    local relationTintMask = AddShapeMask(body, relationTint, BODY_RIGHT_MASK)

    -- Border gets its own child frame above the bars/header but below the
    -- portrait. Parent-frame textures can sit underneath child frames in WoW,
    -- which made the previous 0.22.20 border effectively invisible.
    local relationBorderFrame = CreateFrame("Frame", nil, body)
    relationBorderFrame:SetAllPoints(body)
    relationBorderFrame:SetFrameLevel(body:GetFrameLevel() + 4)
    relationBorderFrame:EnableMouse(false)

    local relationBorder = CreateSolid(relationBorderFrame, "OVERLAY", { 0, 0, 0, 1 }, 0)
    relationBorder:SetAllPoints(relationBorderFrame)
    relationBorder:SetAlpha(0)
    relationBorder:Hide()
    local relationBorderMask = AddShapeMask(relationBorderFrame, relationBorder, ADDON_MEDIA .. "BodyRightTightBorder.tga")

    local header = CreateFrame("Frame", nil, body)
    local headerBorder = CreateSolid(header, "BACKGROUND", { 0.020, 0.035, 0.055, 0.00 })
    headerBorder:SetAllPoints()
    local headerBorderMask = AddShapeMask(header, headerBorder, HEADER_MASK)

    local headerFill = header:CreateTexture(nil, "BORDER")
    headerFill:SetPoint("TOPLEFT", 2, -2)
    headerFill:SetPoint("BOTTOMRIGHT", -2, 2)
    SetGradient(headerFill, COLORS.headerBottom, COLORS.headerTop)
    headerFill:SetAlpha(0)
    local headerFillMask = AddShapeMask(header, headerFill, HEADER_MASK)

    -- Reaction tint used by Target / Target of Target. Unlike the old masked
    -- HeaderFill, this deliberately fills the entire rectangular name area.
    -- The parent wrapper already supplies the outer silhouette, so avoiding a
    -- second rounded mask keeps the treatment clean rather than pill-shaped.
    local headerReactionFill = header:CreateTexture(nil, "BORDER", nil, 1)
    headerReactionFill:SetAllPoints(header)
    headerReactionFill:SetTexture(WHITE_TEXTURE)
    headerReactionFill:SetAlpha(0)
    headerReactionFill:Hide()

    local headerTopLine = header:CreateTexture(nil, "ARTWORK")
    headerTopLine:SetAlpha(0)

    local nameText = header:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("CENTER")
    nameText:SetFont(FONT_NORMAL, 17, "OUTLINE")
    nameText:SetTextColor(unpack(COLORS.gold))
    nameText:SetShadowColor(0, 0, 0, 1)
    nameText:SetShadowOffset(1, -1)

    local headerLevel = header:CreateFontString(nil, "OVERLAY")
    headerLevel:SetFont(FONT_NORMAL, 11, "OUTLINE")
    headerLevel:SetTextColor(unpack(COLORS.muted))
    headerLevel:SetShadowColor(0, 0, 0, 1)
    headerLevel:SetShadowOffset(1, -1)

    local raidGroupText = header:CreateFontString(nil, "OVERLAY")
    raidGroupText:SetFont(FONT_NORMAL, 10, "OUTLINE")
    raidGroupText:SetTextColor(0.88, 0.80, 0.34, 1)
    raidGroupText:SetShadowColor(0, 0, 0, 1)
    raidGroupText:SetShadowOffset(1, -1)

    local combatText = header:CreateFontString(nil, "OVERLAY")
    combatText:SetPoint("RIGHT", header, "RIGHT", -11, 0)
    combatText:SetFont(FONT_NORMAL, 9, "OUTLINE")
    combatText:SetTextColor(unpack(COLORS.combat))
    combatText:SetShadowColor(0, 0, 0, 1)
    combatText:SetShadowOffset(1, -1)
    combatText:SetText("")

    local health = CreateBar(body)
    ApplyBarFillGradient(health, HEALTH_GREEN)
    ApplyBarBackgroundGradient(health, COLORS.healthBackgroundBottom, COLORS.healthBackgroundTop)

    local power = CreateBar(body)
    ApplyBarFillGradient(power, POWER_COLORS.MANA)
    ApplyBarBackgroundGradient(power, COLORS.powerBackgroundBottom, COLORS.powerBackgroundTop)

    local portraitFrame = CreatePortrait(frame)
    local levelBadge = CreateLevelBadge(portraitFrame)
    local leaderIcon = (unit == "player" or unit == "target" or unit:match("^party%d$")) and CreateLeaderIcon(portraitFrame) or nil
    local raidTargetIcon = (unit == "player" or unit == "target" or unit == "targettarget" or unit == "focus" or unit:match("^party%d$")) and CreateRaidTargetIcon(portraitFrame) or nil
    local combatBadge = (unit == "player" or unit == "pet") and CreateCombatBadge(portraitFrame) or nil
    local combatFlair = (unit == "player" or unit == "pet") and CreateCombatFlair(portraitFrame) or nil
    local restingIndicator = (unit == "player") and CreateRestingIndicator(portraitFrame) or nil
    local playerCornerOrnament = (unit == "player") and CreatePlayerCornerOrnament(portraitFrame) or nil
    local petCombatFeedback = (unit == "pet") and CreatePetCombatFeedback(portraitFrame) or nil
    local classificationDragon = (unit == "target") and CreateClassificationDragon(portraitFrame) or nil
    local pvpStatus = (unit == "player" or unit == "target" or unit:match("^party%d$")) and CreatePVPStatus(portraitFrame, unit) or nil
    local mover = CreateMover(frame, unit, config.label)

    frame:SetScript("OnEnter", function(self)
        if UnitFrame_OnEnter then
            UnitFrame_OnEnter(self)
        end
    end)

    frame:SetScript("OnLeave", function(self)
        if UnitFrame_OnLeave then
            UnitFrame_OnLeave(self)
        else
            GameTooltip:Hide()
        end
    end)

    frame.BodyShadow = bodyShadow
    frame.Body = body
    frame.LowHealthGlow = lowHealthGlow
    frame.BodyOuter = outer
    frame.BodyOuterMask = outerMask
    frame.BodyEdge = edge
    frame.BodyEdgeMask = edgeMask
    frame.BodyInner = inner
    frame.BodyInnerMask = innerMask
    frame.BodyRelationTint = relationTint
    frame.BodyRelationTintMask = relationTintMask
    frame.BodyRelationBorderFrame = relationBorderFrame
    frame.BodyRelationBorder = relationBorder
    frame.BodyRelationBorderMask = relationBorderMask
    frame.Header = header
    frame.HeaderBorder = headerBorder
    frame.HeaderBorderMask = headerBorderMask
    frame.HeaderFill = headerFill
    frame.HeaderFillMask = headerFillMask
    frame.HeaderReactionFill = headerReactionFill
    frame.NameText = nameText
    frame.HeaderLevel = headerLevel
    frame.RaidGroupText = raidGroupText
    frame.CombatText = combatText
    frame.Health = health
    frame.Power = power
    frame.PortraitFrame = portraitFrame
    frame.LevelBadge = levelBadge
    frame.LeaderIcon = leaderIcon
    frame.RaidTargetIcon = raidTargetIcon
    frame.CombatBadge = combatBadge
    frame.CombatFlair = combatFlair
    frame.RestingIndicator = restingIndicator
    frame.PlayerCornerOrnament = playerCornerOrnament
    frame.PetCombatFeedback = petCombatFeedback
    frame.ClassificationDragon = classificationDragon
    frame.PVPStatus = pvpStatus
    frame.Mover = mover

    if unit == "target" then
        SUF:CreateTargetExtras(frame)
    elseif unit:match("^party%d$") then
        SUF:CreatePartyExtras(frame, unit)
    end

    return frame
end

function SUF:CreateUnitFrames()
    if self.UnitFrames then
        return
    end

    self.UnitFrames = {
        player = CreateUnitFrame("player"),
        target = CreateUnitFrame("target"),
        targettarget = CreateUnitFrame("targettarget"),
        focus = CreateUnitFrame("focus"),
        pet = CreateUnitFrame("pet"),
        party1 = CreateUnitFrame("party1"),
        party2 = CreateUnitFrame("party2"),
        party3 = CreateUnitFrame("party3"),
        party4 = CreateUnitFrame("party4"),
    }

    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_LEVEL_UP")
    events:RegisterEvent("PLAYER_DEAD")
    events:RegisterEvent("PLAYER_ALIVE")
    events:RegisterEvent("PLAYER_UNGHOST")
    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("PLAYER_UPDATE_RESTING")
    events:RegisterEvent("ZONE_CHANGED")
    events:RegisterEvent("ZONE_CHANGED_INDOORS")
    events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    events:RegisterEvent("PLAYER_TARGET_CHANGED")
    events:RegisterEvent("PLAYER_FOCUS_CHANGED")
    events:RegisterEvent("UNIT_TARGET")
    events:RegisterEvent("UNIT_COMBO_POINTS")
    events:RegisterEvent("GROUP_ROSTER_UPDATE")
    events:RegisterEvent("PARTY_LEADER_CHANGED")
    events:RegisterEvent("RAID_TARGET_UPDATE")
    events:RegisterEvent("PVP_TIMER_UPDATE")
    events:RegisterEvent("UNIT_FACTION")
    events:RegisterEvent("UNIT_FLAGS")
    events:RegisterEvent("UNIT_CONNECTION")
    events:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
    events:RegisterEvent("UNIT_PET")
    events:RegisterEvent("UNIT_HEALTH")
    events:RegisterEvent("UNIT_MAXHEALTH")
    events:RegisterEvent("UNIT_POWER_FREQUENT")
    events:RegisterEvent("UNIT_MAXPOWER")
    events:RegisterEvent("UNIT_DISPLAYPOWER")
    events:RegisterEvent("UNIT_NAME_UPDATE")
    events:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    events:RegisterEvent("UNIT_COMBAT")
    events:RegisterEvent("UNIT_AURA")
    events:RegisterEvent("SPELL_TEXT_UPDATE")
    events:RegisterEvent("UNIT_SPELLCAST_START")
    events:RegisterEvent("UNIT_SPELLCAST_STOP")
    events:RegisterEvent("UNIT_SPELLCAST_FAILED")
    events:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    events:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    events:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    events:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    events:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

    events:SetScript("OnEvent", function(_, event, unit, arg2, arg3, arg4, arg5)
        if event == "PLAYER_ENTERING_WORLD" then
            SUF:RefreshAllUnitFrames(true)
            SUF:UpdateComboPoints()
            SUF:UpdateTargetAuras()
            SUF:UpdateAllPartyAuras()
            SUF:UpdateTargetCastbar()
            SUF:UpdateCombatIndicator(false)
            SUF:UpdatePetCombatIndicator(true)
            SUF:UpdateRestingIndicator()
            SUF:UpdatePVPStatuses()
            SUF:UpdateTargetClassification()
            return
        elseif event == "PLAYER_LEVEL_UP" then
            SUF:UpdateUnitFrame("player", true)
            SUF:UpdateUnitFrame("target", true)
            SUF:UpdateUnitFrame("targettarget", true)
            SUF:UpdateUnitFrame("focus", true)
            return
        elseif event == "PLAYER_DEAD" or event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
            -- Update immediately as the player moves corpse -> ghost -> alive.
            -- UNIT_HEALTH/UNIT_FLAGS still handle equivalent state changes for
            -- target and target-of-target units.
            SUF:UpdateUnitFrame("player", true)
            SUF:UpdateLowHealthIndicator()
            return
        elseif event == "PLAYER_REGEN_DISABLED" then
            SUF:UpdateCombatIndicator(true)
            SUF:UpdateRestingIndicator()
            -- Re-evaluate NPC name colors immediately when combat begins so a
            -- just-attacked neutral target does not remain yellow for a frame.
            SUF:UpdateUnitFrame("target", false)
            SUF:UpdateUnitFrame("targettarget", false)
            SUF:UpdateUnitFrame("focus", false)
            return
        elseif event == "PLAYER_REGEN_ENABLED" then
            SUF:UpdateCombatIndicator(false)
            SUF:UpdateRestingIndicator()
            return
        elseif event == "PLAYER_UPDATE_RESTING" then
            SUF:UpdateRestingIndicator()
            SUF:UpdateUnitFrame("target", false)
            SUF:UpdateUnitFrame("targettarget", false)
            SUF:UpdateUnitFrame("focus", false)
            return
        elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
            -- Level-difficulty colors intentionally collapse back to the normal
            -- gold treatment in cities/resting areas and sanctuary zones.
            SUF:UpdateRestingIndicator()
            SUF:UpdateUnitFrame("target", false)
            SUF:UpdateUnitFrame("targettarget", false)
            SUF:UpdateUnitFrame("focus", false)
            return
        elseif event == "SPELL_TEXT_UPDATE" then
            if SUF.ClearAuraClassificationCache then
                SUF:ClearAuraClassificationCache()
            end
            SUF:UpdateTargetAuras()
            SUF:UpdateAllPartyAuras()
            return
        elseif event == "PLAYER_TARGET_CHANGED" then
            SUF:UpdateUnitFrame("target", true)
            SUF:UpdateUnitFrame("targettarget", true)
            SUF:UpdateComboPoints()
            SUF:UpdateTargetAuras()
            SUF:UpdateTargetCastbar()
            SUF:UpdatePVPStatus("target")
            SUF:UpdateTargetClassification()
            SUF:UpdatePetCombatIndicator(true)
            return
        elseif event == "PLAYER_FOCUS_CHANGED" then
            SUF:UpdateUnitFrame("focus", true)
            return
        elseif event == "UNIT_COMBO_POINTS" then
            SUF:UpdateComboPoints()
            return
        elseif event == "UNIT_TARGET" then
            if unit == "target" then
                SUF:UpdateUnitFrame("targettarget", true)
                SUF:UpdatePetCombatIndicator(true)
            elseif type(unit) == "string" and unit:match("^party%d$") then
                SUF:UpdatePartyTarget(unit, true)
            end
            return
        elseif event == "GROUP_ROSTER_UPDATE" then
            SUF:RefreshUnitWatches()
            SUF:ApplyBlizzardFramesVisibility()
            SUF:UpdateUnitFrame("player", true)
            SUF:UpdateUnitFrame("target", true)
            SUF:UpdateUnitFrame("targettarget", true)
            SUF:UpdateUnitFrame("focus", true)
            for i = 1, 4 do
                SUF:UpdateUnitFrame("party" .. i, true)
            end
            SUF:UpdateAllPartyAuras()
            SUF:UpdateAllPartyTargets(true)
            SUF:UpdatePVPStatuses()
            return
        elseif event == "PARTY_LEADER_CHANGED" then
            SUF:UpdateUnitFrame("player", true)
            SUF:UpdateUnitFrame("target", true)
            for i = 1, 4 do
                SUF:UpdateUnitFrame("party" .. i, true)
            end
            return
        elseif event == "RAID_TARGET_UPDATE" then
            -- Raid markers can be assigned/changed while the unit itself is
            -- otherwise unchanged. Refresh every custom frame that can display
            -- one, including the player, target-of-target and party members.
            SUF:UpdateUnitFrame("player", false)
            SUF:UpdateUnitFrame("target", false)
            SUF:UpdateUnitFrame("targettarget", false)
            SUF:UpdateUnitFrame("focus", false)
            for i = 1, 4 do
                SUF:UpdateUnitFrame("party" .. i, false)
            end
            return
        elseif event == "PVP_TIMER_UPDATE" then
            SUF:UpdatePVPStatus("player")
            return
        elseif event == "UNIT_CONNECTION" then
            -- UNIT_CONNECTION commonly arrives with the party/raid token that
            -- changed, not necessarily the equivalent "target" token. Refresh
            -- both visible target frames and the matching party slot immediately.
            SUF:UpdateUnitFrame("target", true)
            SUF:UpdateUnitFrame("targettarget", true)
            SUF:UpdateUnitFrame("focus", true)
            if type(unit) == "string" and unit:match("^party%d$") then
                SUF:UpdateUnitFrame(unit, true)
                SUF:UpdatePartyAuras(unit)
                SUF:UpdatePartyTarget(unit, true)
                SUF:UpdatePVPStatus(unit)
            else
                local partyTargetOwner = type(unit) == "string" and unit:match("^(party%d)target$")
                if partyTargetOwner then
                    SUF:UpdatePartyTarget(partyTargetOwner, true)
                end
            end
            return
        elseif event == "UNIT_CLASSIFICATION_CHANGED" and unit == "target" then
            SUF:UpdateTargetClassification()
            return
        elseif event == "UNIT_FACTION" then
            if unit == "player" or unit == "target" or (type(unit) == "string" and unit:match("^party%d$")) then
                SUF:UpdatePVPStatus(unit)
            end
            if unit == "target" or unit == "targettarget" or unit == "focus" then
                SUF:UpdateUnitFrame(unit, false)
            end
            local partyTargetOwner = type(unit) == "string" and unit:match("^(party%d)target$")
            if partyTargetOwner then
                SUF:UpdatePartyTarget(partyTargetOwner)
            end
            return
        elseif event == "UNIT_FLAGS" then
            if unit == "target" or unit == "targettarget" or unit == "focus" then
                -- Tap ownership is exposed through the unit flags. Refresh the
                -- target relationship/name state immediately when it changes.
                SUF:UpdateUnitFrame(unit, false)
            elseif type(unit) == "string" and unit:match("^party%d$") then
                SUF:UpdatePVPStatus(unit)
            end
            local partyTargetOwner = type(unit) == "string" and unit:match("^(party%d)target$")
            if partyTargetOwner then
                SUF:UpdatePartyTarget(partyTargetOwner)
            end
            return
        elseif event == "UNIT_PET" and unit == "player" then
            SUF:UpdateUnitFrame("pet", true)
            SUF:UpdatePetCombatIndicator(true)
            return
        elseif event == "UNIT_COMBAT" and unit == "pet" then
            SUF:HandlePetCombatFeedback(arg2, arg3, arg4, arg5)
            SUF:UpdatePetCombatIndicator(true)
            SUF:UpdateUnitFrame("pet", false)
            return
        end

        local partyTargetOwner = type(unit) == "string" and unit:match("^(party%d)target$")
        if partyTargetOwner then
            local forcePartyTarget = event == "UNIT_PORTRAIT_UPDATE"
                or event == "UNIT_NAME_UPDATE"
                or event == "UNIT_DISPLAYPOWER"
                or event == "UNIT_CONNECTION"
            SUF:UpdatePartyTarget(partyTargetOwner, forcePartyTarget)
            return
        end

        if event == "UNIT_POWER_FREQUENT" and unit == "player" and (arg2 == "COMBO_POINTS" or arg2 == "COMBOPOINTS") then
            SUF:UpdateComboPoints()
        end

        local managedPartyUnit = type(unit) == "string" and unit:match("^party%d$")
        if unit ~= "player" and unit ~= "target" and unit ~= "targettarget" and unit ~= "focus" and unit ~= "pet" and not managedPartyUnit then
            return
        end

        if event == "UNIT_AURA" then
            if unit == "target" then
                SUF:UpdateTargetAuras()
            elseif managedPartyUnit then
                SUF:UpdatePartyAuras(unit)
            end
            return
        end

        if event:find("UNIT_SPELLCAST", 1, true) then
            if unit == "target" then
                SUF:UpdateTargetCastbar()
            end
            return
        end

        local fullUpdate = event == "UNIT_NAME_UPDATE" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_DISPLAYPOWER"
        SUF:UpdateUnitFrame(unit, fullUpdate)
    end)

    events.petCombatPollElapsed = 0
    events.animatedPortraitPollElapsed = 0
    events:SetScript("OnUpdate", function(self, elapsed)
        self.petCombatPollElapsed = (self.petCombatPollElapsed or 0) + elapsed
        if self.petCombatPollElapsed >= 0.20 then
            self.petCombatPollElapsed = 0
            SUF:UpdatePetCombatIndicator(false)
        end

        if SUF.db and SUF.db.showAnimatedPortraits then
            self.animatedPortraitPollElapsed = (self.animatedPortraitPollElapsed or 0) + elapsed
            if self.animatedPortraitPollElapsed >= 2.0 then
                self.animatedPortraitPollElapsed = 0
                for unitName, unitFrame in pairs(SUF.UnitFrames or {}) do
                    if UnitExists(unitName) and unitFrame and unitFrame.PortraitFrame and unitFrame.PortraitFrame.AnimatedModel then
                        local model = unitFrame.PortraitFrame.AnimatedModel
                        local visible = unitName == "player" or not UnitIsVisible or UnitIsVisible(unitName)
                        if model.lastVisible ~= (visible and true or false) or (visible and not model.modelReady) then
                            SUF:UpdateAnimatedPortrait(unitFrame, unitName, false, IsUnitOffline(unitName), true)
                        end
                    end
                end
                for i = 1, 4 do
                    local ownerUnit = "party" .. i
                    local ownerFrame = SUF:GetUnitFrame(ownerUnit)
                    local partyTarget = ownerFrame and ownerFrame.PartyTarget
                    local targetUnit = partyTarget and partyTarget.targetUnit
                    local portraitFrame = partyTarget and partyTarget.PortraitFrame
                    local model = portraitFrame and portraitFrame.AnimatedModel
                    if targetUnit and UnitExists(targetUnit) and model then
                        local visible = not UnitIsVisible or UnitIsVisible(targetUnit)
                        if model.lastVisible ~= (visible and true or false) or (visible and not model.modelReady) then
                            SUF:UpdateAnimatedPortrait(partyTarget, targetUnit, false, IsUnitOffline(targetUnit), true)
                        end
                    end
                end
            end
        else
            self.animatedPortraitPollElapsed = 0
        end
    end)

    self.UnitEventFrame = events
end

-- Keep names inside the actual header width. This helper must be declared
-- before ApplyUnitFrameLayout; v0.20.2 accidentally called a later local
-- declaration during initial layout, aborting frame creation entirely.
local function UpdateUnitNameBounds(frame)
    if not frame or not frame.Header or not frame.NameText then
        return
    end

    local sidePadding = 8
    if frame.RaidGroupText and frame.RaidGroupText:IsShown() and frame.RaidGroupText:GetText() ~= "" then
        sidePadding = 36
    end

    frame.NameText:ClearAllPoints()
    frame.NameText:SetPoint("LEFT", frame.Header, "LEFT", sidePadding, 0)
    frame.NameText:SetPoint("RIGHT", frame.Header, "RIGHT", -sidePadding, 0)
    frame.NameText:SetJustifyH("CENTER")
    if frame.NameText.SetWordWrap then
        frame.NameText:SetWordWrap(false)
    end
    if frame.NameText.SetMaxLines then
        frame.NameText:SetMaxLines(1)
    end
end

function SUF:ApplyUnitFrameLayout(frame)
    local db = self.db
    if not frame or not db then
        return
    end

    local portraitSize = math.floor(db.portraitSize + 0.5)
    local barWidth = math.floor(self:GetUnitBodyWidth(frame.unit) + 0.5)

    local overlapBehindPortrait = math.floor(portraitSize * 0.20)
    local outerPadNear = 3
    local outerPadFar = 0
    local topPad = 4
    local bottomPad = 1
    local headerHeight = 17
    local healthHeight = 31
    local powerHeight = 25
    local healthPowerOverlap = 1
    local headerGap = 3

    local wrapperWidth = barWidth + overlapBehindPortrait + outerPadNear + outerPadFar
    local wrapperHeight = topPad + headerHeight + headerGap + healthHeight + powerHeight - healthPowerOverlap + bottomPad
    local frameHeight = math.max(portraitSize + 10, wrapperHeight + 14)
    local frameWidth = portraitSize + barWidth + outerPadFar + 8

    frame:SetSize(frameWidth, frameHeight)

    frame.Body:ClearAllPoints()
    if frame.isMirrored then
        frame.Body:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -11)
    else
        frame.Body:SetPoint("TOPLEFT", frame, "TOPLEFT", portraitSize - overlapBehindPortrait + 4, -11)
    end
    frame.Body:SetSize(wrapperWidth, wrapperHeight)

    local cornerStyle = NormalizeCornerStyle(db.cornerStyle)
    local bodyMask = GetCornerMask("Body", frame.isMirrored, cornerStyle)
    SetMaskPath(frame.BodyOuterMask, bodyMask)
    SetMaskPath(frame.BodyEdgeMask, bodyMask)
    SetMaskPath(frame.BodyInnerMask, bodyMask)
    if frame.BodyRelationTintMask then
        SetMaskPath(frame.BodyRelationTintMask, bodyMask)
    end
    if frame.BodyRelationBorderMask then
        SetMaskPath(frame.BodyRelationBorderMask, GetBodyReactionBorderMask(frame.isMirrored, cornerStyle))
    end

    if frame.LowHealthGlow then
        frame.LowHealthGlow:ClearAllPoints()
        frame.LowHealthGlow:SetPoint("TOPLEFT", frame.Body, "TOPLEFT", -4, 4)
        frame.LowHealthGlow:SetPoint("BOTTOMRIGHT", frame.Body, "BOTTOMRIGHT", 4, -4)
        SetMaskPath(frame.LowHealthGlow.Mask, bodyMask)
    end

    local wrapperOpacity = math.max(0, math.min(100, tonumber(db.wrapperOpacity) or 42)) / 100
    frame.BodyOuter:SetAlpha(wrapperOpacity)
    frame.BodyEdge:SetAlpha(math.min(1, wrapperOpacity * 1.40))
    frame.BodyInner:SetAlpha(wrapperOpacity * 0.52)

    frame.BodyShadow:ClearAllPoints()
    frame.BodyShadow:SetPoint("TOPLEFT", frame.Body, "TOPLEFT", 2, -2)
    frame.BodyShadow:SetPoint("BOTTOMRIGHT", frame.Body, "BOTTOMRIGHT", 2, -2)
    frame.BodyShadow:SetAlpha(0)

    -- Let the bars tuck one extra pixel underneath the portrait-facing edge.
    -- This removes the tiny hairline that can otherwise appear between the
    -- portrait viewport and the header/health/power stack at some UI scales.
    local barsLeftInset = frame.isMirrored and 0 or math.max(1, overlapBehindPortrait + outerPadNear - 3)
    local barsRightInset = frame.isMirrored and math.max(1, overlapBehindPortrait + outerPadNear - 3) or 0

    frame.HeaderBorder:SetAlpha(0)
    frame.HeaderFill:SetAlpha(0)
    frame.HeaderBorder:Hide()
    frame.HeaderFill:Hide()
    if frame.HeaderReactionFill then
        frame.HeaderReactionFill:SetAlpha(0)
        frame.HeaderReactionFill:Hide()
    end

    frame.Header:ClearAllPoints()
    frame.Header:SetPoint("TOPLEFT", frame.Body, "TOPLEFT", barsLeftInset, -topPad)
    frame.Header:SetPoint("TOPRIGHT", frame.Body, "TOPRIGHT", -barsRightInset, -topPad)
    frame.Header:SetHeight(headerHeight)
    frame.HeaderBorder:Hide()
    frame.HeaderFill:Hide()

    frame.Health:ClearAllPoints()
    frame.Health:SetPoint("TOPLEFT", frame.Body, "TOPLEFT", barsLeftInset, -(topPad + headerHeight + headerGap))
    frame.Health:SetPoint("TOPRIGHT", frame.Body, "TOPRIGHT", -barsRightInset, -(topPad + headerHeight + headerGap))
    frame.Health:SetHeight(healthHeight)

    frame.Power:ClearAllPoints()
    frame.Power:SetPoint("TOPLEFT", frame.Health, "BOTTOMLEFT", 0, healthPowerOverlap)
    frame.Power:SetPoint("TOPRIGHT", frame.Health, "BOTTOMRIGHT", 0, healthPowerOverlap)
    frame.Power:SetHeight(powerHeight)

    -- Player/Pet round away from the portrait on the right; mirrored Target
    -- rounds away from its portrait on the left. The portrait-facing edge stays
    -- square and lines up with the separator.
    local healthMask = GetCornerMask("Health", frame.isMirrored, cornerStyle)
    local powerMask = GetCornerMask("Power", frame.isMirrored, cornerStyle)
    local widgets = {
        { widget = frame.Health, mask = healthMask },
        { widget = frame.Power, mask = powerMask },
    }

    for _, entry in ipairs(widgets) do
        local widget = entry.widget
        local maskPath = entry.mask

        SetMaskPath(widget.OuterMask, maskPath)
        SetMaskPath(widget.EdgeMask, maskPath)
        SetMaskPath(widget.BackgroundMask, maskPath)
        SetMaskPath(widget.FillMask, maskPath)
        SetMaskPath(widget.SideGlossMask, maskPath)

        -- Target fills from the fixed rounded outer-left edge, so it keeps the
        -- mask. Player/Pet only get the shape mask when the bar is actually full.
        widget.AlwaysMaskFill = frame.isMirrored
        self:UpdateBarFillMask(widget, widget.displayValue, widget.maximum)

        widget.SideGloss:ClearAllPoints()
        if frame.isMirrored then
            widget.SideGloss:SetPoint("TOPLEFT", widget.Bar, "TOPLEFT", 1, 0)
            widget.SideGloss:SetPoint("BOTTOMLEFT", widget.Bar, "BOTTOMLEFT", 1, 0)
        else
            widget.SideGloss:SetPoint("TOPRIGHT", widget.Bar, "TOPRIGHT", -1, 0)
            widget.SideGloss:SetPoint("BOTTOMRIGHT", widget.Bar, "BOTTOMRIGHT", -1, 0)
        end
    end

    frame.NameText:SetFont(FONT_NORMAL, db.nameFontSize, "OUTLINE")
    UpdateUnitNameBounds(frame)
    frame.Health.LeftText:SetFont(FONT_NORMAL, db.barFontSize, "OUTLINE")
    frame.Health.RightText:SetFont(FONT_NORMAL, db.barFontSize, "OUTLINE")
    frame.Power.LeftText:SetFont(FONT_NORMAL, math.max(11, db.barFontSize - 1), "OUTLINE")
    frame.Power.RightText:SetFont(FONT_NORMAL, math.max(11, db.barFontSize - 1), "OUTLINE")

    local inset = 10
    frame.Health.LeftText:ClearAllPoints()
    frame.Health.RightText:ClearAllPoints()
    frame.Power.LeftText:ClearAllPoints()
    frame.Power.RightText:ClearAllPoints()
    frame.HeaderLevel:ClearAllPoints()

    frame.Health.LeftText:SetPoint("LEFT", frame.Health.Bar, "LEFT", inset, 0)
    frame.Health.RightText:SetPoint("RIGHT", frame.Health.Bar, "RIGHT", -inset, 0)
    frame.Power.LeftText:SetPoint("LEFT", frame.Power.Bar, "LEFT", inset, 0)
    frame.Power.RightText:SetPoint("RIGHT", frame.Power.Bar, "RIGHT", -inset, 0)
    frame.HeaderLevel:SetPoint(frame.isMirrored and "LEFT" or "RIGHT", frame.Header, frame.isMirrored and "LEFT" or "RIGHT", frame.isMirrored and 10 or -10, 0)
    if frame.RaidGroupText then
        frame.RaidGroupText:ClearAllPoints()
        if frame.isMirrored then
            frame.RaidGroupText:SetPoint("RIGHT", frame.Header, "RIGHT", -10, 0)
        else
            frame.RaidGroupText:SetPoint("LEFT", frame.Header, "LEFT", 10, 0)
        end
    end

    local portraitFrame = frame.PortraitFrame
    portraitFrame:ClearAllPoints()
    portraitFrame:SetSize(portraitSize + 8, portraitSize + 8)
    if frame.isMirrored then
        portraitFrame:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    else
        portraitFrame:SetPoint("LEFT", frame, "LEFT", 0, 0)
    end

    local portraitMask = frame.isMirrored and PORTRAIT_RIGHT_MASK or PORTRAIT_LEFT_MASK
    for _, mask in ipairs(portraitFrame.ShapeMasks) do
        SetMaskPath(mask, portraitMask)
    end

    portraitFrame.CombatGlow:ClearAllPoints()
    portraitFrame.CombatGlow:SetSize(portraitSize + 12, portraitSize + 12)
    portraitFrame.CombatGlow:SetPoint("CENTER", frame.isMirrored and -1 or 1, 0)

    portraitFrame.Shadow:ClearAllPoints()
    portraitFrame.Shadow:SetSize(portraitSize + 2, portraitSize + 2)
    portraitFrame.Shadow:SetPoint("CENTER", 0, 0)

    portraitFrame.Outer:ClearAllPoints()
    portraitFrame.Outer:SetSize(portraitSize + 4, portraitSize + 4)
    portraitFrame.Outer:SetPoint("CENTER")

    portraitFrame.Accent:ClearAllPoints()
    portraitFrame.Accent:SetSize(portraitSize, portraitSize)
    portraitFrame.Accent:SetPoint("CENTER")

    portraitFrame.Inner:ClearAllPoints()
    local ringInset = PORTRAIT_RING_ACCENT_THICKNESS * 2
    portraitFrame.Inner:SetSize(portraitSize - ringInset, portraitSize - ringInset)
    portraitFrame.Inner:SetPoint("CENTER")
    ApplyPortraitRingStyle(portraitFrame)

    portraitFrame.Portrait:ClearAllPoints()
    portraitFrame.Portrait:SetSize(portraitSize - 8, portraitSize - 8)
    portraitFrame.Portrait:SetPoint("CENTER")

    if portraitFrame.AnimatedModel then
        portraitFrame.AnimatedModel:ClearAllPoints()

        -- Keep the PlayerModel viewport aligned to the same inner square used
        -- by the static portrait. The previous +4 sizing deliberately allowed
        -- model pixels to overlap the portrait ring; this version prioritizes
        -- predictable placement instead. The values above are easy to tune.
        local modelWidth = math.max(1, math.floor((portraitSize - ANIMATED_PORTRAIT_TUNING.widthInset) + 0.5))
        local modelHeight = math.max(1, math.floor((portraitSize - ANIMATED_PORTRAIT_TUNING.heightInset) + 0.5))
        local modelXOffset = tonumber(ANIMATED_PORTRAIT_TUNING.xOffset) or 0
        local modelYOffset = tonumber(ANIMATED_PORTRAIT_TUNING.yOffset) or 0
        portraitFrame.AnimatedModel:SetSize(modelWidth, modelHeight)
        portraitFrame.AnimatedModel:SetPoint("CENTER", portraitFrame, "CENTER", modelXOffset, modelYOffset)

        -- Clear the experimental viewport cropping from the previous build.
        -- We are no longer trying to fake rounded clipping on PlayerModel.
        if portraitFrame.AnimatedModel.SetViewInsets then
            pcall(portraitFrame.AnimatedModel.SetViewInsets, portraitFrame.AnimatedModel, 0, 0, 0, 0)
        end

        portraitFrame.ModelOverlay:ClearAllPoints()
        portraitFrame.ModelOverlay:SetAllPoints(portraitFrame.AnimatedModel)

        portraitFrame.ModelGlass:ClearAllPoints()
        portraitFrame.ModelGlass:SetAllPoints(portraitFrame.ModelOverlay)

        portraitFrame.ModelSeparator:ClearAllPoints()
        portraitFrame.ModelSeparator:SetWidth(1)
        portraitFrame.ModelSeparator:SetPoint("TOP", portraitFrame.ModelOverlay, "TOP", 0, 0)
        portraitFrame.ModelSeparator:SetPoint("BOTTOM", portraitFrame.ModelOverlay, "BOTTOM", 0, 0)
        if frame.isMirrored then
            portraitFrame.ModelSeparator:SetPoint("LEFT", portraitFrame.ModelOverlay, "LEFT", 0, 0)
        else
            portraitFrame.ModelSeparator:SetPoint("RIGHT", portraitFrame.ModelOverlay, "RIGHT", 0, 0)
        end
        -- Keep the old helper hidden; the bars already overlap the portrait
        -- junction by one pixel to avoid the separator hairline.
        portraitFrame.ModelSeparator:Hide()
    end

    portraitFrame.Glass:ClearAllPoints()
    portraitFrame.Glass:SetSize(portraitSize - 8, portraitSize - 8)
    portraitFrame.Glass:SetPoint("CENTER")

    portraitFrame.Separator:ClearAllPoints()
    portraitFrame.Separator:SetWidth(1)
    portraitFrame.Separator:SetPoint("TOP", portraitFrame, "TOP", 0, -4)
    portraitFrame.Separator:SetPoint("BOTTOM", portraitFrame, "BOTTOM", 0, 4)
    if frame.isMirrored then
        portraitFrame.Separator:SetPoint("LEFT", portraitFrame, "LEFT", 2, 0)
    else
        portraitFrame.Separator:SetPoint("RIGHT", portraitFrame, "RIGHT", -2, 0)
    end

    -- Modern compact level pill, positioned on the rounded outside corner so
    -- the square body-facing bottom corner stays clean.
    local badge = frame.LevelBadge
    badge:ClearAllPoints()
    badge:SetSize(35, 22)
    if frame.isMirrored then
        badge:SetPoint("BOTTOMRIGHT", portraitFrame, "BOTTOMRIGHT", -5, 2)
    else
        badge:SetPoint("BOTTOMLEFT", portraitFrame, "BOTTOMLEFT", 5, 2)
    end
    badge:SetShown(db.showLevelBadge)

    if badge.SoftShadow then
        badge.SoftShadow:ClearAllPoints()
        badge.SoftShadow:SetPoint("TOPLEFT", badge, "TOPLEFT", -3, 3)
        badge.SoftShadow:SetPoint("BOTTOMRIGHT", badge, "BOTTOMRIGHT", 3, -3)
    end

    badge.Shadow:ClearAllPoints()
    badge.Shadow:SetPoint("TOPLEFT", badge, "TOPLEFT", -2, 2)
    badge.Shadow:SetPoint("BOTTOMRIGHT", badge, "BOTTOMRIGHT", 2, -2)
    ApplyLevelBadgeFrameStyle(badge)

    badge.Outer:ClearAllPoints()
    badge.Outer:SetAllPoints(badge)

    badge.Inner:ClearAllPoints()
    badge.Inner:SetPoint("TOPLEFT", 2, -2)
    badge.Inner:SetPoint("BOTTOMRIGHT", -2, 2)

    if badge.Accent then
        badge.Accent:ClearAllPoints()
        badge.Accent:SetPoint("TOPLEFT", badge, "TOPLEFT", 2, -2)
        badge.Accent:SetPoint("BOTTOMRIGHT", badge, "BOTTOMRIGHT", -2, 2)
    end

    badge.Text:SetFont(FONT_NORMAL, 12, "OUTLINE")

    if frame.LeaderIcon then
        frame.LeaderIcon:ClearAllPoints()
        frame.LeaderIcon:SetSize(21, 21)
        -- Sit directly over the top rim of the portrait, matching Blizzard's
        -- familiar party/raid leader crown while keeping it clear of the name.
        frame.LeaderIcon:SetPoint("CENTER", portraitFrame, "TOP", 0, 1)
    end

    if frame.RaidTargetIcon then
        frame.RaidTargetIcon:ClearAllPoints()
        frame.RaidTargetIcon:SetSize(30, 30)
        -- Put raid markers on the upper body-facing corner for every supported
        -- unit frame. This keeps Player/ToT/Party clear of the outer PvP/level
        -- decorations while mirroring naturally on Target.
        if frame.isMirrored then
            frame.RaidTargetIcon:SetPoint("CENTER", portraitFrame, "TOPLEFT", 8, -8)
        else
            frame.RaidTargetIcon:SetPoint("CENTER", portraitFrame, "TOPRIGHT", -8, -8)
        end
    end

    if frame.CombatBadge then
        local combatBadge = frame.CombatBadge
        combatBadge:ClearAllPoints()
        combatBadge:SetSize(26, 26)
        if frame.isMirrored then
            combatBadge:SetPoint("BOTTOMLEFT", portraitFrame, "BOTTOMLEFT", 5, 3)
        else
            combatBadge:SetPoint("BOTTOMRIGHT", portraitFrame, "BOTTOMRIGHT", -5, 3)
        end

        combatBadge.Pulse:ClearAllPoints()
        combatBadge.Pulse:SetPoint("TOPLEFT", combatBadge, "TOPLEFT", -2, 2)
        combatBadge.Pulse:SetPoint("BOTTOMRIGHT", combatBadge, "BOTTOMRIGHT", 2, -2)

        combatBadge.Outer:ClearAllPoints()
        combatBadge.Outer:SetAllPoints(combatBadge)

        combatBadge.Inner:ClearAllPoints()
        combatBadge.Inner:SetPoint("TOPLEFT", 2, -2)
        combatBadge.Inner:SetPoint("BOTTOMRIGHT", -2, 2)

        combatBadge.Ring:ClearAllPoints()
        combatBadge.Ring:SetPoint("TOPLEFT", combatBadge, "TOPLEFT", 3, -3)
        combatBadge.Ring:SetPoint("BOTTOMRIGHT", combatBadge, "BOTTOMRIGHT", -3, 3)

        combatBadge.Icon:ClearAllPoints()
        combatBadge.Icon:SetPoint("TOPLEFT", combatBadge, "TOPLEFT", 4, -4)
        combatBadge.Icon:SetPoint("BOTTOMRIGHT", combatBadge, "BOTTOMRIGHT", -4, 4)
    end

    if frame.CombatFlair then
        local combatFlair = frame.CombatFlair
        combatFlair:ClearAllPoints()
        combatFlair:SetAllPoints(portraitFrame)

        combatFlair.OuterGlow:ClearAllPoints()
        combatFlair.OuterGlow:SetSize(portraitSize + 20, portraitSize + 20)
        combatFlair.OuterGlow:SetPoint("CENTER", portraitFrame, "CENTER", 0, 0)

        combatFlair.InnerGlow:ClearAllPoints()
        combatFlair.InnerGlow:SetSize(portraitSize + 11, portraitSize + 11)
        combatFlair.InnerGlow:SetPoint("CENTER", portraitFrame, "CENTER", 0, 0)

        local combatMask = frame.isMirrored and PORTRAIT_RIGHT_MASK or PORTRAIT_LEFT_MASK
        SetMaskPath(combatFlair.OuterGlowMask, combatMask)
        SetMaskPath(combatFlair.InnerGlowMask, combatMask)

        for i, info in ipairs(COMBAT_REST_SPARK_LAYOUT) do
            local sparkData = combatFlair.Sparks[i]
            if sparkData then
                local spark = sparkData.texture
                spark:ClearAllPoints()
                spark:SetSize(info.size, info.size)
                spark:SetPoint(info.point, portraitFrame, info.relPoint, info.x, info.y)
            end
        end
    end

    if frame.PlayerCornerOrnament then
        local ornament = frame.PlayerCornerOrnament
        local style = (SUF.db and SUF.db.playerCornerOrnamentStyle) or "NONE"
        if style == "ORNATE" then
            style = "SIMPLE"
        end
        ornament:SetShown(style == "SIMPLE")
        if ornament.Simple then ornament.Simple:SetShown(style == "SIMPLE") end
        ApplyPlayerCornerOrnamentStyle(portraitFrame)
    end

    if frame.RestingIndicator then
        local rest = frame.RestingIndicator
        rest:ClearAllPoints()
        rest:SetAllPoints(portraitFrame)

        rest.OuterGlow:ClearAllPoints()
        rest.OuterGlow:SetSize(portraitSize + 20, portraitSize + 20)
        rest.OuterGlow:SetPoint("CENTER", portraitFrame, "CENTER", 0, 0)

        rest.InnerGlow:ClearAllPoints()
        rest.InnerGlow:SetSize(portraitSize + 11, portraitSize + 11)
        rest.InnerGlow:SetPoint("CENTER", portraitFrame, "CENTER", 0, 0)

        rest.Icon:ClearAllPoints()
        rest.Icon:SetSize(28, 28)
        -- With the PvP countdown no longer occupying the name bar, move the
        -- resting state icon to the far-right side of the header instead of
        -- covering the lower portrait corner.
        rest.Icon:SetPoint("RIGHT", frame.Header, "RIGHT", -5, 0)

        if rest.Zs then
            local zAnchors = {
                { x = -13, y = -8 },
                { x = -4,  y = -1 },
                { x = -1,  y = 8 },
            }
            for i, z in ipairs(rest.Zs) do
                z:ClearAllPoints()
                local info = zAnchors[i] or zAnchors[#zAnchors]
                z:SetPoint("CENTER", portraitFrame, "TOPRIGHT", info.x, info.y)
            end
        end

        for i, info in ipairs(COMBAT_REST_SPARK_LAYOUT) do
            local sparkData = rest.Sparks[i]
            if sparkData then
                local spark = sparkData.texture
                spark:ClearAllPoints()
                spark:SetSize(info.size, info.size)
                spark:SetPoint(info.point, portraitFrame, info.relPoint, info.x, info.y)
            end
        end
    end

    if frame.CombatText then
        frame.CombatText:SetText("")
        frame.CombatText:Hide()
    end

    if frame.ClassificationDragon then
        frame.ClassificationDragon:ClearAllPoints()
        -- User-tuned classification ring placement. Keep these values unless
        -- deliberately changing the dragon fit in a future iteration.
        frame.ClassificationDragon:SetPoint("CENTER", portraitFrame, "CENTER", 20, 0)
        frame.ClassificationDragon:SetSize(portraitSize + 63, portraitSize + 63)
    end

    if frame.PVPStatus then
        frame.PVPStatus:ClearAllPoints()
        frame.PVPStatus.Icon:ClearAllPoints()
        frame.PVPStatus.TimerText:ClearAllPoints()

        if frame.unit and frame.unit:match("^party%d$") then
            local partyPvp = PARTY_PVP_ICON_TUNING
            frame.PVPStatus:SetPoint("TOPLEFT", portraitFrame, "TOPLEFT", partyPvp.x, partyPvp.y)
            frame.PVPStatus:SetSize(partyPvp.holderSize, partyPvp.holderSize)
            frame.PVPStatus.Icon:SetSize(partyPvp.iconSize, partyPvp.iconSize)
            frame.PVPStatus.Icon:SetPoint("TOPLEFT", frame.PVPStatus, "TOPLEFT", 0, 0)
            frame.PVPStatus.TimerText:SetText("")
            frame.PVPStatus.TimerText:Hide()
        else
            local pvpTuning = CUSTOM_PVP_ICON_TUNING or {
                holderSize = 52,
                iconSize = 48,
                playerX = -15,
                playerY = 0,
                targetX = 15,
                targetY = 0,
                timerX = 2,
                timerY = 0,
            }

            -- Custom PvP crests look best slightly smaller and tucked onto the
            -- portrait ring corner instead of covering the portrait artwork.
            if frame.isMirrored then
                frame.PVPStatus:SetPoint("TOPRIGHT", portraitFrame, "TOPRIGHT", pvpTuning.targetX, pvpTuning.targetY)
            else
                frame.PVPStatus:SetPoint("TOPLEFT", portraitFrame, "TOPLEFT", pvpTuning.playerX, pvpTuning.playerY)
            end

            frame.PVPStatus:SetSize(pvpTuning.holderSize, pvpTuning.holderSize)
            frame.PVPStatus.Icon:SetSize(pvpTuning.iconSize, pvpTuning.iconSize)
            if frame.isMirrored then
                frame.PVPStatus.Icon:SetPoint("TOPRIGHT", frame.PVPStatus, "TOPRIGHT", 0, 0)
            else
                frame.PVPStatus.Icon:SetPoint("TOPLEFT", frame.PVPStatus, "TOPLEFT", 0, 0)
            end

            if frame.unit == "player" then
                -- Put the PvP clear countdown directly over the faction crest.
                frame.PVPStatus.TimerText:SetPoint("CENTER", frame.PVPStatus.Icon, "CENTER", pvpTuning.timerX or 0, pvpTuning.timerY or 0)
                frame.PVPStatus.TimerText:SetJustifyH("CENTER")
                frame.PVPStatus.TimerText:SetJustifyV("MIDDLE")
            else
                frame.PVPStatus.TimerText:SetPoint("TOP", frame.PVPStatus.Icon, "BOTTOM", 0, 3)
                frame.PVPStatus.TimerText:SetJustifyH("CENTER")
            end
        end
    end

    if frame.unit == "target" then
        self:ApplyTargetComboPointsLayout(frame)
        self:ApplyTargetExtrasLayout(frame)
    elseif frame.unit and frame.unit:match("^party%d$") then
        self:ApplyPartyTargetLayout(frame)
        self:ApplyPartyAuraLayout(frame)
    end
end

local function HasExactPlayerHealth(unit)
    if not unit or not UnitIsPlayer or not UnitIsPlayer(unit) then
        return true
    end

    -- Classic/TBC Anniversary exposes absolute HP for yourself and grouped
    -- players, but normalizes non-group player targets to a 0-100 health scale.
    if UnitIsUnit and UnitIsUnit(unit, "player") then
        return true
    end

    if UnitInParty and UnitInParty(unit) then
        return true
    end

    if UnitInRaid and UnitInRaid(unit) then
        return true
    end

    return false
end

local function SetHealthTextLayout(frame, centered)
    if not frame or not frame.Health then
        return
    end

    local inset = 10
    frame.Health.LeftText:ClearAllPoints()
    frame.Health.RightText:ClearAllPoints()

    if centered then
        frame.Health.LeftText:SetPoint("CENTER", frame.Health.Bar, "CENTER", 0, 0)
        frame.Health.LeftText:SetJustifyH("CENTER")
        frame.Health.RightText:SetPoint("RIGHT", frame.Health.Bar, "RIGHT", -inset, 0)
    else
        frame.Health.LeftText:SetPoint("LEFT", frame.Health.Bar, "LEFT", inset, 0)
        frame.Health.LeftText:SetJustifyH("LEFT")
        frame.Health.RightText:SetPoint("RIGHT", frame.Health.Bar, "RIGHT", -inset, 0)
    end
end

local function GetTargetHeaderSelectionColor(unit, usePreview)
    -- The stock target frame uses the unit's selection/reaction color for the
    -- name-background panel. On BCC Anniversary UnitSelectionColor is the most
    -- direct match: player-controlled friendly/non-attackable units are blue,
    -- friendly NPCs are green, neutral units yellow and hostile units red.
    if usePreview then
        return 0.00, 0.00, 1.00
    end

    if not unit or not UnitExists(unit) then
        return 0.00, 0.00, 1.00
    end

    if UnitIsTapDenied and UnitPlayerControlled and UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
        return 0.50, 0.50, 0.50
    end

    if UnitSelectionColor then
        local r, g, b = UnitSelectionColor(unit)
        if r ~= nil and g ~= nil and b ~= nil then
            return r, g, b
        end
    end

    -- Defensive fallback mirroring the classic TargetFrame faction logic.
    if UnitPlayerControlled and UnitPlayerControlled(unit) then
        local theyCanAttackUs = UnitCanAttack and UnitCanAttack(unit, "player") or false
        local weCanAttackThem = UnitCanAttack and UnitCanAttack("player", unit) or false

        if theyCanAttackUs then
            if not weCanAttackThem then
                return 0.00, 0.00, 1.00
            end
            return 1.00, 0.00, 0.00
        elseif weCanAttackThem then
            return 1.00, 1.00, 0.00
        elseif UnitIsPVP and UnitIsPVP(unit) then
            return 0.00, 1.00, 0.00
        end

        return 0.00, 0.00, 1.00
    end

    local reaction = UnitReaction and UnitReaction(unit, "player") or nil
    if reaction then
        if reaction >= 5 then
            return 0.00, 1.00, 0.00
        elseif reaction == 4 then
            return 1.00, 1.00, 0.00
        end
        return 1.00, 0.00, 0.00
    end

    return 0.00, 0.00, 1.00
end

local function ApplyTargetHeaderReactionStyle(frame, unit, usePreview)
    local oldHeaderFill = frame and frame.HeaderReactionFill
    if oldHeaderFill then
        oldHeaderFill:Hide()
        oldHeaderFill:SetAlpha(0)
    end

    if not frame or not frame.BodyOuter or not frame.BodyEdge or not frame.BodyInner then
        return
    end

    -- Restore the normal wrapper layers. Relation coloring is now rendered on
    -- dedicated overlays and never modifies BodyOuter / BodyEdge / BodyInner.
    SetSolid(frame.BodyOuter, BODY_WRAPPER_BASE_OUTER)
    SetSolid(frame.BodyEdge, BODY_WRAPPER_BASE_EDGE)
    SetSolid(frame.BodyInner, BODY_WRAPPER_BASE_INNER)

    local tintLayer = frame.BodyRelationTint
    local borderLayer = frame.BodyRelationBorder
    if tintLayer then
        tintLayer:SetAlpha(0)
        tintLayer:Hide()
    end
    if borderLayer then
        borderLayer:SetAlpha(0)
        borderLayer:Hide()
    end

    if unit ~= "target" and unit ~= "targettarget" and unit ~= "focus" then
        -- Reuse the same true perimeter ring for Player, Pet and Party, but use
        -- a neutral dark-steel color rather than a relation color.
        if unit == "player" or unit == "pet" or (type(unit) == "string" and unit:match("^party%d$")) then
            local standardBorderOpacity = tonumber(SUF.db and SUF.db.standardFrameBorderOpacity) or 70
            standardBorderOpacity = math.max(0, math.min(100, standardBorderOpacity)) / 100
            if borderLayer and standardBorderOpacity > 0 then
                SetSolid(borderLayer, { 0.018, 0.026, 0.038, 1.00 })
                borderLayer:SetAlpha(standardBorderOpacity)
                borderLayer:Show()
            end
        end
        return
    end

    local tintOpacity = tonumber(SUF.db and SUF.db.targetHeaderReactionOpacity) or 45
    tintOpacity = math.max(0, math.min(100, tintOpacity)) / 100

    local borderOpacity = tonumber(SUF.db and SUF.db.targetRelationBorderOpacity) or 70
    borderOpacity = math.max(0, math.min(100, borderOpacity)) / 100

    if tintOpacity <= 0 and borderOpacity <= 0 then
        return
    end

    local r, g, b = GetTargetHeaderSelectionColor(unit, usePreview)

    if tintLayer and tintOpacity > 0 then
        -- Dark, restrained relation color over the complete wrapper. Its alpha
        -- is controlled ONLY by Target relation tint opacity.
        local tintColor = {
            0.018 + (r * 0.30),
            0.024 + (g * 0.30),
            0.036 + (b * 0.36),
            1.00,
        }
        SetSolid(tintLayer, tintColor)
        tintLayer:SetAlpha(tintOpacity)
        tintLayer:Show()
    end

    if borderLayer and borderOpacity > 0 then
        -- A separate masked ring supplies the darker 1-2px containment edge.
        -- Its alpha is controlled ONLY by Target relation border opacity, so
        -- changing this slider can no longer affect the wrapper background.
        local borderColor = {
            0.004 + (r * 0.085),
            0.006 + (g * 0.085),
            0.010 + (b * 0.105),
            1.00,
        }
        SetSolid(borderLayer, borderColor)
        borderLayer:SetAlpha(borderOpacity)
        borderLayer:Show()
    end
end

local function ApplyUnitNameColor(frame, unit, usePreview)
    if not frame or not frame.NameText then
        return
    end

    if not usePreview and IsUnitOffline(unit) then
        frame.NameText:SetTextColor(0.55, 0.55, 0.55, 1.00)
        return
    end

    -- Keep names gold across the custom frames. For Target and Target of Target
    -- the at-a-glance faction/reaction information now lives in the header
    -- background, matching Blizzard's classic target-frame visual language.
    frame.NameText:SetTextColor(unpack(COLORS.gold))
end

local PREVIEW = {
    target = { name = "Target", health = 68, maxHealth = 100, power = 42, maxPower = 100, powerToken = "MANA" },
    targettarget = { name = "Target's Target", health = 91, maxHealth = 100, power = 64, maxPower = 100, powerToken = "MANA" },
    focus = { name = "Focus", health = 74, maxHealth = 100, power = 58, maxPower = 100, powerToken = "MANA" },
    pet = { name = "Pet", health = 83, maxHealth = 100, power = 76, maxPower = 100, powerToken = "MANA" },
    party1 = { name = "Party Member 1", health = 92, maxHealth = 100, power = 81, maxPower = 100, powerToken = "MANA" },
    party2 = { name = "Party Member 2", health = 73, maxHealth = 100, power = 55, maxPower = 100, powerToken = "MANA" },
    party3 = { name = "Party Member 3", health = 46, maxHealth = 100, power = 34, maxPower = 100, powerToken = "MANA" },
    party4 = { name = "Party Member 4", health = 100, maxHealth = 100, power = 90, maxPower = 100, powerToken = "MANA" },
}

function SUF:UpdateLowHealthIndicator(currentHealth, maxHealth)
    local frame = self:GetUnitFrame("player")
    local db = self.db
    local holder = frame and frame.LowHealthGlow
    if not holder or not db then return end

    currentHealth = tonumber(currentHealth) or ((UnitHealth and UnitHealth("player")) or 0)
    maxHealth = tonumber(maxHealth) or ((UnitHealthMax and UnitHealthMax("player")) or 0)

    local threshold = math.max(1, math.min(100, tonumber(db.lowHealthThreshold) or 30))
    local percent = maxHealth > 0 and ((currentHealth / maxHealth) * 100) or 100
    local alive = currentHealth > 0 and not (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player"))
    local enabled = db.showLowHealthPulse and alive and percent <= threshold

    holder:SetScript("OnUpdate", nil)
    holder.pulseElapsed = 0

    if not enabled then
        holder.Glow:SetAlpha(0)
        holder:Hide()
        return
    end

    holder:Show()
    holder.Glow:SetAlpha(0.18)
    holder:SetScript("OnUpdate", function(self, elapsed)
        self.pulseElapsed = (self.pulseElapsed or 0) + elapsed
        local pulse = 0.15 + (math.sin(self.pulseElapsed * 4.6) * 0.08)
        self.Glow:SetAlpha(math.max(0.06, math.min(0.28, pulse)))
    end)
end

local function SetStaticPortraitState(frame, unit, usePreview, isOffline)
    local portraitFrame = frame and frame.PortraitFrame
    local texture = portraitFrame and portraitFrame.Portrait
    if not texture then
        return
    end

    if usePreview then
        texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    else
        SetPortraitTexture(texture, unit)
    end

    if texture.SetDesaturated then
        texture:SetDesaturated(isOffline and true or false)
    end
    texture:SetAlpha(isOffline and 0.52 or 1.00)
end

function SUF:ApplyAnimatedPortraitMotion(model)
    if not model then
        return
    end

    local allowMotion = self.db and self.db.animatedPortraitIdleMotion

    -- Animation 0 is the normal stand/idle sequence on character models.
    -- FreezeAnimation is available in BCC Anniversary and gives us a stable
    -- neutral 3D portrait without the breathing/fidget motion. Keep defensive
    -- fallbacks for creature models or clients where a method is unavailable.
    if allowMotion then
        if model.SetPaused then
            pcall(model.SetPaused, model, false)
        end
        if model.HasAnimation and model.SetAnimation then
            local ok, hasIdle = pcall(model.HasAnimation, model, 0)
            if ok and hasIdle then
                pcall(model.SetAnimation, model, 0)
            end
        end
        return
    end

    if model.FreezeAnimation then
        local ok = pcall(model.FreezeAnimation, model, 0, 0, 0)
        if ok then
            return
        end
    end

    if model.HasAnimation and model.SetAnimation then
        local ok, hasIdle = pcall(model.HasAnimation, model, 0)
        if ok and hasIdle then
            pcall(model.SetAnimation, model, 0)
        end
    end
    if model.SetPaused then
        pcall(model.SetPaused, model, true)
    end
end

local function StopAnimatedPortrait(frame)
    local portraitFrame = frame and frame.PortraitFrame
    if not portraitFrame then
        return
    end

    local model = portraitFrame.AnimatedModel
    if model then
        model:Hide()
        model.modelReady = false
    end
    if portraitFrame.ModelGlass then portraitFrame.ModelGlass:Hide() end
    if portraitFrame.ModelSeparator then portraitFrame.ModelSeparator:Hide() end
    if portraitFrame.Portrait then
        portraitFrame.Portrait:Show()
    end
end

function SUF:UpdateAnimatedPortrait(frame, unit, usePreview, isOffline, forceModel)
    local portraitFrame = frame and frame.PortraitFrame
    local model = portraitFrame and portraitFrame.AnimatedModel
    if not portraitFrame or not model then
        return
    end

    SetStaticPortraitState(frame, unit, usePreview, isOffline)

    if not self.db or not self.db.showAnimatedPortraits or usePreview or isOffline or not UnitExists(unit) then
        StopAnimatedPortrait(frame)
        return
    end

    -- UnitIsVisible is deliberately different from spell range. It describes
    -- whether the client currently knows the unit as locally visible. The
    -- PlayerModel load itself is a second gate; if SetUnit cannot resolve a
    -- model, the static portrait stays visible underneath.
    local visible = unit == "player" or not UnitIsVisible or UnitIsVisible(unit)
    model.lastVisible = visible and true or false
    if not visible then
        StopAnimatedPortrait(frame)
        return
    end

    local guid = UnitGUID and UnitGUID(unit) or unit
    local needsRequest = forceModel or model.requestedUnit ~= unit or model.requestedGUID ~= guid or not model.modelReady

    if not needsRequest then
        portraitFrame.Portrait:Hide()
        model:Show()
        portraitFrame.ModelGlass:Hide()
        portraitFrame.ModelSeparator:Hide()
        self:ApplyAnimatedPortraitMotion(model)
        return
    end

    model.requestedUnit = unit
    model.requestedGUID = guid
    model.modelReady = false
    portraitFrame.Portrait:Show()
    model:Hide()
    portraitFrame.ModelGlass:Hide()
    portraitFrame.ModelSeparator:Hide()

    if model.SetPaused then
        pcall(model.SetPaused, model, false)
    end
    if model.ClearModel then
        pcall(model.ClearModel, model)
    end
    if model.SetPortraitZoom then
        pcall(model.SetPortraitZoom, model, 1.0)
    end
    if model.SetCamDistanceScale then
        pcall(model.SetCamDistanceScale, model, 0.94)
    end

    local ok, success = pcall(model.SetUnit, model, unit)
    if not ok or success == false then
        StopAnimatedPortrait(frame)
        return
    end

    -- PlayerModel itself supports a transparent scene. Explicitly clear model
    -- fog where available so no client-side fog/scene wash can tint the square
    -- viewport around the character.
    if model.ClearFog then
        pcall(model.ClearFog, model)
    end

    -- Some Classic clients finish SetUnit synchronously. If the model file is
    -- already present, show it immediately instead of waiting for OnModelLoaded.
    if model.GetModelFileID then
        local fileOK, fileID = pcall(model.GetModelFileID, model)
        if fileOK and fileID and fileID ~= 0 then
            model.modelReady = true
            portraitFrame.Portrait:Hide()
            model:Show()
            portraitFrame.ModelGlass:Hide()
                portraitFrame.ModelSeparator:Hide()
            self:ApplyAnimatedPortraitMotion(model)
        end
    end
end

function SUF:UpdateUnitFrame(unit, force)
    local frame = self:GetUnitFrame(unit)
    local db = self.db
    if not frame or not db then
        return
    end

    local usePreview = db.previewMode and unit ~= "player" and not UnitExists(unit)
    local currentHealth, maxHealth, currentPower, maxPower, powerType, powerToken, name, level

    if usePreview then
        local sample = PREVIEW[unit]
        currentHealth = sample.health
        maxHealth = sample.maxHealth
        currentPower = sample.power
        maxPower = sample.maxPower
        powerToken = sample.powerToken
        name = sample.name
        level = unit == "target" and "63" or "63"
    else
        if unit ~= "player" and not UnitExists(unit) then
            return
        end

        currentHealth = UnitHealth(unit) or 0
        maxHealth = UnitHealthMax(unit) or 0
        powerType, powerToken = UnitPowerType(unit)
        currentPower = UnitPower(unit, powerType) or 0
        maxPower = UnitPowerMax(unit, powerType) or 0
        name = UnitName(unit) or ""
        level = FormatLevel(unit)
    end

    if maxHealth <= 0 then
        maxHealth = 1
    end

    local isOffline = (not usePreview) and IsUnitOffline(unit)
    -- Dead and ghost are deliberately separate states. UnitIsDeadOrGhost()
    -- collapses them together, but the stock Blizzard frames distinguish a
    -- released spirit from a corpse. Keep that distinction in our health text.
    local isGhost = (not usePreview) and UnitIsGhost and UnitIsGhost(unit) or false
    local isDead = false
    if not usePreview and not isGhost then
        if UnitIsDead then
            isDead = UnitIsDead(unit) or false
        elseif UnitIsDeadOrGhost then
            isDead = UnitIsDeadOrGhost(unit) or false
        end
    end

    local healthBarValue = (isOffline or isDead or isGhost) and 0 or currentHealth
    self:SetBarValue(frame.Health, healthBarValue, maxHealth, force or isOffline or isDead or isGhost)
    ApplyBarFillGradient(frame.Health, self:GetHealthBarColor(unit))

    if unit == "player" then
        self:UpdateLowHealthIndicator(currentHealth, maxHealth)
    end
    local exactHealthAvailable = usePreview or HasExactPlayerHealth(unit)
    local centerUnavailablePercent = (not exactHealthAvailable)
        and db.showHealthValue
        and db.showHealthPercent
        and db.centerUnavailableHealthPercent

    frame.Health.LeftText:SetTextColor(unpack(COLORS.text))
    frame.Health.RightText:SetTextColor(unpack(COLORS.text))

    if isOffline then
        SetHealthTextLayout(frame, true)
        frame.Health.LeftText:SetText("Offline")
        frame.Health.LeftText:SetTextColor(0.72, 0.72, 0.72, 1.00)
        frame.Health.RightText:SetText("")
    elseif isGhost then
        SetHealthTextLayout(frame, true)
        frame.Health.LeftText:SetText("Ghost")
        frame.Health.RightText:SetText("")
    elseif isDead then
        SetHealthTextLayout(frame, true)
        frame.Health.LeftText:SetText("Dead")
        frame.Health.RightText:SetText("")
    elseif centerUnavailablePercent then
        SetHealthTextLayout(frame, true)
        frame.Health.LeftText:SetText(Percent(currentHealth, maxHealth) .. "%")
        frame.Health.RightText:SetText("")
    else
        SetHealthTextLayout(frame, false)
        frame.Health.LeftText:SetText(db.showHealthPercent and (Percent(currentHealth, maxHealth) .. "%") or "")

        if db.showHealthValue then
            -- Classic/TBC only exposes normalized 0-100 HP for non-group
            -- player targets. If the centered fallback is disabled, retain a
            -- dash rather than pretending that normalized value is real HP.
            frame.Health.RightText:SetText(exactHealthAvailable and FormatValue(currentHealth) or "—")
        else
            frame.Health.RightText:SetText("")
        end
    end

    if isOffline then
        self:SetBarValue(frame.Power, 0, math.max(1, maxPower or 1), true)
        frame.Power.LeftText:SetText("")
        frame.Power.RightText:SetText("")
    elseif maxPower and maxPower > 0 then
        self:SetBarValue(frame.Power, currentPower, maxPower, force)
        frame.Power.LeftText:SetText(db.showPowerPercent and (Percent(currentPower, maxPower) .. "%") or "")
        frame.Power.RightText:SetText(db.showPowerValue and FormatValue(currentPower) or "")
    else
        self:SetBarValue(frame.Power, 0, 1, true)
        frame.Power.LeftText:SetText("")
        frame.Power.RightText:SetText("")
    end

    local powerColor = POWER_COLORS[powerToken]
    if not powerColor and PowerBarColor then
        local blizzardColor = PowerBarColor[powerToken] or (powerType and PowerBarColor[powerType])
        if blizzardColor then
            powerColor = { blizzardColor.r, blizzardColor.g, blizzardColor.b }
        end
    end
    powerColor = powerColor or POWER_COLORS.MANA
    ApplyBarFillGradient(frame.Power, powerColor)

    frame.NameText:SetText(name or "")
    ApplyUnitNameColor(frame, unit, usePreview)
    ApplyTargetHeaderReactionStyle(frame, unit, usePreview)
    frame.HeaderLevel:SetText("")
    if frame.RaidGroupText then
        local raidText = usePreview and "" or GetRaidGroupText(unit)
        frame.RaidGroupText:SetText(raidText)
        frame.RaidGroupText:SetShown(raidText ~= "")
    end
    UpdateUnitNameBounds(frame)
    if frame.LeaderIcon then
        frame.LeaderIcon:SetShown((not usePreview) and UnitLeadsPlayerGroup(unit))
    end
    if frame.RaidTargetIcon then
        local raidTargetIndex = (not usePreview and GetRaidTargetIndex and UnitExists(unit)) and GetRaidTargetIndex(unit) or nil
        if raidTargetIndex then
            SetRaidTargetTexture(frame.RaidTargetIcon.Icon, raidTargetIndex)
            frame.RaidTargetIcon:Show()
        else
            frame.RaidTargetIcon:Hide()
        end
    end
    local rawLevel = (not usePreview and unit and UnitExists(unit)) and UnitLevel(unit) or tonumber(level)
    local classification = (not usePreview and unit == "target" and UnitClassification) and UnitClassification(unit) or nil
    local showBossSkull = unit == "target" and (classification == "worldboss" or (rawLevel and rawLevel < 0))

    frame.LevelBadge:SetShown(db.showLevelBadge)
    if showBossSkull and frame.LevelBadge.Skull then
        frame.LevelBadge.Text:SetText("")
        frame.LevelBadge.Text:Hide()
        frame.LevelBadge.Skull:Show()
        frame.LevelBadge.Outer:SetAlpha(1)
        frame.LevelBadge.Inner:SetAlpha(1)
        ApplyLevelBadgeFrameStyle(frame.LevelBadge)
        ApplyLevelBadgeColor(frame, unit, rawLevel or -1)
    else
        frame.LevelBadge.Skull:Hide()
        frame.LevelBadge.Text:Show()
        frame.LevelBadge.Text:SetText(level or "")
        frame.LevelBadge.Outer:SetAlpha(1)
        frame.LevelBadge.Inner:SetAlpha(1)
        ApplyLevelBadgeFrameStyle(frame.LevelBadge)
        ApplyLevelBadgeColor(frame, unit, tonumber(level))
    end

    self:UpdateAnimatedPortrait(frame, unit, usePreview, isOffline, force)
end

function SUF:RefreshAllUnitFrames(force)
    self:UpdateUnitFrame("player", force)
    self:UpdateUnitFrame("target", force)
    self:UpdateUnitFrame("targettarget", force)
    self:UpdateUnitFrame("focus", force)
    self:UpdateUnitFrame("pet", force)
    self:UpdateUnitFrame("party1", force)
    self:UpdateUnitFrame("party2", force)
    self:UpdateUnitFrame("party3", force)
    self:UpdateUnitFrame("party4", force)
    self:RefreshAuraMasks()
    self:UpdateComboPoints()
    self:UpdateTargetAuras()
    self:UpdateAllPartyAuras()
    self:UpdateAllPartyTargets(force)
    self:UpdateTargetCastbar()
    self:UpdatePVPStatuses()
    self:UpdateTargetClassification()
end

function SUF:UpdateTargetClassification()
    local frame = self:GetUnitFrame("target")
    local dragon = frame and frame.ClassificationDragon
    if not dragon or not self.db then
        return
    end

    if not self.db.showTargetClassificationDragon or not UnitExists("target") or (UnitIsPlayer and UnitIsPlayer("target")) then
        dragon:Hide()
        return
    end

    local classification = UnitClassification and UnitClassification("target") or "normal"
    local texture = CLASSIFICATION_DRAGON_TEXTURES[classification]
    if texture then
        dragon:SetTexture(texture)
        dragon:Show()
    else
        dragon:Hide()
    end
end

function SUF:IsPetCombatActive()
    if not UnitExists or not UnitExists("pet") then
        return false, false
    end

    local targeted = false
    if UnitExists("targettarget") and UnitIsUnit then
        targeted = UnitIsUnit("targettarget", "pet") and true or false
    end

    local fighting = false
    if UnitAffectingCombat then
        fighting = UnitAffectingCombat("pet") and true or false
    end

    return fighting or targeted, targeted
end

function SUF:UpdatePetCombatIndicator(force)
    local frame = self:GetUnitFrame("pet")
    if not frame or not self.db or not frame.PortraitFrame then
        return
    end

    local portrait = frame.PortraitFrame
    local combatBadge = frame.CombatBadge
    local combatFlair = frame.CombatFlair
    local active, targeted = self:IsPetCombatActive()
    local enabled = self.db.showPetCombatIndicator and active

    if not force and frame.petCombatIndicatorActive == enabled and frame.petCombatTargeted == targeted then
        return
    end

    frame.petCombatIndicatorActive = enabled
    frame.petCombatTargeted = targeted
    portrait:SetScript("OnUpdate", nil)
    portrait.petCombatPulseElapsed = 0

    if not enabled then
        portrait.CombatGlow:SetAlpha(0)
        if combatFlair then
            combatFlair.OuterGlow:SetAlpha(0)
            combatFlair.InnerGlow:SetAlpha(0)
            for _, sparkData in ipairs(combatFlair.Sparks or {}) do
                sparkData.texture:SetAlpha(0)
            end
            combatFlair:Hide()
        end
        if combatBadge then
            combatBadge.Pulse:SetAlpha(0)
            combatBadge:Hide()
        end
        ApplyPortraitRingStyle(portrait)
        ApplyPlayerCornerOrnamentStyle(portrait)
        return
    end

    if portrait.Accent then
        portrait.Accent:SetColorTexture(0.62, 0.08, 0.06, 1.00)
    end

    portrait.CombatGlow:SetAlpha(targeted and 0.92 or 0.72)
    if combatFlair then
        combatFlair:Show()
        combatFlair.OuterGlow:SetAlpha(targeted and 0.46 or 0.36)
        combatFlair.InnerGlow:SetAlpha(targeted and 0.38 or 0.30)
    end
    if combatBadge then
        combatBadge:Show()
        combatBadge.Pulse:SetAlpha(targeted and 0.72 or 0.62)
        combatBadge.Icon:Show()
    end

    portrait:SetScript("OnUpdate", function(self, elapsed)
        self.petCombatPulseElapsed = (self.petCombatPulseElapsed or 0) + elapsed
        local base = targeted and 0.72 or 0.58
        local amplitude = targeted and 0.25 or 0.21
        local pulse = base + (math.sin(self.petCombatPulseElapsed * 5.7) * amplitude)
        self.CombatGlow:SetAlpha(math.max(0.30, math.min(1.0, pulse)))

        if combatFlair and combatFlair:IsShown() then
            local t = self.petCombatPulseElapsed * 3.0
            local broadWave = (math.sin(t) + 1) * 0.5
            local innerWave = (math.sin(t + 1.25) + 1) * 0.5
            local targetBoost = targeted and 0.10 or 0
            combatFlair.OuterGlow:SetAlpha(0.18 + targetBoost + (broadWave * 0.30))
            combatFlair.InnerGlow:SetAlpha(0.11 + targetBoost + (innerWave * 0.27))
            for i, sparkData in ipairs(combatFlair.Sparks or {}) do
                local phase = (i - 1) * 0.82
                local wave = (math.sin((t * 1.18) + phase) + 1) * 0.5
                sparkData.texture:SetAlpha(0.08 + (wave * 0.42) + (targeted and 0.07 or 0))
            end
        end

        if combatBadge and combatBadge:IsShown() then
            local badgePulse = 0.46 + (math.sin(self.petCombatPulseElapsed * 5.0) * 0.16)
            local extra = targeted and 0.16 or 0.10
            combatBadge.Pulse:SetAlpha(math.max(0.34, math.min(0.78, badgePulse + extra)))
        end
    end)
end

function SUF:HandlePetCombatFeedback(eventType, flagText, amount, schoolMask)
    if not self.db or not self.db.showPetCombatFeedback then
        return
    end

    local frame = self:GetUnitFrame("pet")
    local controller = frame and frame.PetCombatFeedback
    if not controller or not controller.feedbackText then
        return
    end

    if CombatFeedback_OnCombatEvent then
        CombatFeedback_OnCombatEvent(controller, eventType, flagText, tonumber(amount) or 0, tonumber(schoolMask) or 0)
        return
    end

    -- Fallback for clients where Blizzard's helper is unexpectedly unavailable.
    local labels = {
        MISS = MISS or "Miss",
        DODGE = DODGE or "Dodge",
        PARRY = PARRY or "Parry",
        BLOCK = BLOCK or "Block",
        RESIST = RESIST or "Resist",
        ABSORB = ABSORB or "Absorb",
        IMMUNE = IMMUNE or "Immune",
        EVADE = EVADE or "Evade",
        DEFLECT = DEFLECT or "Deflect",
        REFLECT = REFLECT or "Reflect",
        INTERRUPT = INTERRUPT or "Interrupt",
    }

    local text = controller.feedbackText
    local display
    local r, g, b = 1.0, 0.15, 0.12
    if eventType == "WOUND" and tonumber(amount) and tonumber(amount) > 0 then
        display = tostring(math.floor(tonumber(amount) + 0.5))
    elseif eventType == "HEAL" and tonumber(amount) and tonumber(amount) > 0 then
        display = "+" .. tostring(math.floor(tonumber(amount) + 0.5))
        r, g, b = 0.15, 1.0, 0.20
    else
        display = labels[eventType] or labels[flagText]
    end

    if display then
        text:SetText(display)
        text:SetTextColor(r, g, b)
        text:SetAlpha(1)
        text:Show()
        controller.fallbackHideAt = GetTime() + 1.0
        controller:SetScript("OnUpdate", function(self)
            if self.fallbackHideAt and GetTime() >= self.fallbackHideAt then
                self.feedbackText:Hide()
                self.fallbackHideAt = nil
            end
        end)
    end
end

function SUF:UpdateRestingIndicator()
    local frame = self:GetUnitFrame("player")
    if not frame or not self.db or not frame.RestingIndicator then
        return
    end

    local rest = frame.RestingIndicator
    local portrait = frame.PortraitFrame
    local inCombat = self.playerInCombat == true
    local resting = IsResting and IsResting() or false
    local enabled = self.db.showRestingIndicator and resting and not inCombat
    local style = self.db.restingIndicatorStyle or "RETAIL"

    rest:SetScript("OnUpdate", nil)
    rest.elapsed = 0

    if not enabled then
        for _, sparkData in ipairs(rest.Sparks or {}) do
            sparkData.texture:SetAlpha(0)
        end
        for _, z in ipairs(rest.Zs or {}) do
            z:Hide()
            z:SetAlpha(0)
        end
        rest.Icon:Hide()
        rest.OuterGlow:SetAlpha(0)
        rest.InnerGlow:SetAlpha(0)
        ApplyPortraitRingStyle(portrait)
        ApplyPlayerCornerOrnamentStyle(portrait)
        rest:Hide()
        return
    end

    rest:Show()
    if portrait and portrait.Accent then
        portrait.Accent:SetColorTexture(0.72, 0.45, 0.04, 1.00)
    end
    ApplyPlayerCornerOrnamentStyle(portrait, { 0.72, 0.45, 0.04, 1.00 })

    if style == "CLASSIC" then
        rest.Icon:Show()
        rest.Icon:SetAlpha(1)
        for _, z in ipairs(rest.Zs or {}) do
            z:Hide()
        end
    else
        rest.Icon:Hide()
        for _, z in ipairs(rest.Zs or {}) do
            z:Show()
        end
    end

    rest:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        local t = self.elapsed * 3.0
        local broadWave = (math.sin(t) + 1) * 0.5
        local innerWave = (math.sin(t + 1.25) + 1) * 0.5

        self.OuterGlow:SetAlpha(0.22 + (broadWave * 0.34))
        self.InnerGlow:SetAlpha(0.14 + (innerWave * 0.30))

        for i, sparkData in ipairs(self.Sparks or {}) do
            local phase = (i - 1) * 0.82
            local wave = (math.sin((t * 1.18) + phase) + 1) * 0.5
            sparkData.texture:SetAlpha(0.12 + (wave * 0.50))
        end

        if style == "CLASSIC" then
            self.Icon:SetAlpha(0.86 + (((math.sin(t + 0.7) + 1) * 0.5) * 0.14))
        else
            -- Retail-like staged sleep sequence: Z, then Z, then Z. Each one
            -- rises smoothly into place, all three pause together briefly,
            -- then fade as a group before the next sequence begins.
            local cycleDuration = 2.20
            local stagger = 0.34
            local riseDuration = 0.48
            local holdEnd = 1.84
            local fadeDuration = 0.22
            local cycleTime = self.elapsed % cycleDuration
            local finalPositions = {
                -- Deliberately irregular rather than a ruler-straight staircase,
                -- and pulled closer/lower to the portrait like the Retail sequence.
                { x = -13, y = -8, startDX = -2, startDY = -8,  curveX = -1.1, curveY = 0.7 },
                { x = -4,  y = -1, startDX = -4, startDY = -8,  curveX =  2.1, curveY = 1.0 },
                { x = -1,  y = 8,  startDX =  1, startDY = -9,  curveX = -1.3, curveY = 1.1 },
            }

            for i, z in ipairs(self.Zs or {}) do
                local final = finalPositions[i] or finalPositions[#finalPositions]
                local startTime = (i - 1) * stagger
                local riseEnd = startTime + riseDuration
                local alpha = 0
                local progress = 0

                if cycleTime >= startTime and cycleTime < riseEnd then
                    progress = (cycleTime - startTime) / riseDuration
                    -- Smoothstep keeps the rise soft while the sine arc below
                    -- introduces just enough sideways/vertical drift to feel
                    -- hand-animated rather than mechanically linear.
                    progress = progress * progress * (3 - (2 * progress))
                    alpha = progress
                elseif cycleTime >= riseEnd and cycleTime < holdEnd then
                    progress = 1
                    alpha = 1
                elseif cycleTime >= holdEnd and cycleTime < (holdEnd + fadeDuration) then
                    progress = 1
                    alpha = 1 - ((cycleTime - holdEnd) / fadeDuration)
                end

                if alpha > 0.001 then
                    -- As later Zs arrive, earlier ones soften slightly to make
                    -- the sleep sequence feel more layered and dynamic.
                    if i == 1 then
                        if cycleTime >= (2 * stagger) then
                            alpha = alpha * 0.74
                        elseif cycleTime >= stagger then
                            alpha = alpha * 0.87
                        end
                    elseif i == 2 then
                        if cycleTime >= (2 * stagger) then
                            alpha = alpha * 0.87
                        end
                    end

                    local startX = final.x + final.startDX
                    local startY = final.y + final.startDY
                    local arc = math.sin(progress * math.pi)
                    local x = startX + ((final.x - startX) * progress) + (arc * final.curveX)
                    local y = startY + ((final.y - startY) * progress) + (arc * final.curveY)
                    z:ClearAllPoints()
                    z:SetPoint("CENTER", portrait, "TOPRIGHT", x, y)
                    z:SetAlpha(math.max(0, math.min(1, alpha)))
                    z:Show()
                else
                    z:SetAlpha(0)
                    z:Hide()
                end
            end
        end
    end)
end

function SUF:UpdateCombatIndicator(inCombat)
    self.playerInCombat = inCombat and true or false

    local frame = self:GetUnitFrame("player")
    if not frame or not self.db then
        return
    end

    local portrait = frame.PortraitFrame
    local combatBadge = frame.CombatBadge
    local combatFlair = frame.CombatFlair
    local enabled = self.db.showCombatIndicator and inCombat
    if not portrait or not portrait.CombatGlow then
        return
    end

    if frame.CombatText then
        frame.CombatText:SetText("")
        frame.CombatText:Hide()
    end

    portrait:SetScript("OnUpdate", nil)
    portrait.combatPulseElapsed = 0

    if enabled then
        -- Keep the stronger portrait-ring combat pulse from before v0.22.24.
        -- Only the badge itself should use the newer, more restrained styling.
        portrait.CombatGlow:SetAlpha(0.72)
        if combatFlair then
            combatFlair:Show()
            combatFlair.OuterGlow:SetAlpha(0.40)
            combatFlair.InnerGlow:SetAlpha(0.32)
        end
        if combatBadge then
            combatBadge:Show()
            combatBadge.Pulse:SetAlpha(0.62)
            combatBadge.Icon:Show()
        end

        portrait:SetScript("OnUpdate", function(self, elapsed)
            self.combatPulseElapsed = (self.combatPulseElapsed or 0) + elapsed
            local pulse = 0.60 + (math.sin(self.combatPulseElapsed * 5.4) * 0.24)
            self.CombatGlow:SetAlpha(math.max(0.32, math.min(0.95, pulse)))

            if combatFlair and combatFlair:IsShown() then
                local t = self.combatPulseElapsed * 3.0
                local broadWave = (math.sin(t) + 1) * 0.5
                local innerWave = (math.sin(t + 1.25) + 1) * 0.5
                combatFlair.OuterGlow:SetAlpha(0.20 + (broadWave * 0.34))
                combatFlair.InnerGlow:SetAlpha(0.13 + (innerWave * 0.30))
                for i, sparkData in ipairs(combatFlair.Sparks or {}) do
                    local phase = (i - 1) * 0.82
                    local wave = (math.sin((t * 1.18) + phase) + 1) * 0.5
                    sparkData.texture:SetAlpha(0.10 + (wave * 0.48))
                end
            end

            if combatBadge and combatBadge:IsShown() then
                -- The icon/badge keeps the softer v0.22.24 pulse treatment.
                local badgePulse = 0.46 + (math.sin(self.combatPulseElapsed * 5.0) * 0.16)
                combatBadge.Pulse:SetAlpha(math.max(0.34, math.min(0.72, badgePulse + 0.10)))
            end
        end)
    else
        portrait.CombatGlow:SetAlpha(0)
        if combatFlair then
            combatFlair.OuterGlow:SetAlpha(0)
            combatFlair.InnerGlow:SetAlpha(0)
            for _, sparkData in ipairs(combatFlair.Sparks or {}) do
                sparkData.texture:SetAlpha(0)
            end
            combatFlair:Hide()
        end
        if combatBadge then
            combatBadge.Pulse:SetAlpha(0)
            combatBadge:Hide()
        end
    end

    if portrait.Separator then
        portrait.Separator:SetColorTexture(0.08, 0.12, 0.18, 0)
    end
end

function SUF:UpdatePVPStatus(unit)
    unit = unit or "player"

    local frame = self:GetUnitFrame(unit)
    local db = self.db
    local holder = frame and frame.PVPStatus
    if not holder or not db then
        return
    end

    holder:SetScript("OnUpdate", nil)
    holder.elapsed = 0

    if unit ~= "player" and not UnitExists(unit) then
        holder:Hide()
        return
    end

    -- PvP status can apply to both player characters and NPC targets.
    -- Keep evaluating UnitIsPVP() for any valid target unit.
    local isFFA = UnitIsPVPFreeForAll and UnitIsPVPFreeForAll(unit)
    local isPVP = isFFA or (UnitIsPVP and UnitIsPVP(unit))
    local timerRunning = unit == "player" and IsPVPTimerRunning and IsPVPTimerRunning()
    local isPartyUnit = type(unit) == "string" and unit:match("^party%d$")
    local iconEnabled = isPartyUnit and db.showPartyPVPIndicator or db.showPVPIndicator
    local showIcon = iconEnabled and isPVP
    local showTimer = unit == "player" and db.showPVPTimer and timerRunning

    if not showIcon and not showTimer then
        holder:Hide()
        holder.Icon:Hide()
        holder.TimerText:Hide()
        holder.TimerText:SetText("")
        return
    end

    if showIcon then
        -- Route the live PvP texture through the custom/default selector.
        -- v0.22.7/8 accidentally kept Blizzard's original assignment here,
        -- so the new setting existed but could never affect the displayed icon.
        holder.Icon:SetTexture(GetPVPIconTexture(unit, isFFA))
        holder.Icon:SetTexCoord(0, 1, 0, 1)
        holder.Icon:Show()
    else
        holder.Icon:Hide()
    end

    if showTimer then
        local function RefreshTimerText(self)
            if not (IsPVPTimerRunning and IsPVPTimerRunning()) then
                self.TimerText:SetText("")
                self.TimerText:Hide()
                self:SetScript("OnUpdate", nil)
                SUF:UpdatePVPStatus("player")
                return
            end

            local timeLeft = GetPVPTimer and GetPVPTimer() or 0
            self.TimerText:SetText(FormatPVPClearTimer(timeLeft))
            ApplyPVPTimerTextColor(self.TimerText, SUF and SUF.db)
            self.TimerText:Show()
        end

        RefreshTimerText(holder)
        holder:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = (self.elapsed or 0) + elapsed
            if self.elapsed >= 0.20 then
                self.elapsed = 0
                RefreshTimerText(self)
            end
        end)
    else
        holder.TimerText:SetText("")
        holder.TimerText:Hide()
    end

    if unit ~= "player" then
        holder.TimerText:SetText("")
        holder.TimerText:Hide()
    end

    holder:Show()
end

function SUF:UpdatePVPStatuses()
    self:UpdatePVPStatus("player")
    self:UpdatePVPStatus("target")
    for i = 1, 4 do
        self:UpdatePVPStatus("party" .. i)
    end
end

function SUF:RefreshUnitWatch(unit)
    local frame = self:GetUnitFrame(unit)
    local keys = self.UnitKeys and self.UnitKeys[unit]
    if not frame or not keys or not self.db then
        return
    end

    if not self:IsLayoutChangeAllowed() then
        self.pendingAppearance = true
        return
    end

    if unit == "player" then
        frame:SetShown(self.db[keys.enabled])
        return
    end

    if RegisterUnitWatch and UnregisterUnitWatch then
        UnregisterUnitWatch(frame)
    end

    if not self.db[keys.enabled] then
        frame:Hide()
        return
    end

    if self.db.previewMode then
        frame:Show()
    elseif RegisterUnitWatch then
        RegisterUnitWatch(frame)
    else
        frame:SetShown(UnitExists(unit))
    end
end

function SUF:RefreshPartyTargetWatch(ownerUnit)
    if not self.db or type(ownerUnit) ~= "string" or not ownerUnit:match("^party%d$") then
        return
    end

    if not self:IsLayoutChangeAllowed() then
        self.pendingAppearance = true
        return
    end

    local ownerFrame = self:GetUnitFrame(ownerUnit)
    local targetFrame = ownerFrame and ownerFrame.PartyTarget
    if not targetFrame then
        return
    end

    if RegisterUnitWatch and UnregisterUnitWatch then
        UnregisterUnitWatch(targetFrame)
    end

    if not self.db.enableParty or not self.db.showPartyTargets or self.db.previewMode then
        targetFrame:Hide()
        return
    end

    if RegisterUnitWatch then
        RegisterUnitWatch(targetFrame)
    else
        targetFrame:SetShown(UnitExists(targetFrame.targetUnit))
    end
end

function SUF:RefreshUnitWatches()
    self:RefreshUnitWatch("player")
    self:RefreshUnitWatch("target")
    self:RefreshUnitWatch("targettarget")
    self:RefreshUnitWatch("focus")
    self:RefreshUnitWatch("pet")
    self:RefreshUnitWatch("party1")
    self:RefreshUnitWatch("party2")
    self:RefreshUnitWatch("party3")
    self:RefreshUnitWatch("party4")
    for i = 1, 4 do
        self:RefreshPartyTargetWatch("party" .. i)
    end
end

-- Target extras ----------------------------------------------------------------

local function SafeNumber(value)
    local ok, number = pcall(tonumber, value)
    if ok then
        return number
    end
    return nil
end

local function FormatAuraRemaining(expirationTime)
    expirationTime = SafeNumber(expirationTime)
    if not expirationTime or expirationTime <= 0 then
        return ""
    end

    local remaining = math.max(0, expirationTime - GetTime())
    if remaining <= 0 then
        return ""
    elseif remaining > 300 then
        -- Above five minutes, keep the label compact and show whole minutes only.
        -- Example: 1620 seconds -> 27m.
        return string.format("%dm", math.ceil(remaining / 60))
    elseif remaining >= 60 then
        -- From 1:00 through 5:00, show minutes:seconds.
        local totalSeconds = math.ceil(remaining)
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds % 60
        return string.format("%d:%02d", minutes, seconds)
    elseif remaining > 5 then
        -- Under one minute, show whole seconds.
        return tostring(math.ceil(remaining))
    end

    -- Only the final five seconds use tenths for precise refresh timing.
    return string.format("%.1f", remaining)
end

local MAX_TARGET_DOTS = 12
local MAX_TARGET_BUFFS = 24
local MAX_TARGET_DEBUFFS = 24
local MAX_PARTY_BUFFS = 12
local MAX_PARTY_DEBUFFS = 12

local function CreateAuraButton(parent, harmful, unit)
    local button = CreateFrame("Frame", nil, parent)
    button:EnableMouse(true)
    button.unit = unit or "target"

    local border = button:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    if harmful then
        border:SetColorTexture(0.30, 0.07, 0.09, 0.95)
    else
        border:SetColorTexture(0.06, 0.16, 0.27, 0.95)
    end
    local borderMask = AddShapeMask(button, border, GetAuraMaskPath())

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local iconMask = AddShapeMask(button, icon, GetAuraMaskPath())

    -- Native WoW Cooldown widget gives us the familiar radial "clock wipe".
    -- Blizzard's own countdown numbers are hidden because we keep our custom
    -- seconds/tenths text on top.
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
    cooldown:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
    cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
    if cooldown.SetDrawSwipe then cooldown:SetDrawSwipe(true) end
    if cooldown.SetDrawEdge then cooldown:SetDrawEdge(false) end
    if cooldown.SetDrawBling then cooldown:SetDrawBling(false) end
    if cooldown.SetHideCountdownNumbers then cooldown:SetHideCountdownNumbers(true) end
    if cooldown.SetReverse then cooldown:SetReverse(false) end
    if cooldown.SetSwipeTexture then cooldown:SetSwipeTexture(GetAuraMaskPath()) end
    if cooldown.SetSwipeColor then cooldown:SetSwipeColor(0, 0, 0, 0.62) end
    cooldown:Hide()

    local textOverlay = CreateFrame("Frame", nil, button)
    textOverlay:SetAllPoints(button)
    textOverlay:SetFrameLevel(button:GetFrameLevel() + 2)

    local count = textOverlay:CreateFontString(nil, "OVERLAY")
    count:SetPoint("TOPRIGHT", -1, -1)
    count:SetFont(FONT_NORMAL, 10, "OUTLINE")
    count:SetTextColor(1, 1, 1, 1)

    local timer = textOverlay:CreateFontString(nil, "OVERLAY", nil, 2)
    timer:SetPoint("CENTER", button, "CENTER", 0, 0)
    timer:SetFont(FONT_NORMAL, 11, "OUTLINE")
    timer:SetTextColor(1.00, 0.92, 0.62, 1.00)
    timer:SetShadowColor(0, 0, 0, 1)
    timer:SetShadowOffset(1, -1)
    if timer.SetJustifyH then timer:SetJustifyH("CENTER") end
    if timer.SetJustifyV then timer:SetJustifyV("MIDDLE") end
    timer:Hide()

    button.Icon = icon
    button.Border = border
    button.BorderMask = borderMask
    button.IconMask = iconMask
    button.Cooldown = cooldown
    button.Count = count
    button.TimerText = timer
    button.harmful = harmful
    button.expirationTime = nil

    button:SetScript("OnEnter", function(self)
        local tooltipUnit = self.unit or "target"
        if not self.auraIndex or not UnitExists(tooltipUnit) then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if GameTooltip.SetUnitAura then
            GameTooltip:SetUnitAura(tooltipUnit, self.auraIndex, self.filter)
            GameTooltip:Show()
        end
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:Hide()
    return button
end

local function CreateTargetCastbar(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:Hide()

    local shadow = CreateSolid(holder, "BACKGROUND", COLORS.shadow, -2)
    shadow:SetPoint("TOPLEFT", 3, -3)
    shadow:SetPoint("BOTTOMRIGHT", 4, -4)

    local outer = CreateSolid(holder, "BACKGROUND", COLORS.frameOuter)
    outer:SetAllPoints()

    local edge = CreateSolid(holder, "BORDER", COLORS.frameEdge)
    edge:SetPoint("TOPLEFT", 1, -1)
    edge:SetPoint("BOTTOMRIGHT", -1, 1)

    local bar = CreateFrame("StatusBar", nil, holder)
    bar:SetPoint("TOPLEFT", 2, -2)
    bar:SetPoint("BOTTOMRIGHT", -2, 2)
    bar:SetStatusBarTexture(WHITE_TEXTURE)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    SetGradient(bar:GetStatusBarTexture(), COLORS.castBottom, COLORS.castTop)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    SetGradient(bg, { 0.05, 0.04, 0.02, 1 }, { 0.10, 0.08, 0.03, 1 })

    local name = bar:CreateFontString(nil, "OVERLAY")
    name:SetPoint("LEFT", 7, 0)
    name:SetFont(FONT_NORMAL, 11, "OUTLINE")
    name:SetTextColor(1, 1, 1, 1)

    local time = bar:CreateFontString(nil, "OVERLAY")
    time:SetPoint("RIGHT", -6, 0)
    time:SetFont(FONT_NORMAL, 10, "OUTLINE")
    time:SetTextColor(1, 1, 1, 1)

    holder.Bar = bar
    holder.NameText = name
    holder.TimeText = time
    holder.isChannel = false
    holder.startTime = 0
    holder.endTime = 0

    holder:SetScript("OnUpdate", function(self)
        local now = GetTime() * 1000
        local duration = math.max(1, self.endTime - self.startTime)

        if self.isChannel then
            local remaining = math.max(0, self.endTime - now)
            self.Bar:SetMinMaxValues(0, duration)
            self.Bar:SetValue(remaining)
            self.TimeText:SetText(string.format("%.1f", remaining / 1000))
            if remaining <= 0 then
                self:Hide()
            end
        else
            local elapsed = math.max(0, math.min(duration, now - self.startTime))
            self.Bar:SetMinMaxValues(0, duration)
            self.Bar:SetValue(elapsed)
            self.TimeText:SetText(string.format("%.1f", math.max(0, self.endTime - now) / 1000))
            if now >= self.endTime then
                self:Hide()
            end
        end
    end)

    return holder
end

local function UpdateAuraHolderTimerText(holder, collections, elapsed)
    holder.elapsed = (holder.elapsed or 0) + elapsed
    if holder.elapsed < 0.10 then
        return
    end
    holder.elapsed = 0

    for _, collection in ipairs(collections) do
        for i = 1, #collection do
            local button = collection[i]
            if button:IsShown() and button.TimerText:IsShown() then
                local text = FormatAuraRemaining(button.expirationTime)
                button.TimerText:SetText(text)
                if text == "" then
                    button.TimerText:Hide()
                end
            end
        end
    end
end

local function CreateComboPointDisplay(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetFrameLevel(parent:GetFrameLevel() + 12)
    holder:EnableMouse(false)
    holder.Pips = {}

    for i = 1, 5 do
        local pip = CreateFrame("Frame", nil, holder)
        pip:SetSize(12, 12)
        pip:EnableMouse(false)

        local outer = pip:CreateTexture(nil, "BACKGROUND")
        outer:SetAllPoints(pip)
        outer:SetColorTexture(0.035, 0.018, 0.015, 0.98)
        local outerMask = AddShapeMask(pip, outer, COMBAT_BADGE_MASK)

        local fill = pip:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT", pip, "TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMRIGHT", pip, "BOTTOMRIGHT", -2, 2)
        fill:SetColorTexture(0.10, 0.06, 0.04, 0.82)
        local fillMask = AddShapeMask(pip, fill, COMBAT_BADGE_MASK)

        holder.Pips[i] = {
            Frame = pip,
            Outer = outer,
            Fill = fill,
            OuterMask = outerMask,
            FillMask = fillMask,
        }
    end

    holder:Hide()
    return holder
end

function SUF:ApplyTargetComboPointsLayout(frame)
    if not frame or not frame.ComboPoints then
        return
    end

    local holder = frame.ComboPoints
    local size = 12
    local gap = 4
    local totalWidth = (size * 5) + (gap * 4)

    holder:ClearAllPoints()
    holder:SetPoint("TOPLEFT", frame.Body, "BOTTOMLEFT", 0, -5)
    holder:SetSize(totalWidth, size)

    for i, data in ipairs(holder.Pips or {}) do
        local pip = data.Frame
        pip:ClearAllPoints()
        pip:SetSize(size, size)
        if i == 1 then
            pip:SetPoint("LEFT", holder, "LEFT", 0, 0)
        else
            pip:SetPoint("LEFT", holder.Pips[i - 1].Frame, "RIGHT", gap, 0)
        end
    end
end

function SUF:UpdateComboPoints()
    local frame = self:GetUnitFrame("target")
    local holder = frame and frame.ComboPoints
    if not frame or not holder or not self.db then
        return
    end

    local points = 0
    local preview = self.db.previewMode and not UnitExists("target")

    if preview then
        points = math.max(0, math.min(5, math.floor((tonumber(self.db.previewComboPoints) or 0) + 0.5)))
    elseif UnitExists("target") and GetComboPoints then
        local ok, value = pcall(GetComboPoints, "player", "target")
        if ok then
            points = math.max(0, math.min(5, tonumber(value) or 0))
        end
    end

    local show = self.db.showComboPoints and self.db.enableTarget and points > 0
    holder:SetShown(show)

    for i, data in ipairs(holder.Pips or {}) do
        local active = i <= points
        data.Frame:SetShown(show)
        if active then
            data.Outer:SetColorTexture(0.24, 0.055, 0.025, 0.98)
            SetGradient(data.Fill, { 0.52, 0.08, 0.025, 1.00 }, { 1.00, 0.62, 0.10, 1.00 })
            data.Fill:SetAlpha(1.00)
        else
            data.Outer:SetColorTexture(0.028, 0.030, 0.038, 0.92)
            data.Fill:SetColorTexture(0.08, 0.085, 0.10, 0.72)
            data.Fill:SetAlpha(0.72)
        end
    end

    self:ApplyTargetComboPointsLayout(frame)
    self:ApplyTargetExtrasLayout(frame)
end

function SUF:CreateTargetExtras(frame)
    frame.ComboPoints = CreateComboPointDisplay(frame)

    local auraHolder = CreateFrame("Frame", nil, frame)
    auraHolder:SetFrameLevel(frame:GetFrameLevel() + 10)
    auraHolder.elapsed = 0

    auraHolder.MyDebuffs = {}
    auraHolder.Buffs = {}
    auraHolder.Debuffs = {}

    -- Allocate the maximum supported buttons once. Settings only control how
    -- many are populated, avoiding frame creation churn while the UI is live.
    for i = 1, MAX_TARGET_DOTS do
        auraHolder.MyDebuffs[i] = CreateAuraButton(auraHolder, true, "target")
    end
    for i = 1, MAX_TARGET_BUFFS do
        auraHolder.Buffs[i] = CreateAuraButton(auraHolder, false, "target")
    end
    for i = 1, MAX_TARGET_DEBUFFS do
        auraHolder.Debuffs[i] = CreateAuraButton(auraHolder, true, "target")
    end

    auraHolder:SetScript("OnUpdate", function(self, elapsed)
        UpdateAuraHolderTimerText(self, { self.MyDebuffs, self.Buffs, self.Debuffs }, elapsed)
    end)

    frame.TargetAuras = auraHolder
    frame.TargetCastbar = CreateTargetCastbar(frame)
end

function SUF:CreatePartyExtras(frame, unit)
    frame.PartyTarget = CreatePartyTargetIndicator(frame, unit)

    local auraHolder = CreateFrame("Frame", nil, frame)
    auraHolder:SetFrameLevel(frame:GetFrameLevel() + 10)
    auraHolder.elapsed = 0
    auraHolder.unit = unit
    auraHolder.Buffs = {}
    auraHolder.Debuffs = {}

    for i = 1, MAX_PARTY_BUFFS do
        auraHolder.Buffs[i] = CreateAuraButton(auraHolder, false, unit)
    end
    for i = 1, MAX_PARTY_DEBUFFS do
        auraHolder.Debuffs[i] = CreateAuraButton(auraHolder, true, unit)
    end

    auraHolder:SetScript("OnUpdate", function(self, elapsed)
        UpdateAuraHolderTimerText(self, { self.Buffs, self.Debuffs }, elapsed)
    end)

    auraHolder:Hide()
    frame.PartyAuras = auraHolder
end

function SUF:ApplyTargetExtrasLayout(frame)
    if not frame or not frame.TargetAuras or not frame.TargetCastbar then
        return
    end

    local holder = frame.TargetAuras
    local ownSize = math.floor((self.db and self.db.ownDebuffSize or 32) + 0.5)
    local smallSize = math.floor((self.db and self.db.targetAuraSize or 22) + 0.5)
    local ownGap = 4
    local smallGap = 3
    local rowGap = 4

    local ownCount = holder.MyDebuffCount or 0
    local buffCount = holder.BuffCount or 0
    local debuffCount = holder.DebuffCount or 0

    local ownWidth = ownCount > 0 and ((ownSize * ownCount) + (ownGap * (ownCount - 1))) or 0
    local buffWidth = buffCount > 0 and ((smallSize * buffCount) + (smallGap * (buffCount - 1))) or 0
    local debuffWidth = debuffCount > 0 and ((smallSize * debuffCount) + (smallGap * (debuffCount - 1))) or 0
    local healthWidth = frame.Health:GetWidth() or 0
    if healthWidth <= 0 then
        healthWidth = frame.Body:GetWidth() or 1
    end
    local holderWidth = math.max(1, healthWidth)

    local y = 0
    local function LayoutRow(buttons, count, size, gap)
        if count <= 0 then
            return
        end

        local perLine = math.max(1, math.floor((holderWidth + gap) / (size + gap)))
        local lines = math.max(1, math.ceil(count / perLine))

        for i = 1, #buttons do
            local button = buttons[i]
            button:ClearAllPoints()
            button:SetSize(size, size)

            -- Scale the countdown text together with the aura icon instead of
            -- keeping every timer at a fixed font size.
            if button.TimerText then
                local timerFontSize = math.max(10, math.min(24, math.floor((size * 0.38) + 0.5)))
                button.TimerText:SetFont(FONT_NORMAL, timerFontSize, "OUTLINE")
            end

            if i <= count then
                local zero = i - 1
                local column = zero % perLine
                local row = math.floor(zero / perLine)
                button:SetPoint("TOPLEFT", holder, "TOPLEFT", column * (size + gap), -(y + (row * (size + gap))))
            end
        end

        y = y + (lines * size) + ((lines - 1) * gap) + rowGap
    end

    LayoutRow(holder.MyDebuffs, ownCount, ownSize, ownGap)
    LayoutRow(holder.Buffs, buffCount, smallSize, smallGap)
    LayoutRow(holder.Debuffs, debuffCount, smallSize, smallGap)

    if y > 0 then
        y = y - rowGap
    end

    local comboVisible = frame.ComboPoints and frame.ComboPoints:IsShown()
    local topOffset = comboVisible and 22 or 5

    holder:ClearAllPoints()
    holder:SetPoint("TOPLEFT", frame.Body, "BOTTOMLEFT", 0, -topOffset)
    holder:SetSize(holderWidth, math.max(1, y))

    local castbar = frame.TargetCastbar
    castbar:ClearAllPoints()
    if self.db and self.db.showTargetAuras and y > 0 then
        -- Keep it below the aura rows, but use the full health/power width so
        -- the spell name and cast progress are easy to read.
        castbar:SetPoint("TOP", holder, "BOTTOM", 0, -4)
        castbar:SetPoint("LEFT", frame.Health, "LEFT", 0, 0)
        castbar:SetPoint("RIGHT", frame.Health, "RIGHT", 0, 0)
    elseif comboVisible then
        castbar:SetPoint("TOP", frame.ComboPoints, "BOTTOM", 0, -4)
        castbar:SetPoint("LEFT", frame.Health, "LEFT", 0, 0)
        castbar:SetPoint("RIGHT", frame.Health, "RIGHT", 0, 0)
    else
        castbar:SetPoint("TOPLEFT", frame.Health, "BOTTOMLEFT", 0, -31)
        castbar:SetPoint("TOPRIGHT", frame.Health, "BOTTOMRIGHT", 0, -31)
    end
    castbar:SetHeight(21)
end

function SUF:ApplyPartyTargetLayout(frame)
    if not frame or not frame.PartyTarget or not self.db then
        return
    end

    local target = frame.PartyTarget
    local portraitSize, _, overlapBehindPortrait, wrapperWidth, wrapperHeight, frameWidth, frameHeight = GetPartyTargetDimensions()
    local topPad = PARTY_TARGET_TUNING.topPad
    local headerHeight = PARTY_TARGET_TUNING.headerHeight
    local headerGap = PARTY_TARGET_TUNING.headerGap
    local healthHeight = PARTY_TARGET_TUNING.healthHeight
    local powerHeight = PARTY_TARGET_TUNING.powerHeight
    local healthPowerOverlap = PARTY_TARGET_TUNING.healthPowerOverlap

    target:ClearAllPoints()
    target:SetSize(frameWidth, frameHeight)
    target:SetPoint("LEFT", frame.Body, "RIGHT", PARTY_TARGET_TUNING.gap, 0)

    target.Body:ClearAllPoints()
    target.Body:SetPoint("TOPLEFT", target, "TOPLEFT", portraitSize - overlapBehindPortrait + 4, -1)
    target.Body:SetSize(wrapperWidth, wrapperHeight)

    local cornerStyle = NormalizeCornerStyle(self.db.cornerStyle)
    local bodyMask = GetCornerMask("Body", false, cornerStyle)
    SetMaskPath(target.BodyOuterMask, bodyMask)
    SetMaskPath(target.BodyEdgeMask, bodyMask)
    SetMaskPath(target.BodyInnerMask, bodyMask)

    local wrapperOpacity = math.max(0, math.min(100, tonumber(self.db.wrapperOpacity) or 42)) / 100
    target.BodyOuter:SetAlpha(wrapperOpacity)
    target.BodyEdge:SetAlpha(math.min(1, wrapperOpacity * 1.40))
    target.BodyInner:SetAlpha(wrapperOpacity * 0.52)

    local barsLeftInset = math.max(1, overlapBehindPortrait)

    target.Header:ClearAllPoints()
    target.Header:SetPoint("TOPLEFT", target.Body, "TOPLEFT", barsLeftInset, -topPad)
    target.Header:SetPoint("TOPRIGHT", target.Body, "TOPRIGHT", 0, -topPad)
    target.Header:SetHeight(headerHeight)

    target.Health:ClearAllPoints()
    target.Health:SetPoint("TOPLEFT", target.Body, "TOPLEFT", barsLeftInset, -(topPad + headerHeight + headerGap))
    target.Health:SetPoint("TOPRIGHT", target.Body, "TOPRIGHT", 0, -(topPad + headerHeight + headerGap))
    target.Health:SetHeight(healthHeight)

    target.Power:ClearAllPoints()
    target.Power:SetPoint("TOPLEFT", target.Health, "BOTTOMLEFT", 0, healthPowerOverlap)
    target.Power:SetPoint("TOPRIGHT", target.Health, "BOTTOMRIGHT", 0, healthPowerOverlap)
    target.Power:SetHeight(powerHeight)

    local widgets = {
        { widget = target.Health, mask = GetCornerMask("Health", false, cornerStyle) },
        { widget = target.Power, mask = GetCornerMask("Power", false, cornerStyle) },
    }
    for _, entry in ipairs(widgets) do
        local widget = entry.widget
        SetMaskPath(widget.OuterMask, entry.mask)
        SetMaskPath(widget.EdgeMask, entry.mask)
        SetMaskPath(widget.BackgroundMask, entry.mask)
        SetMaskPath(widget.FillMask, entry.mask)
        SetMaskPath(widget.SideGlossMask, entry.mask)
        widget.AlwaysMaskFill = false
        self:UpdateBarFillMask(widget, widget.displayValue, widget.maximum)
        widget.SideGloss:ClearAllPoints()
        widget.SideGloss:SetPoint("TOPRIGHT", widget.Bar, "TOPRIGHT", -1, 0)
        widget.SideGloss:SetPoint("BOTTOMRIGHT", widget.Bar, "BOTTOMRIGHT", -1, 0)
    end

    target.NameText:SetFont(FONT_NORMAL, math.max(14, tonumber(self.db.nameFontSize) or 17), "OUTLINE")
    target.NameText:ClearAllPoints()
    target.NameText:SetPoint("LEFT", target.Header, "LEFT", 5, 0)
    target.NameText:SetPoint("RIGHT", target.Header, "RIGHT", -5, 0)
    target.NameText:SetJustifyH("CENTER")

    local healthFont = math.max(12, (tonumber(self.db.barFontSize) or 15) - 1)
    local powerFont = math.max(11, healthFont - 1)
    target.Health.LeftText:SetFont(FONT_NORMAL, healthFont, "OUTLINE")
    target.Health.RightText:SetFont(FONT_NORMAL, healthFont, "OUTLINE")
    target.Power.LeftText:SetFont(FONT_NORMAL, powerFont, "OUTLINE")
    target.Power.RightText:SetFont(FONT_NORMAL, powerFont, "OUTLINE")

    local textInset = 7
    target.Health.LeftText:ClearAllPoints()
    target.Health.RightText:ClearAllPoints()
    target.Power.LeftText:ClearAllPoints()
    target.Power.RightText:ClearAllPoints()
    target.Health.LeftText:SetPoint("LEFT", target.Health.Bar, "LEFT", textInset, 0)
    target.Health.RightText:SetPoint("RIGHT", target.Health.Bar, "RIGHT", -textInset, 0)
    target.Power.LeftText:SetPoint("LEFT", target.Power.Bar, "LEFT", textInset, 0)
    target.Power.RightText:SetPoint("RIGHT", target.Power.Bar, "RIGHT", -textInset, 0)

    local portraitFrame = target.PortraitFrame
    portraitFrame:ClearAllPoints()
    portraitFrame:SetSize(portraitSize + 8, portraitSize + 8)
    portraitFrame:SetPoint("LEFT", target, "LEFT", 0, 0)

    for _, mask in ipairs(portraitFrame.ShapeMasks) do
        SetMaskPath(mask, PORTRAIT_LEFT_MASK)
    end

    portraitFrame.CombatGlow:ClearAllPoints()
    portraitFrame.CombatGlow:SetSize(portraitSize + 12, portraitSize + 12)
    portraitFrame.CombatGlow:SetPoint("CENTER", 1, 0)
    portraitFrame.CombatGlow:SetAlpha(0)

    portraitFrame.Shadow:ClearAllPoints()
    portraitFrame.Shadow:SetSize(portraitSize + 2, portraitSize + 2)
    portraitFrame.Shadow:SetPoint("CENTER")

    portraitFrame.Outer:ClearAllPoints()
    portraitFrame.Outer:SetSize(portraitSize + 4, portraitSize + 4)
    portraitFrame.Outer:SetPoint("CENTER")

    portraitFrame.Accent:ClearAllPoints()
    portraitFrame.Accent:SetSize(portraitSize, portraitSize)
    portraitFrame.Accent:SetPoint("CENTER")

    portraitFrame.Inner:ClearAllPoints()
    local ringInset = PORTRAIT_RING_ACCENT_THICKNESS * 2
    portraitFrame.Inner:SetSize(portraitSize - ringInset, portraitSize - ringInset)
    portraitFrame.Inner:SetPoint("CENTER")
    ApplyPortraitRingStyle(portraitFrame)

    portraitFrame.Portrait:ClearAllPoints()
    portraitFrame.Portrait:SetSize(portraitSize - 8, portraitSize - 8)
    portraitFrame.Portrait:SetPoint("CENTER")

    if portraitFrame.AnimatedModel then
        portraitFrame.AnimatedModel:ClearAllPoints()
        local modelWidth = math.max(1, math.floor((portraitSize - ANIMATED_PORTRAIT_TUNING.widthInset) + 0.5))
        local modelHeight = math.max(1, math.floor((portraitSize - ANIMATED_PORTRAIT_TUNING.heightInset) + 0.5))
        portraitFrame.AnimatedModel:SetSize(modelWidth, modelHeight)
        portraitFrame.AnimatedModel:SetPoint("CENTER", portraitFrame, "CENTER", ANIMATED_PORTRAIT_TUNING.xOffset or 0, ANIMATED_PORTRAIT_TUNING.yOffset or 0)
        if portraitFrame.AnimatedModel.SetViewInsets then
            pcall(portraitFrame.AnimatedModel.SetViewInsets, portraitFrame.AnimatedModel, 0, 0, 0, 0)
        end
        portraitFrame.ModelOverlay:ClearAllPoints()
        portraitFrame.ModelOverlay:SetAllPoints(portraitFrame.AnimatedModel)
        portraitFrame.ModelGlass:ClearAllPoints()
        portraitFrame.ModelGlass:SetAllPoints(portraitFrame.ModelOverlay)
        portraitFrame.ModelSeparator:Hide()
    end

    portraitFrame.Glass:ClearAllPoints()
    portraitFrame.Glass:SetSize(portraitSize - 8, portraitSize - 8)
    portraitFrame.Glass:SetPoint("CENTER")

    portraitFrame.Separator:ClearAllPoints()
    portraitFrame.Separator:SetWidth(1)
    portraitFrame.Separator:SetPoint("TOP", portraitFrame, "TOP", 0, -4)
    portraitFrame.Separator:SetPoint("BOTTOM", portraitFrame, "BOTTOM", 0, 4)
    portraitFrame.Separator:SetPoint("RIGHT", portraitFrame, "RIGHT", -2, 0)
end

function SUF:UpdatePartyTarget(unit, force)
    if not self.db or type(unit) ~= "string" or not unit:match("^party%d$") then
        return
    end

    local frame = self:GetUnitFrame(unit)
    local holder = frame and frame.PartyTarget
    if not frame or not holder then
        return
    end

    local targetUnit = holder.targetUnit or (unit .. "target")
    if not self.db.showPartyTargets or not self.db.enableParty or not UnitExists(unit) or not UnitExists(targetUnit) then
        holder.NameText:SetText("")
        self:SetBarValue(holder.Health, 0, 1, true)
        self:SetBarValue(holder.Power, 0, 1, true)
        holder.Health.LeftText:SetText("")
        holder.Health.RightText:SetText("")
        holder.Power.LeftText:SetText("")
        holder.Power.RightText:SetText("")
        StopAnimatedPortrait(holder)
        if self.db and not self.db.locked then
            self:RefreshPartyGroupMover()
        end
        return
    end

    local currentHealth = UnitHealth(targetUnit) or 0
    local maxHealth = UnitHealthMax(targetUnit) or 0
    if maxHealth <= 0 then maxHealth = 1 end

    local powerType, powerToken = UnitPowerType(targetUnit)
    local currentPower = UnitPower(targetUnit, powerType) or 0
    local maxPower = UnitPowerMax(targetUnit, powerType) or 0
    local isOffline = IsUnitOffline(targetUnit)
    local isGhost = UnitIsGhost and UnitIsGhost(targetUnit) or false
    local isDead = false
    if not isGhost then
        if UnitIsDead then
            isDead = UnitIsDead(targetUnit) or false
        elseif UnitIsDeadOrGhost then
            isDead = UnitIsDeadOrGhost(targetUnit) or false
        end
    end

    holder.NameText:SetText(UnitName(targetUnit) or "")
    holder.NameText:SetTextColor(unpack(COLORS.gold))

    local healthBarValue = (isOffline or isDead or isGhost) and 0 or currentHealth
    self:SetBarValue(holder.Health, healthBarValue, maxHealth, force or isOffline or isDead or isGhost)
    ApplyBarFillGradient(holder.Health, self:GetHealthBarColor(targetUnit))
    holder.Health.LeftText:SetTextColor(unpack(COLORS.text))
    holder.Health.RightText:SetTextColor(unpack(COLORS.text))

    local exactHealthAvailable = HasExactPlayerHealth(targetUnit)
    local centerUnavailablePercent = (not exactHealthAvailable)
        and self.db.showHealthValue
        and self.db.showHealthPercent
        and self.db.centerUnavailableHealthPercent

    if isOffline then
        SetHealthTextLayout(holder, true)
        holder.Health.LeftText:SetText("Offline")
        holder.Health.LeftText:SetTextColor(0.72, 0.72, 0.72, 1.00)
        holder.Health.RightText:SetText("")
    elseif isGhost then
        SetHealthTextLayout(holder, true)
        holder.Health.LeftText:SetText("Ghost")
        holder.Health.RightText:SetText("")
    elseif isDead then
        SetHealthTextLayout(holder, true)
        holder.Health.LeftText:SetText("Dead")
        holder.Health.RightText:SetText("")
    elseif centerUnavailablePercent then
        SetHealthTextLayout(holder, true)
        holder.Health.LeftText:SetText(Percent(currentHealth, maxHealth) .. "%")
        holder.Health.RightText:SetText("")
    else
        SetHealthTextLayout(holder, false)
        holder.Health.LeftText:SetText(self.db.showHealthPercent and (Percent(currentHealth, maxHealth) .. "%") or "")
        if self.db.showHealthValue then
            holder.Health.RightText:SetText(exactHealthAvailable and FormatValue(currentHealth) or "—")
        else
            holder.Health.RightText:SetText("")
        end
    end

    if isOffline then
        self:SetBarValue(holder.Power, 0, math.max(1, maxPower), true)
        holder.Power.LeftText:SetText("")
        holder.Power.RightText:SetText("")
    elseif maxPower > 0 then
        self:SetBarValue(holder.Power, currentPower, maxPower, force)
        holder.Power.LeftText:SetText(self.db.showPowerPercent and (Percent(currentPower, maxPower) .. "%") or "")
        holder.Power.RightText:SetText(self.db.showPowerValue and FormatValue(currentPower) or "")
    else
        self:SetBarValue(holder.Power, 0, 1, true)
        holder.Power.LeftText:SetText("")
        holder.Power.RightText:SetText("")
    end

    local powerColor = POWER_COLORS[powerToken]
    if not powerColor and PowerBarColor then
        local blizzardColor = PowerBarColor[powerToken] or (powerType and PowerBarColor[powerType])
        if blizzardColor then
            powerColor = { blizzardColor.r, blizzardColor.g, blizzardColor.b }
        end
    end
    ApplyBarFillGradient(holder.Power, powerColor or POWER_COLORS.MANA)

    self:UpdateAnimatedPortrait(holder, targetUnit, false, isOffline, force)

    if self.db and not self.db.locked then
        self:RefreshPartyGroupMover()
    end
end

function SUF:UpdateAllPartyTargets(force)
    if not self.UnitFrames then
        return
    end
    for i = 1, 4 do
        self:UpdatePartyTarget("party" .. i, force)
    end
end

function SUF:ApplyPartyAuraLayout(frame)
    if not frame or not frame.PartyAuras then
        return
    end

    local holder = frame.PartyAuras
    local size = math.floor((self.db and self.db.partyAuraSize or 24) + 0.5)
    local gap = 3
    local rowGap = 4
    local position = (self.db and self.db.partyAuraPosition) or "RIGHT"
    local buffCount = holder.BuffCount or 0
    local debuffCount = holder.DebuffCount or 0
    local maxColumns = 0
    local y = 0

    local holderWidth = 1
    local perLine = 6
    if position == "BELOW" then
        holderWidth = frame.Power and frame.Power:GetWidth() or (self.db and self.db.partyBodyWidth) or 224
        if not holderWidth or holderWidth <= 0 then
            holderWidth = 224
        end
        perLine = math.max(1, math.floor((holderWidth + gap) / (size + gap)))
    end

    local function LayoutCollection(buttons, count)
        if count <= 0 then
            for i = 1, #buttons do
                buttons[i]:ClearAllPoints()
                buttons[i]:SetSize(size, size)
            end
            return
        end

        local rows = math.ceil(count / perLine)
        maxColumns = math.max(maxColumns, math.min(perLine, count))

        for i = 1, #buttons do
            local button = buttons[i]
            button:ClearAllPoints()
            button:SetSize(size, size)

            if button.TimerText then
                local timerFontSize = math.max(10, math.min(22, math.floor((size * 0.38) + 0.5)))
                button.TimerText:SetFont(FONT_NORMAL, timerFontSize, "OUTLINE")
            end

            if i <= count then
                local zero = i - 1
                local column = zero % perLine
                local row = math.floor(zero / perLine)
                button:SetPoint("TOPLEFT", holder, "TOPLEFT", column * (size + gap), -(y + row * (size + gap)))
            end
        end

        y = y + (rows * size) + ((rows - 1) * gap) + rowGap
    end

    LayoutCollection(holder.Buffs, buffCount)
    LayoutCollection(holder.Debuffs, debuffCount)

    if y > 0 then
        y = y - rowGap
    end

    holder:ClearAllPoints()
    if position == "BELOW" then
        holder:SetPoint("TOPLEFT", frame.Power, "BOTTOMLEFT", 0, -5)
        holder:SetSize(math.max(1, holderWidth), math.max(1, y))
    else
        local width = maxColumns > 0 and ((maxColumns * size) + ((maxColumns - 1) * gap)) or 1
        local targetReserve = 0
        if self.db and self.db.showPartyTargets then
            local _, _, _, _, _, partyTargetWidth = GetPartyTargetDimensions()
            targetReserve = partyTargetWidth + PARTY_TARGET_TUNING.gap + 4
        end
        holder:SetPoint("TOPLEFT", frame.Body, "TOPRIGHT", 6 + targetReserve, 0)
        holder:SetSize(math.max(1, width), math.max(1, y))
    end
end

function SUF:ApplyAllPartyAuraLayouts()
    if not self.UnitFrames then
        return
    end
    for i = 1, 4 do
        local frame = self:GetUnitFrame("party" .. i)
        if frame then
            self:ApplyPartyAuraLayout(frame)
        end
    end
end

local function GetAuraData(unit, index, filter)
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then
        return nil
    end

    local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, index, filter)
    if not ok then
        return nil
    end
    return aura
end

local AURA_DOT_CACHE = {}

local function BuildOwnAuraInstanceSet(unit, filter)
    local result = {}
    local playerFilter = filter .. "|PLAYER"

    for index = 1, 40 do
        local aura = GetAuraData(unit, index, playerFilter)
        if not aura then
            break
        end

        if aura.auraInstanceID then
            result[aura.auraInstanceID] = true
        end
    end

    return result
end

local function IsAuraOwnedByPlayer(aura, ownInstanceSet)
    if not aura then
        return false
    end

    if aura.auraInstanceID and ownInstanceSet and ownInstanceSet[aura.auraInstanceID] then
        return true
    end

    local source = aura.sourceUnit
    if source == "player" or source == "pet" or source == "vehicle" then
        return true
    end

    if source and UnitExists and UnitExists(source) and UnitIsUnit then
        if UnitIsUnit(source, "player") then
            return true
        end
        if UnitExists("pet") and UnitIsUnit(source, "pet") then
            return true
        end
        if UnitExists("vehicle") and UnitIsUnit(source, "vehicle") then
            return true
        end
    end

    return false
end

local function IsDamageOverTimeAura(aura)
    if not aura or not aura.spellId then
        return false
    end

    local spellID = SafeNumber(aura.spellId)
    if not spellID then
        return false
    end

    if AURA_DOT_CACHE[spellID] ~= nil then
        return AURA_DOT_CACHE[spellID]
    end

    local description
    if C_Spell and C_Spell.GetSpellDescription then
        local ok, value = pcall(C_Spell.GetSpellDescription, spellID)
        if ok then
            description = value
        end
    elseif GetSpellDescription then
        local ok, value = pcall(GetSpellDescription, spellID)
        if ok then
            description = value
        end
    end

    -- Spell text can be empty until its data has loaded. Don't cache that case;
    -- SPELL_TEXT_UPDATE will make us try again.
    if type(description) ~= "string" or description == "" then
        return false
    end

    local text = description:lower()
    local hasPeriodicLanguage = text:find(" over ", 1, true)
        or text:find(" every ", 1, true)
        or text:find(" each ", 1, true)
        or text:find(" per second", 1, true)
        or text:find(" periodically", 1, true)
    local hasDamageLanguage = text:find("damage", 1, true)
        or text:find("drain", 1, true)
        or text:find("transfers", 1, true)
        or text:find("bleed", 1, true)
        or text:find("burn", 1, true)

    local isDot = not not (hasPeriodicLanguage and hasDamageLanguage)
    AURA_DOT_CACHE[spellID] = isDot
    return isDot
end

function SUF:ClearAuraClassificationCache()
    wipe(AURA_DOT_CACHE)
end

local function GetAuraCountText(unit, aura)
    if not aura then
        return ""
    end

    local applications = SafeNumber(aura.applications)
    if applications and applications > 1 then
        return tostring(math.floor(applications + 0.5))
    end

    if aura.auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
        local ok, text = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, unit, aura.auraInstanceID, 2)
        if ok and text then
            return text
        end
    end
    return ""
end

local function PopulateAuraButton(button, unit, auraEntry, filter, isOwn, showTimer)
    if not auraEntry then
        button.auraIndex = nil
        button.expirationTime = nil
        button.TimerText:SetText("")
        button.TimerText:Hide()
        if button.Cooldown then
            if button.Cooldown.Clear then
                button.Cooldown:Clear()
            else
                button.Cooldown:SetCooldown(0, 0)
            end
            button.Cooldown:Hide()
        end
        button:Hide()
        return
    end

    local aura = auraEntry.aura
    button.auraIndex = auraEntry.index
    button.filter = filter
    button.unit = unit
    button.expirationTime = aura.expirationTime

    local ok = pcall(button.Icon.SetTexture, button.Icon, aura.icon)
    if not ok then
        button.Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    button.Count:SetText(GetAuraCountText(unit, aura))

    if isOwn then
        button.Border:SetColorTexture(0.74, 0.46, 0.10, 0.90)
    elseif filter == "HARMFUL" then
        button.Border:SetColorTexture(0.30, 0.07, 0.09, 0.90)
    else
        button.Border:SetColorTexture(0.06, 0.16, 0.27, 0.90)
    end

    local duration = SafeNumber(aura.duration)
    local expiration = SafeNumber(aura.expirationTime)
    local hasDuration = duration and duration > 0 and expiration and expiration > 0

    if showTimer and hasDuration then
        button.TimerText:SetText(FormatAuraRemaining(expiration))
        button.TimerText:Show()
    else
        button.TimerText:SetText("")
        button.TimerText:Hide()
    end

    if button.Cooldown then
        if isOwn and showTimer and SUF.db and SUF.db.showOwnAuraCooldownSwipe and hasDuration then
            local startTime = expiration - duration
            button.Cooldown:SetCooldown(startTime, duration)
            button.Cooldown:Show()
        else
            if button.Cooldown.Clear then
                button.Cooldown:Clear()
            else
                button.Cooldown:SetCooldown(0, 0)
            end
            button.Cooldown:Hide()
        end
    end

    button:Show()
end

local PREVIEW_AURA_SPELLS = {
    buffs = { 1243, 1126, 1459, 21562, 10901, 14752, 27126, 25898 },
    debuffs = { 702, 1714, 1490, 770, 6788, 1014, 15487, 25771 },
    dots = { 172, 980, 348, 589, 18265, 25309, 27216, 27243 },
}

local function GetPreviewAuraTexture(spellList, index)
    local list = spellList or PREVIEW_AURA_SPELLS.buffs
    local spellID = list[((index - 1) % #list) + 1]
    if C_Spell and C_Spell.GetSpellTexture then
        local texture = C_Spell.GetSpellTexture(spellID)
        if texture then
            return texture
        end
    elseif GetSpellTexture then
        local texture = GetSpellTexture(spellID)
        if texture then
            return texture
        end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function PopulatePreviewAuraButton(button, spellList, index, filter, isOwn, showTimer, seconds)
    if not button then
        return
    end

    button.auraIndex = nil
    button.filter = nil
    button.unit = nil
    button.Icon:SetTexture(GetPreviewAuraTexture(spellList, index))
    button.Count:SetText((index % 4 == 0) and "2" or "")

    if isOwn then
        button.Border:SetColorTexture(0.74, 0.46, 0.10, 0.90)
    elseif filter == "HARMFUL" then
        button.Border:SetColorTexture(0.30, 0.07, 0.09, 0.90)
    else
        button.Border:SetColorTexture(0.06, 0.16, 0.27, 0.90)
    end

    seconds = tonumber(seconds) or 24
    if showTimer then
        button.expirationTime = GetTime() + seconds
        button.TimerText:SetText(FormatAuraRemaining(button.expirationTime))
        button.TimerText:Show()
    else
        button.expirationTime = nil
        button.TimerText:SetText("")
        button.TimerText:Hide()
    end

    if button.Cooldown then
        if isOwn and showTimer and SUF.db and SUF.db.showOwnAuraCooldownSwipe then
            button.Cooldown:SetCooldown(GetTime() - 4, seconds + 4)
            button.Cooldown:Show()
        else
            if button.Cooldown.Clear then
                button.Cooldown:Clear()
            else
                button.Cooldown:SetCooldown(0, 0)
            end
            button.Cooldown:Hide()
        end
    end

    button:Show()
end

function SUF:UpdateTargetAuras()
    local frame = self:GetUnitFrame("target")
    if not frame or not frame.TargetAuras or not self.db then
        return
    end

    local holder = frame.TargetAuras
    local show = self.db.showTargetAuras and self.db.enableTarget and (UnitExists("target") or self.db.previewMode)
    holder:SetShown(show)

    if not show then
        return
    end

    if self.db.previewMode and not UnitExists("target") then
        local buffLimit = math.max(0, math.min(MAX_TARGET_BUFFS, math.floor((tonumber(self.db.targetAuraBuffLimit) or 8) + 0.5)))
        local debuffLimit = math.max(0, math.min(MAX_TARGET_DEBUFFS, math.floor((tonumber(self.db.targetAuraDebuffLimit) or 8) + 0.5)))
        local dotLimit = math.max(0, math.min(MAX_TARGET_DOTS, math.floor((tonumber(self.db.targetAuraDotLimit) or 6) + 0.5)))

        local buffCount = math.min(buffLimit, math.max(0, math.floor((tonumber(self.db.previewTargetBuffs) or 0) + 0.5)))
        local debuffCount = math.min(debuffLimit, math.max(0, math.floor((tonumber(self.db.previewTargetDebuffs) or 0) + 0.5)))
        local dotCount = self.db.emphasizeOwnDebuffs and math.min(dotLimit, math.max(0, math.floor((tonumber(self.db.previewTargetDots) or 0) + 0.5))) or 0

        holder.MyDebuffCount = dotCount
        holder.BuffCount = buffCount
        holder.DebuffCount = debuffCount

        for i = 1, #holder.MyDebuffs do
            if i <= dotCount then
                PopulatePreviewAuraButton(holder.MyDebuffs[i], PREVIEW_AURA_SPELLS.dots, i, "HARMFUL", true, self.db.showOwnDotTimers, 16 + (i * 4))
            else
                holder.MyDebuffs[i]:Hide()
            end
        end

        for i = 1, #holder.Buffs do
            if i <= buffCount then
                local isOwn = (i % 3 == 1)
                PopulatePreviewAuraButton(holder.Buffs[i], PREVIEW_AURA_SPELLS.buffs, i, "HELPFUL", isOwn, isOwn and self.db.showOwnBuffTimers, 45 + (i * 7))
            else
                holder.Buffs[i]:Hide()
            end
        end

        for i = 1, #holder.Debuffs do
            if i <= debuffCount then
                local isOwn = (i % 2 == 1)
                PopulatePreviewAuraButton(holder.Debuffs[i], PREVIEW_AURA_SPELLS.debuffs, i, "HARMFUL", isOwn, isOwn and self.db.showOwnDebuffTimers, 22 + (i * 5))
            else
                holder.Debuffs[i]:Hide()
            end
        end

        self:ApplyTargetExtrasLayout(frame)
        return
    end

    local buffLimit = math.max(1, math.min(MAX_TARGET_BUFFS, math.floor((tonumber(self.db.targetAuraBuffLimit) or 8) + 0.5)))
    local debuffLimit = math.max(1, math.min(MAX_TARGET_DEBUFFS, math.floor((tonumber(self.db.targetAuraDebuffLimit) or 8) + 0.5)))
    local dotLimit = math.max(1, math.min(MAX_TARGET_DOTS, math.floor((tonumber(self.db.targetAuraDotLimit) or 6) + 0.5)))

    -- A normal target frame shows auras regardless of caster. Ownership is
    -- tracked separately so only the player's/pet's effects receive timer text
    -- and radial cooldown wipes according to the three timer settings.
    local ownHelpful = BuildOwnAuraInstanceSet("target", "HELPFUL")
    local ownHarmful = BuildOwnAuraInstanceSet("target", "HARMFUL")

    local buffs = {}
    for index = 1, 40 do
        local aura = GetAuraData("target", index, "HELPFUL")
        if not aura then
            break
        end

        if #buffs < buffLimit then
            buffs[#buffs + 1] = {
                aura = aura,
                index = index,
                isOwn = IsAuraOwnedByPlayer(aura, ownHelpful),
                isDot = false,
            }
        end
    end

    local myDots = {}
    local regularDebuffs = {}
    local emphasizeDots = self.db.emphasizeOwnDebuffs

    for index = 1, 40 do
        local aura = GetAuraData("target", index, "HARMFUL")
        if not aura then
            break
        end

        local isOwn = IsAuraOwnedByPlayer(aura, ownHarmful)
        local isDot = isOwn and IsDamageOverTimeAura(aura) or false
        local entry = {
            aura = aura,
            index = index,
            isOwn = isOwn,
            isDot = isDot,
        }

        if emphasizeDots and isOwn and isDot and #myDots < dotLimit then
            myDots[#myDots + 1] = entry
        elseif #regularDebuffs < debuffLimit then
            regularDebuffs[#regularDebuffs + 1] = entry
        end
    end

    holder.MyDebuffCount = emphasizeDots and #myDots or 0
    holder.BuffCount = #buffs
    holder.DebuffCount = #regularDebuffs

    for i = 1, #holder.MyDebuffs do
        local entry = myDots[i]
        local showTimer = entry and entry.isOwn and self.db.showOwnDotTimers
        PopulateAuraButton(holder.MyDebuffs[i], "target", entry, "HARMFUL", entry and entry.isOwn or false, showTimer or false)
    end

    for i = 1, #holder.Buffs do
        local entry = buffs[i]
        local showTimer = entry and entry.isOwn and self.db.showOwnBuffTimers
        PopulateAuraButton(holder.Buffs[i], "target", entry, "HELPFUL", entry and entry.isOwn or false, showTimer or false)
    end

    for i = 1, #holder.Debuffs do
        local entry = regularDebuffs[i]
        local showTimer = false
        if entry and entry.isOwn then
            if entry.isDot then
                showTimer = self.db.showOwnDotTimers
            else
                showTimer = self.db.showOwnDebuffTimers
            end
        end
        PopulateAuraButton(holder.Debuffs[i], "target", entry, "HARMFUL", entry and entry.isOwn or false, showTimer or false)
    end

    self:ApplyTargetExtrasLayout(frame)
end

function SUF:UpdatePartyAuras(unit)
    if not self.db or type(unit) ~= "string" or not unit:match("^party%d$") then
        return
    end

    local frame = self:GetUnitFrame(unit)
    if not frame or not frame.PartyAuras then
        return
    end

    local holder = frame.PartyAuras
    local previewMissing = self.db.previewMode and not UnitExists(unit)
    local show = self.db.showPartyAuras and self.db.enableParty and (UnitExists(unit) or previewMissing)
    holder:SetShown(show)

    if not show then
        holder.BuffCount = 0
        holder.DebuffCount = 0
        for _, collection in ipairs({ holder.Buffs, holder.Debuffs }) do
            for i = 1, #collection do
                collection[i]:Hide()
            end
        end
        self:ApplyPartyAuraLayout(frame)
        return
    end

    if previewMissing then
        local buffLimit = math.max(0, math.min(MAX_PARTY_BUFFS, math.floor((tonumber(self.db.partyAuraBuffLimit) or 6) + 0.5)))
        local debuffLimit = math.max(0, math.min(MAX_PARTY_DEBUFFS, math.floor((tonumber(self.db.partyAuraDebuffLimit) or 6) + 0.5)))
        local buffCount = math.min(buffLimit, math.max(0, math.floor((tonumber(self.db.previewPartyBuffs) or 0) + 0.5)))
        local debuffCount = math.min(debuffLimit, math.max(0, math.floor((tonumber(self.db.previewPartyDebuffs) or 0) + 0.5)))

        holder.BuffCount = buffCount
        holder.DebuffCount = debuffCount

        for i = 1, #holder.Buffs do
            if i <= buffCount then
                local isOwn = (i % 3 == 1)
                PopulatePreviewAuraButton(holder.Buffs[i], PREVIEW_AURA_SPELLS.buffs, i, "HELPFUL", isOwn, isOwn and self.db.showOwnBuffTimers, 50 + (i * 6))
            else
                holder.Buffs[i]:Hide()
            end
        end

        for i = 1, #holder.Debuffs do
            if i <= debuffCount then
                local isOwn = (i % 2 == 1)
                PopulatePreviewAuraButton(holder.Debuffs[i], PREVIEW_AURA_SPELLS.debuffs, i, "HARMFUL", isOwn, isOwn and self.db.showOwnDebuffTimers, 25 + (i * 4))
            else
                holder.Debuffs[i]:Hide()
            end
        end

        self:ApplyPartyAuraLayout(frame)
        if self.db and not self.db.locked then
            self:RefreshPartyGroupMover()
        end
        return
    end

    local buffLimit = math.max(1, math.min(MAX_PARTY_BUFFS, math.floor((tonumber(self.db.partyAuraBuffLimit) or 6) + 0.5)))
    local debuffLimit = math.max(1, math.min(MAX_PARTY_DEBUFFS, math.floor((tonumber(self.db.partyAuraDebuffLimit) or 6) + 0.5)))
    local ownHelpful = BuildOwnAuraInstanceSet(unit, "HELPFUL")
    local ownHarmful = BuildOwnAuraInstanceSet(unit, "HARMFUL")
    local buffs = {}
    local debuffs = {}

    for index = 1, 40 do
        local aura = GetAuraData(unit, index, "HELPFUL")
        if not aura then
            break
        end
        if #buffs < buffLimit then
            buffs[#buffs + 1] = {
                aura = aura,
                index = index,
                isOwn = IsAuraOwnedByPlayer(aura, ownHelpful),
                isDot = false,
            }
        end
    end

    for index = 1, 40 do
        local aura = GetAuraData(unit, index, "HARMFUL")
        if not aura then
            break
        end
        if #debuffs < debuffLimit then
            local isOwn = IsAuraOwnedByPlayer(aura, ownHarmful)
            debuffs[#debuffs + 1] = {
                aura = aura,
                index = index,
                isOwn = isOwn,
                isDot = isOwn and IsDamageOverTimeAura(aura) or false,
            }
        end
    end

    holder.BuffCount = #buffs
    holder.DebuffCount = #debuffs

    for i = 1, #holder.Buffs do
        local entry = buffs[i]
        local showTimer = entry and entry.isOwn and self.db.showOwnBuffTimers
        PopulateAuraButton(holder.Buffs[i], unit, entry, "HELPFUL", entry and entry.isOwn or false, showTimer or false)
    end

    for i = 1, #holder.Debuffs do
        local entry = debuffs[i]
        local showTimer = false
        if entry and entry.isOwn then
            if entry.isDot then
                showTimer = self.db.showOwnDotTimers
            else
                showTimer = self.db.showOwnDebuffTimers
            end
        end
        PopulateAuraButton(holder.Debuffs[i], unit, entry, "HARMFUL", entry and entry.isOwn or false, showTimer or false)
    end

    self:ApplyPartyAuraLayout(frame)
    if self.db and not self.db.locked then
        self:RefreshPartyGroupMover()
    end
end

function SUF:UpdateAllPartyAuras()
    if not self.UnitFrames then
        return
    end
    for i = 1, 4 do
        self:UpdatePartyAuras("party" .. i)
    end
end

function SUF:RefreshAllAuras()
    self:UpdateTargetAuras()
    self:UpdateAllPartyAuras()
end

function SUF:RefreshAuraMasks()
    if not self.UnitFrames then
        return
    end

    local target = self:GetUnitFrame("target")
    if target and target.TargetAuras then
        for _, collection in ipairs({ target.TargetAuras.MyDebuffs, target.TargetAuras.Buffs, target.TargetAuras.Debuffs }) do
            for i = 1, #collection do
                ApplyAuraMaskToButton(collection[i])
            end
        end
    end

    for partyIndex = 1, 4 do
        local frame = self:GetUnitFrame("party" .. partyIndex)
        if frame and frame.PartyAuras then
            for _, collection in ipairs({ frame.PartyAuras.Buffs, frame.PartyAuras.Debuffs }) do
                for i = 1, #collection do
                    ApplyAuraMaskToButton(collection[i])
                end
            end
        end
    end
end

local function ConfigureCastbarGradient(castbar, notInterruptible)
    local texture = castbar.Bar:GetStatusBarTexture()
    if notInterruptible then
        SetGradient(texture, COLORS.castNoInterruptBottom, COLORS.castNoInterruptTop)
    else
        SetGradient(texture, COLORS.castBottom, COLORS.castTop)
    end
end

function SUF:UpdateTargetCastbar()
    local frame = self:GetUnitFrame("target")
    if not frame or not frame.TargetCastbar or not self.db then
        return
    end

    local castbar = frame.TargetCastbar
    if not self.db.showTargetCastbar or not self.db.enableTarget or not UnitExists("target") then
        castbar:Hide()
        return
    end

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target")
    if name and startTime and endTime then
        castbar.isChannel = false
        castbar.startTime = startTime
        castbar.endTime = endTime
        castbar.NameText:SetText(name)
        ConfigureCastbarGradient(castbar, notInterruptible)
        castbar:Show()
        return
    end

    local channelName, channelText, channelTexture, channelStart, channelEnd, isTradeSkillChannel, channelNotInterruptible = UnitChannelInfo("target")
    if channelName and channelStart and channelEnd then
        castbar.isChannel = true
        castbar.startTime = channelStart
        castbar.endTime = channelEnd
        castbar.NameText:SetText(channelName)
        ConfigureCastbarGradient(castbar, channelNotInterruptible)
        castbar:Show()
        return
    end

    castbar:Hide()
end
