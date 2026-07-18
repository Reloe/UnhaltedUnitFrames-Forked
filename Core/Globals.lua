local _, UUF = ...
local oUF = UUF.oUF
UUFG = UUFG or {}
UUF.AURA_TEST_MODE = false
UUF.CASTBAR_TEST_MODE = false
UUF.BOSS_TEST_MODE = false
UUF.PARTY_TEST_MODE = false
UUF.RAID_TEST_MODE = false
UUF.BOSS_FRAMES = {}
UUF.MAX_BOSS_FRAMES = 5
UUF.PARTY_FRAMES = {}
UUF.MAX_PARTY_FRAMES = 4
UUF.RAID_FRAMES = {}
UUF.AUGMENTATION_RAID_FRAMES = {}
UUF.RAID_TEST_FRAMES = {}
UUF.RAID_HEADERS = {}
UUF.AUGMENTATION_RAID_FRAME_COUNT = 0
UUF.MAX_RAID_FRAMES = 40
UUF.MAX_RAID_GROUPS = 8
UUF.MAX_RAID_FRAMES_PER_GROUP = 5
local CooldownDurationFormatter = C_StringUtil.CreateNumericRuleFormatter()

UUF.LSM = LibStub("LibSharedMedia-3.0")
UUF.LDS = LibStub("LibDualSpec-1.0")
UUF.AG = LibStub("AceGUI-3.0")
UUF.LD = LibStub("LibDispel-1.0")
UUF.BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 0, right = 0, top = 0, bottom = 0} }
UUF.INFOBUTTON = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\InfoButton.png:16:16|t "
UUF.ADDON_NAME = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Title")
UUF.ADDON_VERSION = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Version")
UUF.ADDON_AUTHOR = C_AddOns.GetAddOnMetadata("UnhaltedUnitFrames", "Author")
UUF.ADDON_LOGO = "|TInterface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Logo:11:12|t"
UUF.PRETTY_ADDON_NAME = UUF.ADDON_LOGO .. " " .. UUF.ADDON_NAME

UUF.LSM:Register("statusbar", "Better Blizzard", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\BetterBlizzard.blp")
UUF.LSM:Register("statusbar", "Dragonflight", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Dragonflight.tga")
UUF.LSM:Register("statusbar", "Skyline", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Skyline.tga")
UUF.LSM:Register("statusbar", "Stripes", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Stripes.png")
UUF.LSM:Register("statusbar", "Thin Stripes", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ThinStripes.png")

UUF.LSM:Register("background", "Dragonflight", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Backgrounds\\Dragonflight_BG.tga")

UUF.LSM:Register("font", "Expressway", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\Expressway.ttf")
UUF.LSM:Register("font", "Avante", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\Avante.ttf")
UUF.LSM:Register("font", "Avantgarde (Book)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\Book.ttf")
UUF.LSM:Register("font", "Avantgarde (Book Oblique)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\BookOblique.ttf")
UUF.LSM:Register("font", "Avantgarde (Demi)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\Demi.ttf")
UUF.LSM:Register("font", "Avantgarde (Regular)", "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Fonts\\AvantGarde\\Regular.ttf")

UUF.StatusTextures = {
    Combat = {
        ["COMBAT0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat0.tga",
        ["COMBAT1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat1.tga",
        ["COMBAT2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat2.tga",
        ["COMBAT3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat3.tga",
        ["COMBAT4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat4.tga",
        ["COMBAT5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat5.tga",
        ["COMBAT6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat6.tga",
        ["COMBAT7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat7.tga",
        ["COMBAT8"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Combat\\Combat8.png",
    },
    Resting = {
        ["RESTING0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting0.tga",
        ["RESTING1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting1.tga",
        ["RESTING2"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting2.tga",
        ["RESTING3"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting3.tga",
        ["RESTING4"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting4.tga",
        ["RESTING5"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting5.tga",
        ["RESTING6"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting6.tga",
        ["RESTING7"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting7.tga",
        ["RESTING8"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Status\\Resting\\Resting8.png",
    },
}

UUF.ClassificationTextures = {
    ["CLASSIFICATION0"] = {
        ["elite"] = "nameplates-icon-elite-gold",
        ["rare"] = "nameplates-icon-elite-silver",
        ["rareelite"] = "nameplates-icon-elite-silver",
        ["worldboss"] = "nameplates-icon-elite-gold",
    },
    ["CLASSIFICATION1"] = {
        ["elite"] = "VignetteEvent-SuperTracked",
        ["rare"] = "VignetteEvent",
        ["rareelite"] = "VignetteKillElite-SuperTracked",
        ["worldboss"] = "vignettekillboss",
    },
    ["CLASSIFICATION2"] = {
        ["elite"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\Elite.png",
        ["rare"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\Rare.png",
        ["rareelite"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\RareElite.png",
        ["worldboss"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Classic\\WorldBoss.png",
    },
    ["CLASSIFICATION3"] = {
        ["elite"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\Elite.png",
        ["rare"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\Rare.png",
        ["rareelite"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\RareElite.png",
        ["worldboss"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Classification\\Minimalist\\WorldBoss.png",
    },
}

UUF.QuestTextures = {
    ["DEFAULT"] = "Interface\\TargetingFrame\\PortraitQuestBadge",
    ["QUEST0"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Quest\\Quest01.png",
    ["QUEST1"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Quest\\Quest02.png",
}

UUF.RoleTextures = {
    ["Blizzard"] = {
        ["TANK"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Blizzard\\Tank.tga",
        ["HEALER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Blizzard\\Healer.tga",
        ["DAMAGER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Blizzard\\DPS.tga",
    },
    ["Colour"] = {
        ["TANK"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Colour\\Tank.tga",
        ["HEALER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Colour\\Healer.tga",
        ["DAMAGER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Colour\\DPS.tga",
    },
    ["White"] = {
        ["TANK"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\White\\Tank.png",
        ["HEALER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\White\\Healer.png",
        ["DAMAGER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\White\\DPS.png",
    },
    ["ElvUI"] = {
        ["TANK"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\ElvUI\\Tank.tga",
        ["HEALER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\ElvUI\\Healer.tga",
        ["DAMAGER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\ElvUI\\DPS.tga",
    },
	["Square"] = {
		["TANK"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Square\\Tank.png",
		["HEALER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Square\\Healer.png",
		["DAMAGER"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Role\\Square\\DPS.png",
	},
}

UUF.ReadyCheckTextures = {
	["White"] = {
		["READY"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\Ready.png",
		["NOTREADY"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\NotReady.png",
		["WAITING"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\White\\Pending.png",
	},
    ["HiRes"] = {
		["READY"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\HiRes\\Ready.png",
		["NOTREADY"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\HiRes\\NotReady.png",
		["WAITING"] = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\ReadyCheck\\HiRes\\Pending.png",
	},
}

UUF.InterruptSpellIDs = {
	["DEATHKNIGHT"] = {47528},
	["DEMONHUNTER"] = {183752},
	["DRUID"] = {106839, 78675, 38675},
	["EVOKER"] = {351338},
	["HUNTER"] = {187707, 147362},
	["MAGE"] = {2139},
	["MONK"] = {116705},
	["PALADIN"] = {96231, 31935},
	["PRIEST"] = {15487},
	["ROGUE"] = {1766},
	["SHAMAN"] = {57994},
	["WARLOCK"] = {19647, 132409, 89766, 119910, 1276467},
	["WARRIOR"] = {6552},
}

function UUF:PrettyPrint(MSG) print(UUF.ADDON_NAME .. ":|r " .. MSG) end

function UUF:GetInterruptSpellID()
	local playerInterrupt = UUF.InterruptSpellIDs[UnitClassBase("player")]
	if not playerInterrupt then return end
	for i = 1, #playerInterrupt do
		local spellID = playerInterrupt[i]
		if C_SpellBook.IsSpellKnownOrInSpellBook then
			if C_SpellBook.IsSpellKnownOrInSpellBook(spellID) or C_SpellBook.IsSpellKnownOrInSpellBook(spellID, Enum.SpellBookSpellBank.Pet) then return spellID end
		elseif IsSpellKnown and IsSpellKnown(spellID) then
			return spellID
		end
	end
end

function UUF:IsInterruptOnCooldown()
	local spellID = UUF:GetInterruptSpellID()
	if not spellID then return false end
	if C_Spell.GetSpellCooldown then
		local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
		return cooldownInfo and cooldownInfo.isEnabled and cooldownInfo.isActive and not cooldownInfo.isOnGCD or false
	end
	return false
end

function UUF:FetchFrameName(unit)
    local UnitToFrame = {
        ["player"] = "UUF_Player",
        ["target"] = "UUF_Target",
        ["targettarget"] = "UUF_TargetTarget",
        ["focus"] = "UUF_Focus",
        ["focustarget"] = "UUF_FocusTarget",
        ["pet"] = "UUF_Pet",
        ["boss"] = "UUF_Boss",
        ["party"] = "UUF_Party",
        ["partyplayer"] = "UUF_PartyPlayer",
        ["raid"] = "UUF_Raid",
    }
    if not unit then return end
    if unit:match("^boss(%d+)$") then local unitID = unit:match("^boss(%d+)$") return "UUF_Boss" .. unitID end
    if unit:match("^party(%d+)$") then local unitID = unit:match("^party(%d+)$") return "UUF_Party" .. unitID end
    if unit:match("^raid(%d+)$") then local unitID = unit:match("^raid(%d+)$") return "UUF_Raid" .. unitID end
    return UnitToFrame[unit]
end

function UUF:ResolveLSM()
    local LSM = UUF.LSM
    local General = UUF.db.profile.General
    General.Fonts.Raid = General.Fonts.Raid or {}
    General.Fonts.Raid.Font = General.Fonts.Raid.Font or General.Fonts.Font
    General.Fonts.Raid.FontFlag = General.Fonts.Raid.FontFlag or General.Fonts.FontFlag
    General.Fonts.Raid.Shadow = General.Fonts.Raid.Shadow or {}
    General.Fonts.Raid.Shadow.Enabled = General.Fonts.Raid.Shadow.Enabled == nil and General.Fonts.Shadow.Enabled or General.Fonts.Raid.Shadow.Enabled
    General.Fonts.Raid.Shadow.Colour = General.Fonts.Raid.Shadow.Colour or {unpack(General.Fonts.Shadow.Colour)}
    General.Fonts.Raid.Shadow.XPos = General.Fonts.Raid.Shadow.XPos == nil and General.Fonts.Shadow.XPos or General.Fonts.Raid.Shadow.XPos
    General.Fonts.Raid.Shadow.YPos = General.Fonts.Raid.Shadow.YPos == nil and General.Fonts.Shadow.YPos or General.Fonts.Raid.Shadow.YPos
    UUF.Media = UUF.Media or {}
    UUF.Media.Font = LSM:Fetch("font", General.Fonts.Font) or STANDARD_TEXT_FONT
    UUF.Media.RaidFont = LSM:Fetch("font", General.Fonts.Raid and General.Fonts.Raid.Font or General.Fonts.Font) or UUF.Media.Font
    UUF.Media.Foreground = LSM:Fetch("statusbar", General.Textures.Foreground) or "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
    UUF.Media.Background = LSM:Fetch("statusbar", General.Textures.Background) or "Interface\\Buttons\\WHITE8X8"
    UUF.Media.RaidForeground = LSM:Fetch("statusbar", General.Textures.RaidForeground or General.Textures.Foreground) or UUF.Media.Foreground
    UUF.Media.RaidBackground = LSM:Fetch("statusbar", General.Textures.RaidBackground or General.Textures.Background) or UUF.Media.Background
end

function UUF:GetStatusBarTexture(unitFrame, unit, textureType)
    local configuredUnit = unitFrame and unitFrame.isAugmentationRaidFrame and "augmentation" or unitFrame and unitFrame.UUFConfiguredUnit or unit
    local normalizedUnit = configuredUnit and UUF:GetNormalizedUnit(configuredUnit)
    local useGroupTextures = normalizedUnit == "party" or normalizedUnit == "raid" or normalizedUnit == "augmentation"
    if textureType == "Background" then
        return useGroupTextures and UUF.Media.RaidBackground or UUF.Media.Background
    end
    return useGroupTextures and UUF.Media.RaidForeground or UUF.Media.Foreground
end

function UUF:GetFontSettings(unitFrame, unit)
    local FontsDB = UUF.db.profile.General.Fonts
    local configuredUnit = unitFrame and unitFrame.isAugmentationRaidFrame and "augmentation" or unitFrame and unitFrame.UUFConfiguredUnit or unit
    local normalizedUnit = configuredUnit and UUF:GetNormalizedUnit(configuredUnit)
    if normalizedUnit == "party" or normalizedUnit == "raid" or normalizedUnit == "augmentation" then
        return FontsDB.Raid or FontsDB
    end
    return FontsDB
end

function UUF:GetFontMedia(unitFrame, unit)
    local configuredUnit = unitFrame and unitFrame.isAugmentationRaidFrame and "augmentation" or unitFrame and unitFrame.UUFConfiguredUnit or unit
    local normalizedUnit = configuredUnit and UUF:GetNormalizedUnit(configuredUnit)
    if normalizedUnit == "party" or normalizedUnit == "raid" or normalizedUnit == "augmentation" then
        return UUF.Media.RaidFont or UUF.Media.Font
    end
    return UUF.Media.Font
end

function UUF:GetCooldownDurationComponents(displayStyle, minValue)
    if displayStyle == "clock" then
        if minValue >= 86400 then
            return {{div = 86400}, {div = 3600, mod = 24}}
        elseif minValue >= 3600 then
            return {{div = 3600}, {div = 60, mod = 60}}
        end
        return {{div = 60}, {mod = 60}}
    elseif displayStyle == "minutes" then
        return {{div = 60}}
    elseif displayStyle == "hours" then
        return {{div = 3600}}
    elseif displayStyle == "days" then
        return {{div = 86400}}
    end
end

function UUF:ApplyCooldownText(icon, textRegion, unit, unitFrame)
    if not icon then return end
    local CooldownTextDB = UUF.db.profile.General.CooldownText
    for _, breakpoint in ipairs(CooldownTextDB.CooldownBreakpoints) do
        if breakpoint.displayStyle == "secondsOnly" then breakpoint.min = 1 end
    end
    if icon.SetCountdownFormatter then
        CooldownDurationFormatter:SetBreakpoints(CooldownTextDB.CooldownBreakpoints)
        icon:SetCountdownFormatter(CooldownDurationFormatter)
    end
	if CooldownTextDB.Advanced and unit then CooldownTextDB = UUF:GetUnitDB(unitFrame, unit).Auras.AuraDuration end
    if not textRegion then
        C_Timer.After(0.01, function()
            for _, region in ipairs({icon:GetRegions()}) do
                if region:GetObjectType() == "FontString" then
					UUF:ApplyCooldownText(icon, region, unit, unitFrame)
                    return
                end
            end
        end)
        return
    end

    local FontsDB = UUF:GetFontSettings(unitFrame, unit)
    local fontMedia = UUF:GetFontMedia(unitFrame, unit)
    if CooldownTextDB.ScaleByIconSize then
        local iconWidth = icon:GetWidth()
        local scaleFactor = iconWidth > 0 and iconWidth / 36 or 1
        local fontSize = CooldownTextDB.FontSize * scaleFactor
        if fontSize < 1 then fontSize = 12 end
        textRegion:SetFont(fontMedia, fontSize, FontsDB.FontFlag)
    else
        textRegion:SetFont(fontMedia, CooldownTextDB.FontSize, FontsDB.FontFlag)
    end
    textRegion:ClearAllPoints()
    textRegion:SetPoint(CooldownTextDB.Layout[1], icon, CooldownTextDB.Layout[2], CooldownTextDB.Layout[3], CooldownTextDB.Layout[4])
    if FontsDB.Shadow.Enabled then
        textRegion:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
        textRegion:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
    else
        textRegion:SetShadowColor(0, 0, 0, 0)
        textRegion:SetShadowOffset(0, 0)
    end
end

function UUF:GetCooldownDurationFormatter()
	CooldownDurationFormatter:SetBreakpoints(UUF.db.profile.General.CooldownText.CooldownBreakpoints)
	return CooldownDurationFormatter
end

function UUF:Capitalize(STR)
    return "|cFF8080FF" .. (STR:gsub("^%l", string.upper)) .. "|r"
end

function UUF:GetPixelPerfectScale()
    local _, screenHeight = GetPhysicalScreenSize()
    local pixelSize = 768 / screenHeight
    return pixelSize
end

local function SetupSlashCommands()
    SLASH_UUF1 = "/uuf"
    SLASH_UUF2 = "/unhaltedunitframes"
    SLASH_UUF3 = "/uf"
    SlashCmdList["UUF"] = function() UUF:CreateGUI() end
    if UUF.db.global.DisplayLoginMessage then UUF:PrettyPrint("'|cFF8080FF/uuf|r' for in-game configuration.") end

    -- RL command
    SLASH_UUFRELOAD1 = "/rl"
    SlashCmdList["UUFRELOAD"] = function() C_UI.Reload() end
end

function UUF:SetUIScale()
    local GeneralDB = UUF.db.profile.General
    if GeneralDB.UIScale.Enabled then
        UIParent:SetScale(GeneralDB.UIScale.Scale or 0.5333333333333)
    else
        return
    end
end

function UUF:LoadCustomColours()
    local General = UUF.db.profile.General
    local DefaultClassColours = UUF:GetDefaultDB().profile.General.Colours.Class

    General.Colours.Class = General.Colours.Class or {}
    for classToken, defaultColor in pairs(DefaultClassColours) do
        General.Colours.Class[classToken] = General.Colours.Class[classToken] or {defaultColor[1], defaultColor[2], defaultColor[3]}
    end

    General.Colours.RaidClass = General.Colours.RaidClass or {}
    for classToken, defaultColor in pairs(DefaultClassColours) do
        local fallbackColor = General.Colours.Class[classToken] or defaultColor
        General.Colours.RaidClass[classToken] = General.Colours.RaidClass[classToken] or {fallbackColor[1], fallbackColor[2], fallbackColor[3]}
    end

    -- Map power type enums to their string names
    local PowerTypesToString = {
        [Enum.PowerType.Mana or 0] = "MANA",
        [Enum.PowerType.Rage or 1] = "RAGE",
        [Enum.PowerType.Focus or 2] = "FOCUS",
        [Enum.PowerType.Energy or 3] = "ENERGY",
        [Enum.PowerType.ComboPoints or 4] = "COMBO_POINTS",
        [Enum.PowerType.Runes or 5] = "RUNES",
        [Enum.PowerType.RunicPower or 6] = "RUNIC_POWER",
        [Enum.PowerType.SoulShards or 7] = "SOUL_SHARDS",
        [Enum.PowerType.LunarPower or 8] = "LUNAR_POWER",
        [Enum.PowerType.HolyPower or 9] = "HOLY_POWER",
        [Enum.PowerType.Alternate or 10] = "ALTERNATE",
        [Enum.PowerType.Maelstrom or 11] = "MAELSTROM",
        [Enum.PowerType.Chi or 12] = "CHI",
        [Enum.PowerType.Insanity or 13] = "INSANITY",
        [Enum.PowerType.ArcaneCharges or 16] = "ARCANE_CHARGES",
        [Enum.PowerType.Fury or 17] = "FURY",
        [Enum.PowerType.Pain or 18] = "PAIN",
        [Enum.PowerType.Essence or 19] = "ESSENCE",
    }

    for powerType, color in pairs(General.Colours.Power) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = oUF:CreateColor(color[1], color[2], color[3])
            oUF.colors.power[powerType] = oUF.colors.power[powerTypeString]
        end
    end

    for powerType, color in pairs(General.Colours.SecondaryPower) do
        local powerTypeString = PowerTypesToString[powerType]
        if powerTypeString then
            oUF.colors.power[powerTypeString] = oUF:CreateColor(color[1], color[2], color[3])
            oUF.colors.power[powerType] = oUF.colors.power[powerTypeString]
        end
    end

    for reaction, color in pairs(General.Colours.Reaction) do
        oUF.colors.reaction[reaction] = oUF:CreateColor(color[1], color[2], color[3])
    end

    for classToken, defaultColor in pairs(RAID_CLASS_COLORS or {}) do
        local color = General.Colours.Class and General.Colours.Class[classToken]
        local r = color and color[1] or defaultColor.r
        local g = color and color[2] or defaultColor.g
        local b = color and color[3] or defaultColor.b
        oUF.colors.class[classToken] = oUF:CreateColor(r, g, b)
    end

    local DefaultStatusColours = UUF:GetDefaultDB().profile.General.Colours.Status
    local StatusColours = General.Colours.Status or DefaultStatusColours
    local tappedColor = StatusColours.Tapped or DefaultStatusColours.Tapped
    local disconnectedColor = StatusColours.Disconnected or DefaultStatusColours.Disconnected
    local deadBackdropColor = StatusColours.DeadBackdrop or DefaultStatusColours.DeadBackdrop
    oUF.colors.tapped = oUF:CreateColor(tappedColor[1], tappedColor[2], tappedColor[3])
    oUF.colors.disconnected = oUF:CreateColor(disconnectedColor[1], disconnectedColor[2], disconnectedColor[3])
    oUF.colors.deadBackdrop = oUF:CreateColor(deadBackdropColor[1], deadBackdropColor[2], deadBackdropColor[3])

    local DefaultThreatColours = UUF:GetDefaultDB().profile.General.Colours.Threat
    local ThreatColours = General.Colours.Threat or DefaultThreatColours
    for threatStatus, defaultColor in pairs(DefaultThreatColours) do
        local color = ThreatColours[threatStatus] or defaultColor
        oUF.colors.threat[threatStatus] = oUF:CreateColor(color[1], color[2], color[3])
    end

    if General.Colours.Dispel then
        local dispelMap = {
            Magic = oUF.Enum.DispelType.Magic,
            Curse = oUF.Enum.DispelType.Curse,
            Disease = oUF.Enum.DispelType.Disease,
            Poison = oUF.Enum.DispelType.Poison,
            Bleed = oUF.Enum.DispelType.Bleed,
        }
        for dispelType, index in pairs(dispelMap) do
            local color = General.Colours.Dispel[dispelType]
            if color then
                oUF.colors.dispel[index] = oUF:CreateColor(color[1], color[2], color[3])
            end
        end
	end

    for _, obj in next, oUF.objects do
        if obj.UpdateTags then
            obj:UpdateTags()
        end
    end
end

function UUF:UsesRaidClassColours(unitFrame, unit)
    local configuredUnit = unitFrame and unitFrame.isAugmentationRaidFrame and "augmentation" or unitFrame and unitFrame.UUFConfiguredUnit or unit
    local normalizedUnit = configuredUnit and UUF:GetNormalizedUnit(configuredUnit)
    return normalizedUnit == "party" or normalizedUnit == "raid" or normalizedUnit == "augmentation"
end

function UUF:GetConfiguredClassColour(classToken, unitFrame, unit)
    if not classToken then return end
    local ColourDB = UUF.db.profile.General.Colours
    local classColours = UUF:UsesRaidClassColours(unitFrame, unit) and ColourDB.RaidClass or ColourDB.Class
    local color = classColours and classColours[classToken]
    if color then
        return color[1], color[2], color[3]
    end
    local defaultColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    if defaultColor then
        return defaultColor.r, defaultColor.g, defaultColor.b
    end
end

local function AddAnchorsToBCDM()
    if not C_AddOns.IsAddOnLoaded("BetterCooldownManager") then return end
    if select(4, GetBuildInfo()) >= 121000 then return end
    local UUF_Anchors = {
        ["UUF_Player"] = "|cFF8080FFUnhalted|rUnitFrames: Player Frame",
        ["UUF_Target"] = "|cFF8080FFUnhalted|rUnitFrames: Target Frame",
        ["UUF_Pet"] = "|cFF8080FFUnhalted|rUnitFrames: Pet Frame",
    }
    if BCDMG then
        BCDMG:AddAnchors("UnhaltedUnitFrames", {"Utility", "CustomViewer", "Custom", "AdditionalCustom", "Item", "ItemSpell", "Trinket"}, UUF_Anchors)
    end
end

function UUF:Init()
    SetupSlashCommands()
    UUF:SetUIScale()
    UUF:ResolveLSM()
    UUF:LoadCustomColours()
    UUF:SetTagUpdateInterval()
    AddAnchorsToBCDM()
end

function UUF:CopyTable(originalTable, destinationTable)
    for key, value in pairs(originalTable) do
        if type(value) == "table" then
            destinationTable[key] = destinationTable[key] or {}
            UUF:CopyTable(value, destinationTable[key])
        else
            destinationTable[key] = value
        end
    end
end

function UUF:SetJustification(anchorFrom)
    if anchorFrom == "TOPLEFT" or anchorFrom == "LEFT" or anchorFrom == "BOTTOMLEFT" then
        return "LEFT"
    elseif anchorFrom == "TOPRIGHT" or anchorFrom == "RIGHT" or anchorFrom == "BOTTOMRIGHT" then
        return "RIGHT"
    else
        return "CENTER"
    end
end

function UUF:GetUnitColour(unit, unitFrame)
    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
        local _, class = UnitClass(unit)
        local r, g, b = UUF:GetConfiguredClassColour(class, unitFrame, unit)
        if r then return r, g, b end
    end
    local reaction = UnitReaction(unit, "player")
    if reaction and UUF.db.profile.General.Colours.Reaction[reaction] then
        local r, g, b = unpack(UUF.db.profile.General.Colours.Reaction[reaction])
        return r, g, b
    end
    return 1, 1, 1
end

function UUF:GetClassColour(unitFrame)
    local _, class = UnitClass(unitFrame.unit)
    local r, g, b = UUF:GetConfiguredClassColour(class, unitFrame, unitFrame.unit)
    if r then return {r, g, b, 1} end
end

function UUF:GetReactionColour(reaction)
    local reactionColour = oUF.colors.reaction[reaction]
    if reactionColour then
        return {reactionColour.r, reactionColour.g, reactionColour.b, 1}
    end
end

function UUF:GetNormalizedUnit(unit)
    local normalizedUnit = unit == "vehicle" and "player" or unit == "partyplayer" and "party" or unit:match("^boss%d+$") and "boss" or unit:match("^party%d+$") and "party" or unit:match("^raid%d+$") and "raid" or unit
    return normalizedUnit
end

function UUF:GetUnitDB(unitFrame, unit, units)
	units = units or UUF.db.profile.Units
	local configuredUnit = unitFrame and unitFrame.isAugmentationRaidFrame and "augmentation" or unitFrame and unitFrame.UUFConfiguredUnit or unit
	local normalizedUnit = UUF:GetNormalizedUnit(configuredUnit)
	return normalizedUnit == "augmentation" and units.raid.augmentation or units[normalizedUnit]
end

function UUF:GetFrameAnchorParent(unitFrame, unit)
	local UnitDB = UUF:GetUnitDB(unitFrame, unit)
	local FrameDB = UnitDB and UnitDB.Frame
	local anchorParentName = FrameDB and FrameDB.AnchorParent
	if not anchorParentName or anchorParentName == "" then return UIParent end
	local anchorParent = _G[anchorParentName] or _G[UUF.SCMAnchors and UUF.SCMAnchors[anchorParentName] or ""]
	if not anchorParent or anchorParent == unitFrame then return UIParent end
	return anchorParent
end

function UUF:PositionUnitFrame(unitFrame, unit)
	if not unitFrame then return end
	local FrameDB = UUF:GetUnitDB(unitFrame, unit).Frame
	unitFrame:ClearAllPoints()
	unitFrame:SetPoint(FrameDB.Layout[1], UUF:GetFrameAnchorParent(unitFrame, unit), FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
	unitFrame:SetSize(FrameDB.Width, FrameDB.Height)
end

function UUF:ForEachUnitDB(callback)
	for unit, unitDB in pairs(UUF.db.profile.Units) do callback(unitDB, unit) end
	callback(UUF.db.profile.Units.raid.augmentation, "augmentation")
end

function UUF:IsAugmentationEvoker()
	if UnitClassBase("player") ~= "EVOKER" then return false end
	local specializationIndex = C_SpecializationInfo.GetSpecialization()
	return specializationIndex and C_SpecializationInfo.GetSpecializationInfo(specializationIndex) == 1473 or false
end

function UUF:RequiresAlternativePowerBar()
    local SpecsNeedingAltPower = {
        PRIEST = { 258 },           -- Shadow
        MAGE   = { 62, 63, 64 },        -- Fire, Frost
        PALADIN = { 70 },           -- Ret
        SHAMAN  = { 262, 263 },     -- Ele, Enh
        EVOKER  = { 1467, 1473 },   -- Dev, Aug
        DRUID = { 102, 103, 104 },    -- Balance, Feral, Guardian
    }
    local class = select(2, UnitClass("player"))
    local specIndex = C_SpecializationInfo.GetSpecialization()
    if not specIndex then return false end
    local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    local classSpecs = SpecsNeedingAltPower[class]
    if not classSpecs then return false end
    for _, requiredSpec in ipairs(classSpecs) do if specID == requiredSpec then return true end end
    return false
end

UUF.LayoutConfig = {
    TOPLEFT     = { anchor="TOPLEFT",   offsetMultiplier=0   },
    TOP         = { anchor="TOP",       offsetMultiplier=0   },
    TOPRIGHT    = { anchor="TOPRIGHT",  offsetMultiplier=0   },
    BOTTOMLEFT  = { anchor="TOPLEFT",   offsetMultiplier=1   },
    BOTTOM      = { anchor="TOP",       offsetMultiplier=1   },
    BOTTOMRIGHT = { anchor="TOPRIGHT",  offsetMultiplier=1   },
    CENTER      = { anchor="CENTER",    offsetMultiplier=0.5, isCenter=true },
    LEFT        = { anchor="LEFT",      offsetMultiplier=0.5, isCenter=true },
    RIGHT       = { anchor="RIGHT",     offsetMultiplier=0.5, isCenter=true },
}

function UUF:SetTagUpdateInterval()
    oUF.Tags:SetEventUpdateTimer(UUF.TAG_UPDATE_INTERVAL)
end

function UUF:OpenURL(title, urlText)
    StaticPopupDialogs["UUF_URL_POPUP"] = {
        text = title or "",
        button1 = CLOSE,
        hasEditBox = true,
        editBoxWidth = 300,
        OnShow = function(self)
            self.EditBox:SetText(urlText or "")
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        OnAccept = function(self) end,
        EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    local urlDialog = StaticPopup_Show("UUF_URL_POPUP")
    if urlDialog then
        urlDialog:SetFrameStrata("TOOLTIP")
    end
    return urlDialog
end

function UUF:CreatePrompt(title, text, onAccept, onCancel, acceptText, cancelText)
    StaticPopupDialogs["UUF_PROMPT_DIALOG"] = {
        text = text or "",
        button1 = acceptText or ACCEPT,
        button2 = cancelText or CANCEL,
        OnAccept = function(self, data)
            if data and data.onAccept then
                data.onAccept()
            end
        end,
        OnCancel = function(self, data)
            if data and data.onCancel then
                data.onCancel()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        showAlert = true,
    }
    local promptDialog = StaticPopup_Show("UUF_PROMPT_DIALOG", title, text)
    if promptDialog then
        promptDialog.data = { onAccept = onAccept, onCancel = onCancel }
        promptDialog:SetFrameStrata("TOOLTIP")
    end
    return promptDialog
end

function UUFG:UpdateAllTags()
    for _, obj in next, oUF.objects do
        if obj.UpdateTags then
            obj:UpdateTags()
        end
    end
end

-- Thanks Details / Plater for this.
function UUF:CleanTruncateUTF8String(text)
    local DetailsFramework = _G.DF
    if DetailsFramework and DetailsFramework.CleanTruncateUTF8String then
        return DetailsFramework:CleanTruncateUTF8String(text)
    end
    return text
end

function UUF:IsSecretValue(value)
    return issecretvalue and issecretvalue(value)
end

function UUF:GetSecondaryPowerType()
    local class = select(2, UnitClass("player"))
    local spec = C_SpecializationInfo.GetSpecialization()

    if class == "ROGUE" then
        return Enum.PowerType.ComboPoints
    elseif class == "DRUID" then
        local form = GetShapeshiftFormID()
        if form == 1 then return Enum.PowerType.ComboPoints end
    elseif class == "PALADIN" then
        return Enum.PowerType.HolyPower
    elseif class == "WARLOCK" then
        return Enum.PowerType.SoulShards
    elseif class == "MAGE" then
        if spec == 1 then return Enum.PowerType.ArcaneCharges end
    elseif class == "MONK" then
        if spec == 3 then return Enum.PowerType.Chi end
    elseif class == "EVOKER" then
        return Enum.PowerType.Essence
    end

    return nil
end

function UUF:HasActiveSecondaryPowerBar(unitFrame, unit)
	local SecondaryPowerBarDB = UUF:GetUnitDB(unitFrame, unit).SecondaryPowerBar
    return SecondaryPowerBarDB and SecondaryPowerBarDB.Enabled and (unitFrame.Runes or unitFrame.ClassPower)
end

local function NormalizeBarPosition(value, fallback)
    if value == "TOP" or value == "BOTTOM" then
        return value
    end
    return fallback
end

function UUF:GetConfiguredPowerBarPosition(unit, unitFrame)
	local PowerBarDB = UUF:GetUnitDB(unitFrame, unit).PowerBar
    if not PowerBarDB then return "BOTTOM" end
    if PowerBarDB.Position then
        return NormalizeBarPosition(PowerBarDB.Position, "BOTTOM")
    end
    if PowerBarDB.SwapPositionWithSecondary then
        return "TOP"
    end
    return "BOTTOM"
end

function UUF:GetConfiguredSecondaryPowerBarPosition(unit, unitFrame)
	local UnitDB = UUF:GetUnitDB(unitFrame, unit)
    local SecondaryPowerBarDB = UnitDB.SecondaryPowerBar
    if not SecondaryPowerBarDB then return "TOP" end
    if SecondaryPowerBarDB.Position then
        return NormalizeBarPosition(SecondaryPowerBarDB.Position, "TOP")
    end
    if UnitDB.PowerBar and UnitDB.PowerBar.SwapPositionWithSecondary then
        return "BOTTOM"
    end
    return "TOP"
end

function UUF:GetSecondaryPowerBarStackOffset(unitFrame, unit)
    if not UUF:HasActiveSecondaryPowerBar(unitFrame, unit) then return 0 end

	local PowerBarDB = UUF:GetUnitDB(unitFrame, unit).PowerBar
    if not (PowerBarDB and PowerBarDB.Enabled and unitFrame.Power) then
        return 0
    end

	if UUF:GetConfiguredPowerBarPosition(unit, unitFrame) ~= UUF:GetConfiguredSecondaryPowerBarPosition(unit, unitFrame) then
        return 0
    end

    return PowerBarDB.Height + 1
end

function UUF:UpdateHealthBarLayout(unitFrame, unit)
	local PowerBarDB = UUF:GetUnitDB(unitFrame, unit).PowerBar
	local SecondaryPowerBarDB = UUF:GetUnitDB(unitFrame, unit).SecondaryPowerBar

    local topDepth = 0
    local bottomDepth = 0

    local hasPrimaryPower = PowerBarDB and PowerBarDB.Enabled and unitFrame.Power
    local hasSecondaryPower = UUF:HasActiveSecondaryPowerBar(unitFrame, unit)

    if hasPrimaryPower then
		if UUF:GetConfiguredPowerBarPosition(unit, unitFrame) == "TOP" then
            topDepth = topDepth + PowerBarDB.Height + 1
        else
            bottomDepth = bottomDepth + PowerBarDB.Height + 1
        end
    end

    if hasSecondaryPower then
		if UUF:GetConfiguredSecondaryPowerBarPosition(unit, unitFrame) == "TOP" then
            topDepth = topDepth + SecondaryPowerBarDB.Height + 1
        else
            bottomDepth = bottomDepth + SecondaryPowerBarDB.Height + 1
        end
    end

    local topOffset = -1 - topDepth
    local bottomOffset = 1 + bottomDepth

    unitFrame.HealthBackground:ClearAllPoints()
    unitFrame.HealthBackground:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, topOffset)
    unitFrame.HealthBackground:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, bottomOffset)

    unitFrame.Health:ClearAllPoints()
    unitFrame.Health:SetPoint("TOPLEFT", unitFrame.Container, "TOPLEFT", 1, topOffset)
    unitFrame.Health:SetPoint("BOTTOMRIGHT", unitFrame.Container, "BOTTOMRIGHT", -1, bottomOffset)
end


UUF.MAX_AURA_CONTAINERS = 10

function UUF:GetAuraContainerKeys(AurasDB)
	local containerKeys = {}
	for containerKey, ContainerDB in pairs(AurasDB and AurasDB.Containers or {}) do
		if type(containerKey) == "string" and type(ContainerDB) == "table" then containerKeys[#containerKeys + 1] = containerKey end
	end
	table.sort(containerKeys, function(firstKey, secondKey)
		local firstIndex = tonumber(firstKey:match("^Container #(%d+)$"))
		local secondIndex = tonumber(secondKey:match("^Container #(%d+)$"))
		if firstIndex and secondIndex then return firstIndex < secondIndex end
		if firstIndex or secondIndex then return firstIndex ~= nil end
		local firstLower, secondLower = firstKey:lower(), secondKey:lower()
		return firstLower == secondLower and firstKey < secondKey or firstLower < secondLower
	end)
	return containerKeys
end

UUF.AURA_FILTERS = {
	{Key = "Player", Source = "PLAYER", Group = "Player (You)", Title = "All", Desc = "Only auras cast by the player, their pet, or their vehicle."},
	{Key = "RaidPlayer", Token = "RAID", Source = "PLAYER", Group = "Player (You)", Title = "Raid", Desc = "Helpful auras the player can apply and harmful auras the player can dispel."},
	{Key = "RaidInCombatPlayer", Token = "RAID_IN_COMBAT", Source = "PLAYER", Group = "Player (You)", Title = "Raid in Combat", Desc = "Auras flagged to show on raid frames while in combat."},
	{Key = "RaidPlayerDispellablePlayer", Token = "RAID_PLAYER_DISPELLABLE", Source = "PLAYER", Group = "Player (You)", Title = "Raid Dispellable", Desc = "Auras someone in the player's raid can dispel, including helpful enrages on enemies."},
	{Key = "DispellablePlayer", Token = "DISPELLABLE", Source = "PLAYER", Group = "Player (You)", Title = "Dispellable", Desc = "Auras that are dispellable, whether or not the player's raid can dispel them."},
	{Key = "ImportantPlayer", Token = "IMPORTANT", Source = "PLAYER", Group = "Player (You)", Title = "Important", Desc = "Auras flagged as important, including helpful auras shown on enemy nameplates even when they are not stealable."},
	{Key = "CrowdControlPlayer", Token = "CROWD_CONTROL", Source = "PLAYER", Group = "Player (You)", Title = "Crowd Control", Desc = "Auras with a crowd-control effect, such as a stun or fear."},
	{Key = "BigDefensivePlayer", Token = "BIG_DEFENSIVE", Source = "PLAYER", Group = "Player (You)", Title = "Big Defensive", TreeTitle = "Big Defensives", Desc = "Auras categorized as big defensives."},
	{Key = "ExternalDefensivePlayer", Token = "EXTERNAL_DEFENSIVE", Source = "PLAYER", Group = "Player (You)", Title = "External Defensive", TreeTitle = "External Defensives", Desc = "Auras categorized as external defensives."},
	{Key = "CancelablePlayer", Token = "CANCELABLE", Source = "PLAYER", Group = "Player (You)", Title = "Cancelable", Desc = "Auras the player can cancel."},
	{Key = "NotCancelablePlayer", Token = "!CANCELABLE", Source = "PLAYER", Group = "Player (You)", Title = "Not Cancelable", Desc = "Auras the player cannot cancel."},
	{Key = "Others", Source = "!PLAYER", Group = "Others (Not You)", Title = "All", Desc = "Only auras not cast by the player, their pet, or their vehicle."},
	{Key = "Raid", Token = "RAID", Source = "!PLAYER", Group = "Others (Not You)", Title = "Raid", Desc = "Helpful auras the player can apply and harmful auras the player can dispel."},
	{Key = "RaidInCombat", Token = "RAID_IN_COMBAT", Source = "!PLAYER", Group = "Others (Not You)", Title = "Raid in Combat", Desc = "Auras flagged to show on raid frames while in combat."},
	{Key = "RaidPlayerDispellableOthers", Token = "RAID_PLAYER_DISPELLABLE", Source = "!PLAYER", Group = "Others (Not You)", Title = "Raid Dispellable", Desc = "Auras someone in the player's raid can dispel, including helpful enrages on enemies."},
	{Key = "Dispellable", Token = "DISPELLABLE", Source = "!PLAYER", Group = "Others (Not You)", Title = "Dispellable", Desc = "Auras that are dispellable, whether or not the player's raid can dispel them."},
	{Key = "Important", Token = "IMPORTANT", Source = "!PLAYER", Group = "Others (Not You)", Title = "Important", Desc = "Auras flagged as important, including helpful auras shown on enemy nameplates even when they are not stealable."},
	{Key = "CrowdControl", Token = "CROWD_CONTROL", Source = "!PLAYER", Group = "Others (Not You)", Title = "Crowd Control", Desc = "Auras with a crowd-control effect, such as a stun or fear."},
	{Key = "BigDefensive", Token = "BIG_DEFENSIVE", Source = "!PLAYER", Group = "Others (Not You)", Title = "Big Defensive", TreeTitle = "Big Defensives", Desc = "Auras categorized as big defensives."},
	{Key = "ExternalDefensive", Token = "EXTERNAL_DEFENSIVE", Source = "!PLAYER", Group = "Others (Not You)", Title = "External Defensive", TreeTitle = "External Defensives", Desc = "Auras categorized as external defensives."},
	{Key = "Cancelable", Token = "CANCELABLE", Source = "!PLAYER", Group = "Others (Not You)", Title = "Cancelable", Desc = "Auras the player can cancel."},
	{Key = "NotCancelable", Token = "!CANCELABLE", Source = "!PLAYER", Group = "Others (Not You)", Title = "Not Cancelable", Desc = "Auras the player cannot cancel."},
}

UUF.SCMAnchors = {
    ["Player"] = "UUF_Player",
    ["Target"] = "UUF_Target",
    ["Pet"] = "UUF_Pet",
    ["Focus"] = "UUF_Focus",
    ["Focus Target"] = "UUF_FocusTarget",
    ["Target of Target"] = "UUF_TargetTarget",
}

function UUF:RefreshProfiles()
	UUF:ResolveLSM()
	UUF:LoadCustomColours()
	UUF:UpdateAllUnitFrames()
	UUF:ForEachUnitDB(function(_, unit) UUF:UpdateUnitTags(unit) end)
end
