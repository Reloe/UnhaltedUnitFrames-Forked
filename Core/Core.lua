local _, UUF = ...
local UnhaltedUnitFrames = LibStub("AceAddon-3.0"):NewAddon("UnhaltedUnitFrames")

function UnhaltedUnitFrames:OnInitialize()
    UUF.db = LibStub("AceDB-3.0"):New("UUFDB", UUF:GetDefaultDB(), true)
    UUF.LDS:EnhanceDatabase(UUF.db, "UnhaltedUnitFrames")
    UUF.TAG_UPDATE_INTERVAL = UUF.db.profile.General.TagUpdateInterval or 0.25
    UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
    UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"
    if UUF.db.global.UseGlobalProfile then
        local globalProfile = UUF:GetGlobalProfileName()
        UUF.db.global.GlobalProfile = globalProfile
		UUF.db:SetProfile(globalProfile)
	end
	UUF.db.RegisterCallback(UUF, "OnProfileChanged", UUF.HandleProfileChanged)
	UUF.db.RegisterCallback(UUF, "OnProfileCopied", UUF.RefreshProfiles)
	UUF.db.RegisterCallback(UUF, "OnProfileReset", UUF.RefreshProfiles)

    local playerSpecializationChangedEventFrame = CreateFrame("Frame")
    local specializationRefreshTimer
    playerSpecializationChangedEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	playerSpecializationChangedEventFrame:SetScript("OnEvent", function(_, _, unit)
        if unit ~= "player" then return end
        if specializationRefreshTimer then specializationRefreshTimer:Cancel() end
        specializationRefreshTimer = C_Timer.NewTimer(0.1, function()
            specializationRefreshTimer = nil
            UUF:RefreshProfiles()
        end)
    end)
end

function UnhaltedUnitFrames:OnEnable()
    UUF:Init()
    UUF:SpawnUnitFrame("player")
    UUF:SpawnUnitFrame("target")
    UUF:SpawnUnitFrame("targettarget")
    UUF:SpawnUnitFrame("focus")
    UUF:SpawnUnitFrame("focustarget")
    UUF:SpawnUnitFrame("pet")
    UUF:SpawnUnitFrame("boss")
    UUF:SpawnUnitFrame("party")
    UUF:SpawnUnitFrame("raid")
	if SCMAPI and SCMAPI.RegisterAnchorParents then SCMAPI.RegisterAnchorParents("UnhaltedUnitFrames", UUF.SCMAnchors) end
end
