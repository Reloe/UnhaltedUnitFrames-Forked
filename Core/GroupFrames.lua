local _, UUF = ...
local oUF = UUF.oUF
local GroupRosterEventFrame = CreateFrame("Frame")

local BlizzardRaidHiddenParent = CreateFrame("Frame", "UUF_BlizzardRaidHiddenParent", UIParent)
BlizzardRaidHiddenParent:Hide()

function UUF:HideBlizzardRaidFrames()
	for i = 1, UUF.MAX_RAID_GROUPS + UUF.MAX_RAID_FRAMES + 2 do
		local frameName = i == 1 and "CompactRaidFrameManager" or i == 2 and "CompactRaidFrameContainer" or i <= UUF.MAX_RAID_GROUPS + 2 and "CompactRaidGroup" .. (i - 2) or "CompactRaidFrame" .. (i - UUF.MAX_RAID_GROUPS - 2)
		local raidFrame = _G[frameName]
		if raidFrame then
			raidFrame:UnregisterAllEvents()
			raidFrame:Hide()
			if not InCombatLockdown() or not raidFrame:IsProtected() then raidFrame:SetParent(BlizzardRaidHiddenParent) end
		end
	end
end

function UUF:RegisterRaidFrame(unitFrame)
	if not unitFrame or unitFrame.isUUFUnitFrame then return end
	unitFrame.isUUFUnitFrame = true
	local raidFrames = unitFrame.isAugmentationRaidFrame and UUF.AUGMENTATION_RAID_FRAMES or unitFrame.isRaidStylePartyFrame and UUF.RAID_PARTY_FRAMES or UUF.RAID_FRAMES
	raidFrames[#raidFrames + 1] = unitFrame
end

function UUF:ForEachRaidFrame(callback, includeInactive, includeTestFrames, ...)
	for _, raidFrame in ipairs(UUF.RAID_FRAMES) do
		if raidFrame and (not raidFrame.isTestFrame or includeTestFrames) then
			local assignedUnit = raidFrame:GetAttribute("unit")
			local unit = assignedUnit or includeInactive and (raidFrame.isTestFrame and "raid" .. raidFrame.testIndex or raidFrame.UUFConfiguredUnit)
			callback(raidFrame, unit, assignedUnit, ...)
		end
	end
end

function UUF:ForEachRaidStylePartyFrame(callback, includeInactive, ...)
	for _, raidFrame in ipairs(UUF.RAID_PARTY_FRAMES) do
		if raidFrame then
			local assignedUnit = raidFrame:GetAttribute("unit")
			local unit = assignedUnit or includeInactive and raidFrame.UUFConfiguredUnit
			callback(raidFrame, unit, assignedUnit, ...)
		end
	end
end

function UUF:ForEachAugmentationRaidFrame(callback, includeInactive, ...)
	for _, raidFrame in ipairs(UUF.AUGMENTATION_RAID_FRAMES) do
		if raidFrame then
			local assignedUnit = raidFrame:GetAttribute("unit")
			local unit = assignedUnit or includeInactive and raidFrame.UUFConfiguredUnit
			callback(raidFrame, unit, assignedUnit, ...)
		end
	end
end

function UUF:LayoutAugmentationRaidFrames()
	if not UUF.AUGMENTATION_RAID_CONTAINER or not UUF.AUGMENTATION_RAID_HEADER then return end
	local FrameDB = UUF.db.profile.Units.raid.augmentation.Frame
	local unitGrowth, groupGrowth = (FrameDB.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_(%a+)$")
	unitGrowth = unitGrowth or "RIGHT"
	groupGrowth = groupGrowth or "DOWN"
	local spacing = FrameDB.Layout[5] or 0
	local frameCount = math.max(UUF.AUGMENTATION_RAID_FRAME_COUNT, 1)
	local unitsPerColumn = FrameDB.UnitsPerColumn or UUF.MAX_RAID_FRAMES_PER_GROUP
	local columns = math.ceil(frameCount / unitsPerColumn)
	local rows = math.min(frameCount, unitsPerColumn)
	local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
	local xOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
	local yOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0
	local columnAnchorPoint = groupGrowth == "RIGHT" and "LEFT" or groupGrowth == "LEFT" and "RIGHT" or groupGrowth == "UP" and "BOTTOM" or "TOP"
	local columnWidth = (unitGrowth == "UP" or unitGrowth == "DOWN") and FrameDB.Width or (FrameDB.Width + spacing) * rows - spacing
	local columnHeight = (unitGrowth == "UP" or unitGrowth == "DOWN") and (FrameDB.Height + spacing) * rows - spacing or FrameDB.Height

	UUF.AUGMENTATION_RAID_CONTAINER:ClearAllPoints()
	UUF.AUGMENTATION_RAID_CONTAINER:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
	UUF.AUGMENTATION_RAID_CONTAINER:SetFrameStrata(FrameDB.FrameStrata)
	UUF.AUGMENTATION_RAID_CONTAINER:SetSize((groupGrowth == "LEFT" or groupGrowth == "RIGHT") and (columnWidth + spacing) * columns - spacing or columnWidth, (groupGrowth == "UP" or groupGrowth == "DOWN") and (columnHeight + spacing) * columns - spacing or columnHeight)

	local header = UUF.AUGMENTATION_RAID_HEADER
	for childIndex = 1, UUF.MAX_RAID_FRAMES do
		local child = header:GetAttribute("child" .. childIndex)
		if child then
			child:ClearAllPoints()
			child:SetSize(FrameDB.Width, FrameDB.Height)
			child:SetFrameStrata(FrameDB.FrameStrata)
		end
	end
	header:SetAttribute("point", point)
	header:SetAttribute("xOffset", xOffset)
	header:SetAttribute("yOffset", yOffset)
	header:SetAttribute("initial-width", FrameDB.Width)
	header:SetAttribute("initial-height", FrameDB.Height)
	header:SetAttribute("oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height))
	header:SetAttribute("unitsPerColumn", unitsPerColumn)
	header:SetAttribute("maxColumns", math.ceil(UUF.MAX_RAID_FRAMES / unitsPerColumn))
	header:SetAttribute("columnSpacing", spacing)
	header:SetAttribute("columnAnchorPoint", columnAnchorPoint)
	header:SetFrameStrata(FrameDB.FrameStrata)
	header:SetSize(UUF.AUGMENTATION_RAID_CONTAINER:GetSize())
	header:ClearAllPoints()
	local horizontalAnchor = groupGrowth == "LEFT" and "RIGHT" or groupGrowth == "RIGHT" and "LEFT" or unitGrowth == "RIGHT" and "RIGHT" or "LEFT"
	local verticalAnchor = groupGrowth == "UP" and "BOTTOM" or groupGrowth == "DOWN" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "TOP"
	header:SetPoint(verticalAnchor .. horizontalAnchor, UUF.AUGMENTATION_RAID_CONTAINER, verticalAnchor .. horizontalAnchor)
end

function UUF:UpdateAugmentationRaidFrames()
	local AugmentationDB = UUF.db.profile.Units.raid.augmentation
	local isAugmentation = AugmentationDB.Enabled and UUF:IsAugmentationEvoker() and not UUF.RAID_TEST_MODE
	if not UUF.AUGMENTATION_RAID_HEADER then
		if isAugmentation then UUF:SpawnUnitFrame("raid") end
		return
	end
	if InCombatLockdown() then
		GroupRosterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if not isAugmentation then
		UUF.AUGMENTATION_RAID_FRAME_COUNT = 0
		if UUF.AUGMENTATION_RAID_HEADER:GetAttribute("nameList") ~= "" then
			UUF.AUGMENTATION_RAID_HEADER:SetAttribute("nameList", "")
			UUF:ForEachAugmentationRaidFrame(function(raidFrame)
				UUF:UnregisterRangeFrame(raidFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
				raidFrame.UUFGroupUnit = nil
			end, true)
		end
		if UUF.AUGMENTATION_RAID_CONTAINER:IsShown() then UUF.AUGMENTATION_RAID_CONTAINER:Hide() end
		if UUF.MOVERS and UUF.MOVERS.augmentation and UUF.MOVERS.augmentation:IsShown() then UUF.MOVERS.augmentation:Hide() end
		return
	end

	local names = {}
	local seen, rosterByFullName, rosterByShortName = {}, {}, {}
	for raidIndex = 1, GetNumGroupMembers() do
		local rosterName = GetRaidRosterInfo(raidIndex)
		if rosterName then
			rosterByFullName[rosterName:lower()] = rosterName
			local shortName = Ambiguate(rosterName, "short"):lower()
			local shortNames = rosterByShortName[shortName]
			if not shortNames then
				rosterByShortName[shortName] = rosterName
			elseif type(shortNames) == "string" then
				rosterByShortName[shortName] = {shortNames, rosterName}
			else
				shortNames[#shortNames + 1] = rosterName
			end
		end
	end

	for configuredName in (AugmentationDB.Names or ""):gmatch("[^,;\n]+") do
		local configuredNameLower = strtrim(configuredName):lower()
		if configuredNameLower ~= "" then
			local rosterName = rosterByFullName[configuredNameLower]
			local shortNames = not rosterName and rosterByShortName[configuredNameLower]
			if type(shortNames) == "string" then
				rosterName = shortNames
			elseif shortNames then
				for _, shortName in ipairs(shortNames) do
					if not seen[shortName] then rosterName = shortName break end
				end
			end
			if rosterName and not seen[rosterName] then
				seen[rosterName] = true
				names[#names + 1] = rosterName
			end
		end
	end
	local active = #names > 0
	UUF.AUGMENTATION_RAID_FRAME_COUNT = #names
	local nameList = table.concat(names, ",")
	local activeNameList = active and nameList or ""
	local sortMethod = AugmentationDB.Frame.SortBy == "NAME" and "NAME" or "NAMELIST"
	if UUF.AUGMENTATION_RAID_HEADER:GetAttribute("sortMethod") ~= sortMethod then UUF.AUGMENTATION_RAID_HEADER:SetAttribute("sortMethod", sortMethod) end
	if UUF.AUGMENTATION_RAID_HEADER:GetAttribute("nameList") ~= activeNameList then UUF.AUGMENTATION_RAID_HEADER:SetAttribute("nameList", activeNameList) end
	UUF:ForEachAugmentationRaidFrame(function(raidFrame, unit, assignedUnit)
		if not assignedUnit then
			UUF:UnregisterRangeFrame(raidFrame)
			UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
			raidFrame.UUFGroupUnit = nil
			return
		end
		raidFrame:SetSize(AugmentationDB.Frame.Width, AugmentationDB.Frame.Height)
		raidFrame:SetFrameStrata(AugmentationDB.Frame.FrameStrata)
		UUF:UpdateUnitFrame(raidFrame, unit)
		raidFrame.UUFGroupUnit = assignedUnit
	end, true)
	UUF:LayoutAugmentationRaidFrames()
	UUF.AUGMENTATION_RAID_CONTAINER:SetShown(active)
	if UUF.MOVERS and UUF.MOVERS.augmentation then UUF.MOVERS.augmentation:SetShown(isAugmentation and UUF.MOVERS_UNLOCKED) end
end

function UUF:SpawnAugmentationRaidFrames()
	local AugmentationDB = UUF.db.profile.Units.raid.augmentation
	if not AugmentationDB or not AugmentationDB.Enabled or not UUF:IsAugmentationEvoker() then return end
	if not UUF.AUGMENTATION_RAID_CONTAINER then
		UUF.AUGMENTATION_RAID_CONTAINER = CreateFrame("Frame", "UUF_AugmentationRaidContainer", UIParent, "BackdropTemplate")
		UUF.AUGMENTATION_RAID_CONTAINER:SetBackdrop(UUF.BACKDROP)
		UUF.AUGMENTATION_RAID_CONTAINER:SetBackdropColor(0, 0, 0, 0)
		UUF.AUGMENTATION_RAID_CONTAINER:SetBackdropBorderColor(0, 0, 0, 0)
	end
	if not UUF.AUGMENTATION_RAID_HEADER then
		local FrameDB = AugmentationDB.Frame
		UUF.AUGMENTATION_RAID_HEADER = oUF:SpawnHeader("UUF_AugmentationRaidHeader", nil,
			"showRaid", true,
			"showParty", false,
			"showPlayer", true,
			"showSolo", false,
			"nameList", "",
			"sortMethod", FrameDB.SortBy == "NAME" and "NAME" or "NAMELIST",
			"initial-width", FrameDB.Width,
			"initial-height", FrameDB.Height,
			"oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
			"unitsPerColumn", FrameDB.UnitsPerColumn or UUF.MAX_RAID_FRAMES_PER_GROUP,
			"maxColumns", math.ceil(UUF.MAX_RAID_FRAMES / (FrameDB.UnitsPerColumn or UUF.MAX_RAID_FRAMES_PER_GROUP))
		)
	UUF.AUGMENTATION_RAID_HEADER:SetNumAuraContainers(UUF.MAX_AURA_CONTAINERS)
		UUF.AUGMENTATION_RAID_HEADER:SetParent(UUF.AUGMENTATION_RAID_CONTAINER)
		UUF.AUGMENTATION_RAID_HEADER:SetVisibility("raid")
	end
	UUF:CreateMover("augmentation")
	UUF:UpdateAugmentationRaidFrames()
end

local function HideNormalPartyFrames()
	if UUF.PARTY_CONTAINER then
		if not InCombatLockdown() then UnregisterStateDriver(UUF.PARTY_CONTAINER, "visibility") end
		UUF.PARTY_CONTAINER:Hide()
	end
	for _, partyFrame in ipairs(UUF.PARTY_FRAMES) do
		UUF:UnregisterRangeFrame(partyFrame)
		UUF:UnregisterTargetGlowIndicatorFrame(partyFrame)
		partyFrame.UUFGroupUnit = nil
		if not InCombatLockdown() then UnregisterUnitWatch(partyFrame) end
		if not InCombatLockdown() or not partyFrame:IsProtected() then partyFrame:Hide() end
	end
end

function UUF:LayoutRaidStylePartyFrames()
	local RaidDB = UUF.db.profile.Units.raid
	if not RaidDB or not RaidDB.Frame or not UUF.RAID_PARTY_CONTAINER or not UUF.RAID_PARTY_HEADER then return end
	local Frame = RaidDB.Frame
	local unitGrowth = (Frame.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_") or "RIGHT"
	local spacing = Frame.Layout[5] or 0
	local headerWidth = (unitGrowth == "UP" or unitGrowth == "DOWN") and Frame.Width or (Frame.Width + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing
	local headerHeight = (unitGrowth == "UP" or unitGrowth == "DOWN") and (Frame.Height + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing or Frame.Height
	local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
	local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
	local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0

	UUF.RAID_PARTY_CONTAINER:ClearAllPoints()
	UUF.RAID_PARTY_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
	UUF.RAID_PARTY_CONTAINER:SetFrameStrata(Frame.FrameStrata)
	UUF.RAID_PARTY_CONTAINER:SetSize(math.max(headerWidth, Frame.Width), math.max(headerHeight, Frame.Height))

	local header = UUF.RAID_PARTY_HEADER
	for childIndex = 1, UUF.MAX_RAID_FRAMES_PER_GROUP do
		local child = header:GetAttribute("child" .. childIndex)
		if child then
			child:ClearAllPoints()
			child:SetSize(Frame.Width, Frame.Height)
			child:SetFrameStrata(Frame.FrameStrata)
		end
	end
	header:SetAttribute("point", point)
	header:SetAttribute("xOffset", unitXOffset)
	header:SetAttribute("yOffset", unitYOffset)
	header:SetAttribute("initial-width", Frame.Width)
	header:SetAttribute("initial-height", Frame.Height)
	header:SetAttribute("oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(Frame.Width, Frame.Height))
	header:SetAttribute("unitsPerColumn", UUF.MAX_RAID_FRAMES_PER_GROUP)
	header:SetAttribute("maxColumns", 1)
	header:SetAttribute("sortMethod", Frame.SortBy == "INDEX" and "INDEX" or nil)
	header:SetFrameStrata(Frame.FrameStrata)
	header:SetSize(headerWidth, headerHeight)
	header:ClearAllPoints()
	local horizontalAnchor = unitGrowth == "RIGHT" and "RIGHT" or "LEFT"
	local verticalAnchor = unitGrowth == "DOWN" and "BOTTOM" or "TOP"
	header:SetPoint(verticalAnchor .. horizontalAnchor, UUF.RAID_PARTY_CONTAINER, verticalAnchor .. horizontalAnchor)
end

function UUF:SpawnRaidStylePartyFrames()
	local RaidDB = UUF.db.profile.Units.raid
	if not UUF:UseRaidStyleForParty() then return end
	UUF:RegisterRaidStylePartyStyle()
	oUF:SetActiveStyle(UUF:FetchFrameName("raidparty"))
	if not UUF.RAID_PARTY_CONTAINER then
		UUF.RAID_PARTY_CONTAINER = CreateFrame("Frame", "UUF_RaidPartyContainer", UIParent, "BackdropTemplate")
		UUF.RAID_PARTY_CONTAINER:SetBackdrop(UUF.BACKDROP)
		UUF.RAID_PARTY_CONTAINER:SetBackdropColor(0, 0, 0, 0)
		UUF.RAID_PARTY_CONTAINER:SetBackdropBorderColor(0, 0, 0, 0)
	end
	if not UUF.RAID_PARTY_HEADER then
		local FrameDB = RaidDB.Frame
		local unitGrowth = (FrameDB.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_") or "RIGHT"
		local spacing = FrameDB.Layout[5] or 0
		local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
		local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
		local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0
		UUF.RAID_PARTY_HEADER = oUF:SpawnHeader("UUF_RaidPartyHeader", nil,
			"showRaid", false,
			"showParty", true,
			"showPlayer", true,
			"showSolo", false,
			"initial-width", FrameDB.Width,
			"initial-height", FrameDB.Height,
			"oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
			"point", point,
			"xOffset", unitXOffset,
			"yOffset", unitYOffset,
			"unitsPerColumn", UUF.MAX_RAID_FRAMES_PER_GROUP,
			"maxColumns", 1,
			"sortMethod", FrameDB.SortBy == "INDEX" and "INDEX" or nil
		)
		UUF.RAID_PARTY_HEADER:SetNumAuraContainers(UUF.MAX_AURA_CONTAINERS)
		UUF.RAID_PARTY_HEADER:SetParent(UUF.RAID_PARTY_CONTAINER)
		UUF.RAID_PARTY_HEADER:SetVisibility("party")
	end
	RegisterStateDriver(UUF.RAID_PARTY_CONTAINER, "visibility", "[group:party,nogroup:raid] show; hide")
	HideNormalPartyFrames()
	UUF:UpdateRaidStylePartyFrames()
end

function UUF:UpdateRaidStylePartyFrames()
	if not UUF:UseRaidStyleForParty() then
		if UUF.RAID_PARTY_CONTAINER then
			if not InCombatLockdown() then UnregisterStateDriver(UUF.RAID_PARTY_CONTAINER, "visibility") end
			UUF.RAID_PARTY_CONTAINER:Hide()
		end
		return
	end
	if not UUF.RAID_PARTY_CONTAINER or not UUF.RAID_PARTY_HEADER then return UUF:SpawnRaidStylePartyFrames() end
	local RaidDB = UUF.db.profile.Units.raid
	RegisterStateDriver(UUF.RAID_PARTY_CONTAINER, "visibility", "[group:party,nogroup:raid] show; hide")
	HideNormalPartyFrames()
	UUF:ForEachRaidStylePartyFrame(function(raidFrame, unit, assignedUnit)
		if not assignedUnit then
			UUF:UnregisterRangeFrame(raidFrame)
			UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
			raidFrame.UUFGroupUnit = nil
			return
		end
		raidFrame:SetSize(RaidDB.Frame.Width, RaidDB.Frame.Height)
		raidFrame:SetFrameStrata(RaidDB.Frame.FrameStrata)
		UUF:UpdateUnitFrame(raidFrame, assignedUnit)
		raidFrame.UUFGroupUnit = assignedUnit
	end, true)
	UUF:LayoutRaidStylePartyFrames()
end

function UUF:SpawnGroupFrame(groupType)
	local FrameDB = UUF.db.profile.Units[groupType].Frame
	if groupType == "party" then
		if UUF:UseRaidStyleForParty() then return UUF:SpawnRaidStylePartyFrames() end
		if not UUF.PARTY_CONTAINER then
			UUF.PARTY_CONTAINER = CreateFrame("Frame", "UUF_PartyContainer", UIParent, "BackdropTemplate")
			UUF.PARTY_CONTAINER:SetBackdrop(UUF.BACKDROP)
			UUF.PARTY_CONTAINER:SetBackdropColor(0, 0, 0, 0)
			UUF.PARTY_CONTAINER:SetBackdropBorderColor(0, 0, 0, 0)
		end
		UUF.PARTY_CONTAINER:ClearAllPoints()
		UUF.PARTY_CONTAINER:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
		UUF.PARTY_CONTAINER:SetFrameStrata(FrameDB.FrameStrata)
		RegisterStateDriver(UUF.PARTY_CONTAINER, "visibility", "[group:party,nogroup:raid] show; hide")
		for i = 1, UUF.MAX_PARTY_FRAMES do
			local partyFrame = oUF:Spawn("party" .. i, UUF:FetchFrameName("party" .. i))
			partyFrame.partyIndex = i + 1
			partyFrame:SetParent(UUF.PARTY_CONTAINER)
			partyFrame:SetSize(FrameDB.Width, FrameDB.Height)
			partyFrame:SetFrameStrata(FrameDB.FrameStrata)
			UUF["PARTY" .. i] = partyFrame
			UUF.PARTY_FRAMES[i] = partyFrame
			UUF:RegisterTargetGlowIndicatorFrame(UUF:FetchFrameName("party" .. i), "party" .. i)
			UUF:RegisterRangeFrame(UUF:FetchFrameName("party" .. i), "party" .. i)
		end
		if FrameDB.ShowPlayer then
			local partyPlayerFrame = oUF:Spawn("player", UUF:FetchFrameName("partyplayer"))
			partyPlayerFrame.partyIndex = 1
			partyPlayerFrame:SetParent(UUF.PARTY_CONTAINER)
			partyPlayerFrame:SetSize(FrameDB.Width, FrameDB.Height)
			partyPlayerFrame:SetFrameStrata(FrameDB.FrameStrata)
			UUF.PARTYPLAYER = partyPlayerFrame
			UUF.PARTY_FRAMES[#UUF.PARTY_FRAMES + 1] = partyPlayerFrame
			UUF:RegisterTargetGlowIndicatorFrame(partyPlayerFrame, "partyplayer")
			UUF:RegisterRangeFrame(partyPlayerFrame, "player")
		end
		UUF:CreateMover(groupType)
		for i = 1, UUF.MAX_PARTY_FRAMES do RegisterUnitWatch(UUF["PARTY" .. i]) end
		UUF.PARTY_CONTAINER:Show()
	elseif groupType == "raid" then
		if not UUF.RAID_CONTAINER then
			UUF.RAID_CONTAINER = CreateFrame("Frame", "UUF_RaidContainer", UIParent, "BackdropTemplate")
			UUF.RAID_CONTAINER:SetBackdrop(UUF.BACKDROP)
			UUF.RAID_CONTAINER:SetBackdropColor(0, 0, 0, 0)
			UUF.RAID_CONTAINER:SetBackdropBorderColor(0, 0, 0, 0)
		end
		UUF.RAID_CONTAINER:ClearAllPoints()
		UUF.RAID_CONTAINER:SetPoint(FrameDB.Layout[1], UIParent, FrameDB.Layout[2], FrameDB.Layout[3], FrameDB.Layout[4])
		UUF.RAID_CONTAINER:SetFrameStrata(FrameDB.FrameStrata)
		RegisterStateDriver(UUF.RAID_CONTAINER, "visibility", "show")
		local unitGrowth = (FrameDB.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_")
		local spacing = FrameDB.Layout[5] or 0
		local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
		local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
		local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0

		for groupIndex = 1, UUF.MAX_RAID_GROUPS do
			local headerName = "UUF_RaidHeader" .. groupIndex
			local header = oUF:SpawnHeader(headerName, nil,
				"showRaid", true,
				"showParty", false,
				"showPlayer", true,
				"showSolo", false,
				"groupFilter", (not FrameDB.Groups or FrameDB.Groups[groupIndex]) and tostring(groupIndex) or "0",
				"initial-width", FrameDB.Width,
				"initial-height", FrameDB.Height,
				"oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(FrameDB.Width, FrameDB.Height),
				"point", point,
				"xOffset", unitXOffset,
				"yOffset", unitYOffset,
				"unitsPerColumn", UUF.MAX_RAID_FRAMES_PER_GROUP,
				"maxColumns", 1,
				"sortMethod", FrameDB.SortBy == "INDEX" and "INDEX" or nil
			)
			header:SetNumAuraContainers(UUF.MAX_AURA_CONTAINERS)
			header:SetSize(FrameDB.Width, FrameDB.Height)
			header:SetParent(UUF.RAID_CONTAINER)
			header:SetVisibility("raid")
			header:SetAttribute("startingIndex", -(UUF.MAX_RAID_FRAMES_PER_GROUP - 1))
			header:Show()
			header:SetAttribute("startingIndex", 1)
			UUF.RAID_HEADERS[groupIndex] = header
		end
		UUF:CreateMover(groupType)
		UUF.RAID_CONTAINER:Show()
		for _, header in ipairs(UUF.RAID_HEADERS) do header:Show() end
	end
	UUF:LayoutGroupFrames(groupType)
end

function UUF:UpdateGroupFrame(groupType)
	if groupType == "party" and UUF:UseRaidStyleForParty() then return UUF:UpdateRaidStylePartyFrames() end
	local UnitDB = UUF.db.profile.Units[groupType]
	if not UnitDB or not UnitDB.Enabled then
		local container = groupType == "party" and UUF.PARTY_CONTAINER or UUF.RAID_CONTAINER
		if container then if not InCombatLockdown() then UnregisterStateDriver(container, "visibility") end container:Hide() end
		if groupType == "party" then
			for _, partyFrame in ipairs(UUF.PARTY_FRAMES) do
				UUF:UnregisterRangeFrame(partyFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(partyFrame)
				partyFrame.UUFGroupUnit = nil
			end
		else
			UUF:ForEachRaidFrame(function(raidFrame)
				UUF:UnregisterRangeFrame(raidFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
				raidFrame.UUFGroupUnit = nil
			end, true, UUF.RAID_TEST_MODE)
		end
		return
	end
	if groupType == "party" then
		if not UUF.PARTY_CONTAINER then UUF:SpawnGroupFrame("party") else
			UUF.PARTY_CONTAINER:ClearAllPoints()
			UUF.PARTY_CONTAINER:SetPoint(UnitDB.Frame.Layout[1], UIParent, UnitDB.Frame.Layout[2], UnitDB.Frame.Layout[3], UnitDB.Frame.Layout[4])
			UUF.PARTY_CONTAINER:SetFrameStrata(UnitDB.Frame.FrameStrata)
			RegisterStateDriver(UUF.PARTY_CONTAINER, "visibility", "[group:party,nogroup:raid] show; hide")
		end
		for i = 1, UUF.MAX_PARTY_FRAMES do if UUF["PARTY" .. i] then UUF:UpdateUnitFrame(UUF["PARTY" .. i], "party" .. i) end end
		if UUF.PARTYPLAYER then UUF:UpdateUnitFrame(UUF.PARTYPLAYER, "partyplayer") end
	elseif groupType == "raid" then
		if not UUF.RAID_CONTAINER then UUF:SpawnGroupFrame("raid") else
			UUF.RAID_CONTAINER:ClearAllPoints()
			UUF.RAID_CONTAINER:SetPoint(UnitDB.Frame.Layout[1], UIParent, UnitDB.Frame.Layout[2], UnitDB.Frame.Layout[3], UnitDB.Frame.Layout[4])
			UUF.RAID_CONTAINER:SetFrameStrata(UnitDB.Frame.FrameStrata)
			RegisterStateDriver(UUF.RAID_CONTAINER, "visibility", "show")
		end
		UUF:ForEachRaidFrame(function(raidFrame, unit, assignedUnit)
			if not unit or unit == "raid" then
				UUF:UnregisterRangeFrame(raidFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
				raidFrame.UUFGroupUnit = nil
				return
			end
			raidFrame:SetSize(UnitDB.Frame.Width, UnitDB.Frame.Height)
			raidFrame:SetFrameStrata(UnitDB.Frame.FrameStrata)
			UUF:UpdateUnitFrame(raidFrame, unit)
			if assignedUnit then
				raidFrame.UUFGroupUnit = assignedUnit
			else
				UUF:UnregisterRangeFrame(raidFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
				raidFrame.UUFGroupUnit = nil
			end
		end, true, UUF.RAID_TEST_MODE)
	end
	UUF:LayoutGroupFrames(groupType)
	if groupType == "party" and UUF.PARTY_TEST_MODE or groupType == "raid" and UUF.RAID_TEST_MODE then UUF:UpdateTestEnvironment(groupType, "all") end
end

function UUF:UpdateGroupIndicators(groupType, onlyUpdateRoles)
	if groupType == "party" and UUF:UseRaidStyleForParty() then
		local UnitDB = UUF.db.profile.Units.raid
		if not UnitDB or not UnitDB.Enabled then return end
		UUF:ForEachRaidStylePartyFrame(function(raidFrame, unit)
			if unit and not unit:match("^raidparty") then
				if not onlyUpdateRoles then
					UUF:RegisterRangeFrame(raidFrame, unit)
					UUF:RegisterTargetGlowIndicatorFrame(raidFrame, unit)
					if raidFrame.UUFGroupUnit ~= unit then
						raidFrame.UUFGroupUnit = unit
						if raidFrame.DispelHighlight then UUF:UpdateUnitDispelHighlight(raidFrame, unit) end
					end
				end
				if UnitDB.PowerBar.Enabled and UnitDB.PowerBar.OnlyShowHealers then UUF:UpdateUnitPowerBar(raidFrame, unit) end
				UUF:UpdateUnitRoleIndicator(raidFrame, unit)
			elseif not onlyUpdateRoles then
				UUF:UnregisterRangeFrame(raidFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
				raidFrame.UUFGroupUnit = nil
			end
		end, false)
		UUF:LayoutRaidStylePartyFrames()
		return
	end
	local UnitDB = UUF.db.profile.Units[groupType]
	if not UnitDB or not UnitDB.Enabled then return end
	if groupType == "party" then
		for i = 1, UUF.MAX_PARTY_FRAMES do
			local partyFrame = UUF["PARTY" .. i]
			if partyFrame then
				if not onlyUpdateRoles then
					UUF:RegisterRangeFrame(partyFrame, "party" .. i)
					UUF:RegisterTargetGlowIndicatorFrame(partyFrame, "party" .. i)
					if partyFrame.UUFGroupUnit ~= "party" .. i then
						partyFrame.UUFGroupUnit = "party" .. i
						if partyFrame.DispelHighlight then UUF:UpdateUnitDispelHighlight(partyFrame, "party" .. i) end
					end
				end
				if UnitDB.PowerBar.Enabled and UnitDB.PowerBar.OnlyShowHealers then UUF:UpdateUnitPowerBar(partyFrame, "party" .. i) end
				UUF:UpdateUnitRoleIndicator(partyFrame, "party" .. i)
			end
		end
		if UUF.PARTYPLAYER then
			if not onlyUpdateRoles then
				UUF:RegisterRangeFrame(UUF.PARTYPLAYER, "player")
				UUF:RegisterTargetGlowIndicatorFrame(UUF.PARTYPLAYER, "partyplayer")
				if UUF.PARTYPLAYER.UUFGroupUnit ~= "partyplayer" then
					UUF.PARTYPLAYER.UUFGroupUnit = "partyplayer"
					if UUF.PARTYPLAYER.DispelHighlight then UUF:UpdateUnitDispelHighlight(UUF.PARTYPLAYER, "partyplayer") end
				end
			end
			if UnitDB.PowerBar.Enabled and UnitDB.PowerBar.OnlyShowHealers then UUF:UpdateUnitPowerBar(UUF.PARTYPLAYER, "partyplayer") end
			UUF:UpdateUnitRoleIndicator(UUF.PARTYPLAYER, "partyplayer")
		end
	elseif groupType == "raid" then
		UUF:ForEachRaidFrame(function(raidFrame, unit)
			if unit and unit ~= "raid" then
				if not onlyUpdateRoles then
					UUF:RegisterRangeFrame(raidFrame, unit)
					UUF:RegisterTargetGlowIndicatorFrame(raidFrame, unit)
					if raidFrame.UUFGroupUnit ~= unit then
						raidFrame.UUFGroupUnit = unit
						if raidFrame.DispelHighlight then UUF:UpdateUnitDispelHighlight(raidFrame, unit) end
					end
				end
				if UnitDB.PowerBar.Enabled and UnitDB.PowerBar.OnlyShowHealers then UUF:UpdateUnitPowerBar(raidFrame, unit) end
				UUF:UpdateUnitRoleIndicator(raidFrame, unit)
			elseif not onlyUpdateRoles then
				UUF:UnregisterRangeFrame(raidFrame)
				UUF:UnregisterTargetGlowIndicatorFrame(raidFrame)
				raidFrame.UUFGroupUnit = nil
			end
		end, false, UUF.RAID_TEST_MODE)
	end
	if groupType == "party" then UUF:LayoutGroupFrames(groupType) end
end

function UUF:LayoutGroupFrames(groupType)
	if groupType == "party" and UUF:UseRaidStyleForParty() then return UUF:LayoutRaidStylePartyFrames() end
	local Frame = UUF.db.profile.Units[groupType].Frame
	if groupType == "party" then
		if not UUF.PARTY_CONTAINER or #UUF.PARTY_FRAMES == 0 then return end
		UUF.PARTY_CONTAINER:ClearAllPoints()
		UUF.PARTY_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
		UUF.PARTY_CONTAINER:SetFrameStrata(Frame.FrameStrata)
		local partyFrames = {}
		for _, partyFrame in ipairs(UUF.PARTY_FRAMES) do partyFrames[#partyFrames + 1] = partyFrame end
		table.sort(partyFrames, function(firstFrame, secondFrame)
			if Frame.SortBy == "NAME" then
				return (UnitName(firstFrame.unit) or firstFrame.unit or "") < (UnitName(secondFrame.unit) or secondFrame.unit or "")
			elseif Frame.SortBy == "ROLE" then
				local firstRole = UUF.PARTY_TEST_MODE and firstFrame.testRole or UnitGroupRolesAssigned(firstFrame.unit)
				local secondRole = UUF.PARTY_TEST_MODE and secondFrame.testRole or UnitGroupRolesAssigned(secondFrame.unit)
				if firstRole ~= secondRole then
					for _, orderedRole in ipairs(Frame.RoleOrder or {}) do
						if firstRole == orderedRole then return true end
						if secondRole == orderedRole then return false end
					end
				end
			end
			return (firstFrame.partyIndex or 0) < (secondFrame.partyIndex or 0)
		end)
		local spacing = Frame.Layout[5] or 0
		local horizontal = Frame.GrowthDirection == "LEFT" or Frame.GrowthDirection == "RIGHT"
		UUF.PARTY_CONTAINER:SetSize(math.max(horizontal and (Frame.Width + spacing) * #partyFrames - spacing or Frame.Width, Frame.Width), math.max(horizontal and Frame.Height or (Frame.Height + spacing) * #partyFrames - spacing, Frame.Height))
		for index, partyFrame in ipairs(partyFrames) do
			partyFrame:ClearAllPoints()
			partyFrame:SetSize(Frame.Width, Frame.Height)
			partyFrame:SetFrameStrata(Frame.FrameStrata)
			if Frame.GrowthDirection == "UP" then
				partyFrame:SetPoint("BOTTOMLEFT", UUF.PARTY_CONTAINER, "BOTTOMLEFT", 0, (index - 1) * (Frame.Height + spacing))
			elseif Frame.GrowthDirection == "LEFT" then
				partyFrame:SetPoint("TOPRIGHT", UUF.PARTY_CONTAINER, "TOPRIGHT", -((index - 1) * (Frame.Width + spacing)), 0)
			elseif Frame.GrowthDirection == "RIGHT" then
				partyFrame:SetPoint("TOPLEFT", UUF.PARTY_CONTAINER, "TOPLEFT", (index - 1) * (Frame.Width + spacing), 0)
			else
				partyFrame:SetPoint("TOPLEFT", UUF.PARTY_CONTAINER, "TOPLEFT", 0, -((index - 1) * (Frame.Height + spacing)))
			end
		end
	elseif groupType == "raid" then
		if not UUF.RAID_CONTAINER then return end
		local _, _, difficultyID = GetInstanceInfo()
		local autoGroupCount = Frame.AutoAdjustGroups and ((difficultyID == 14 or difficultyID == 15) and 6 or difficultyID == 16 and 4 or difficultyID == 233 and 5 or 8)
		local unitGrowth, groupGrowth = (Frame.GrowthDirection or "RIGHT_DOWN"):match("^(%a+)_(%a+)$")
		unitGrowth = unitGrowth or "RIGHT"
		groupGrowth = groupGrowth or "DOWN"
		local spacing = Frame.Layout[5] or 0
		local shownGroups = 0
		for groupIndex = 1, UUF.MAX_RAID_GROUPS do if autoGroupCount and groupIndex <= autoGroupCount or not autoGroupCount and (not Frame.Groups or Frame.Groups[groupIndex]) then shownGroups = shownGroups + 1 end end
		local headerWidth = (unitGrowth == "UP" or unitGrowth == "DOWN") and Frame.Width or (Frame.Width + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing
		local headerHeight = (unitGrowth == "UP" or unitGrowth == "DOWN") and (Frame.Height + spacing) * UUF.MAX_RAID_FRAMES_PER_GROUP - spacing or Frame.Height
		local point = unitGrowth == "RIGHT" and "RIGHT" or unitGrowth == "UP" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "LEFT"
		local unitXOffset = unitGrowth == "RIGHT" and -spacing or unitGrowth == "LEFT" and spacing or 0
		local unitYOffset = unitGrowth == "UP" and -spacing or unitGrowth == "DOWN" and spacing or 0
		UUF.RAID_CONTAINER:ClearAllPoints()
		UUF.RAID_CONTAINER:SetPoint(Frame.Layout[1], UIParent, Frame.Layout[2], Frame.Layout[3], Frame.Layout[4])
		UUF.RAID_CONTAINER:SetFrameStrata(Frame.FrameStrata)
		UUF.RAID_CONTAINER:SetSize(math.max((groupGrowth == "LEFT" or groupGrowth == "RIGHT") and (headerWidth + spacing) * shownGroups - spacing or headerWidth, Frame.Width), math.max((groupGrowth == "UP" or groupGrowth == "DOWN") and (headerHeight + spacing) * shownGroups - spacing or headerHeight, Frame.Height))
		local shownGroupIndex = 0
		for groupIndex, header in ipairs(UUF.RAID_HEADERS) do
			local showGroup = autoGroupCount and groupIndex <= autoGroupCount or not autoGroupCount and (not Frame.Groups or Frame.Groups[groupIndex])
			if showGroup then shownGroupIndex = shownGroupIndex + 1 end
			for childIndex = 1, UUF.MAX_RAID_FRAMES_PER_GROUP do
				local child = header:GetAttribute("child" .. childIndex)
				if child then child:ClearAllPoints() end
			end
			header:SetAttribute("point", point)
			header:SetAttribute("xOffset", unitXOffset)
			header:SetAttribute("yOffset", unitYOffset)
			header:SetAttribute("initial-width", Frame.Width)
			header:SetAttribute("initial-height", Frame.Height)
			header:SetAttribute("oUF-initialConfigFunction", ("self:SetWidth(%s); self:SetHeight(%s)"):format(Frame.Width, Frame.Height))
			header:SetAttribute("unitsPerColumn", UUF.MAX_RAID_FRAMES_PER_GROUP)
			header:SetAttribute("maxColumns", 1)
			header:SetAttribute("sortMethod", Frame.SortBy == "INDEX" and "INDEX" or nil)
			header:SetAttribute("groupFilter", showGroup and tostring(groupIndex) or "0")
			if showGroup then header:Show() else header:Hide() end
			header:SetFrameStrata(Frame.FrameStrata)
			header:SetSize(headerWidth, headerHeight)
			header:ClearAllPoints()
			local horizontalAnchor = groupGrowth == "LEFT" and "RIGHT" or groupGrowth == "RIGHT" and "LEFT" or unitGrowth == "RIGHT" and "RIGHT" or "LEFT"
			local verticalAnchor = groupGrowth == "UP" and "BOTTOM" or groupGrowth == "DOWN" and "TOP" or unitGrowth == "DOWN" and "BOTTOM" or "TOP"
			header:SetPoint(verticalAnchor .. horizontalAnchor, UUF.RAID_CONTAINER, verticalAnchor .. horizontalAnchor, groupGrowth == "RIGHT" and (shownGroupIndex - 1) * (headerWidth + spacing) or groupGrowth == "LEFT" and -((shownGroupIndex - 1) * (headerWidth + spacing)) or 0, groupGrowth == "UP" and (shownGroupIndex - 1) * (headerHeight + spacing) or groupGrowth == "DOWN" and -((shownGroupIndex - 1) * (headerHeight + spacing)) or 0)
		end
	end
end

GroupRosterEventFrame:RegisterEvent("ADDON_LOADED")
GroupRosterEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
GroupRosterEventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
GroupRosterEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
GroupRosterEventFrame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
GroupRosterEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
GroupRosterEventFrame:SetScript("OnEvent", function(_, event, addonName)
	if not UUF.db then return end
	local RaidDB = UUF.db.profile.Units.raid
	if event == "ADDON_LOADED" then
		if addonName == "Blizzard_CompactRaidFrames" and RaidDB and RaidDB.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		return
	end
	if InCombatLockdown() then GroupRosterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	if event == "PLAYER_REGEN_ENABLED" then GroupRosterEventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if event == "GROUP_ROSTER_UPDATE" then
		if RaidDB and RaidDB.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		UUF:UpdateGroupIndicators("party")
		UUF:UpdateAugmentationRaidFrames()
	elseif event == "PLAYER_ROLES_ASSIGNED" then
		UUF:UpdateGroupIndicators("party", true)
		UUF:UpdateGroupIndicators("raid", true)
		UUF:UpdateAugmentationRaidFrames()
	elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_DIFFICULTY_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
		if RaidDB and RaidDB.Frame.AutoAdjustGroups then UUF:LayoutGroupFrames("raid") end
		UUF:UpdateAugmentationRaidFrames()
		if event == "PLAYER_ENTERING_WORLD" then
			UUF:UpdateGroupIndicators("party", true)
			UUF:UpdateGroupIndicators("raid", true)
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if RaidDB and RaidDB.ForceHideBlizzard then UUF:HideBlizzardRaidFrames() end
		UUF:UpdateGroupIndicators("party")
		UUF:UpdateGroupIndicators("raid")
		UUF:UpdateAugmentationRaidFrames()
	end
end)
