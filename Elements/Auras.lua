local _, UUF = ...

local AuraDurationFormatter = C_StringUtil.CreateNumericRuleFormatter()
local AuraDurationNoDecimalsFormatter = C_StringUtil.CreateNumericRuleFormatter()
local AuraContainerState = setmetatable({}, {__mode = "k"})
local AuraUnitFrames = setmetatable({}, {__mode = "k"})
local AuraEligibilityEventFrame = CreateFrame("Frame")
local AuraBorderOptions = {
	[false] = {showIcon = false, showWhenHarmful = false, showWhenHelpful = false, style = AuraButtonBorderStyle.Color},
	[true] = {showIcon = false, showWhenHarmful = true, showWhenHelpful = true, style = AuraButtonBorderStyle.Color},
}

AuraEligibilityEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
AuraEligibilityEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
AuraEligibilityEventFrame:RegisterEvent("UNIT_FACTION")
AuraEligibilityEventFrame:SetScript("OnEvent", function(_, event, eventUnit)
	for unitFrame, unit in pairs(AuraUnitFrames) do
		local unitToken = unitFrame.unit
		if not unitToken then unitToken = unit == "partyplayer" and "player" or unit end
		local update = event == "UNIT_FACTION" and (eventUnit == "player" or unitToken == eventUnit) or event == "PLAYER_TARGET_CHANGED" and (unit == "target" or unit == "targettarget") or event == "PLAYER_FOCUS_CHANGED" and (unit == "focus" or unit == "focustarget")
		if update then UUF:UpdateUnitAuraEligibility(unitFrame, unit) end
	end
end)

local function GetAuraDB(unitFrame, unit, auraKey)
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	return AurasDB and AurasDB.Containers and AurasDB.Containers[auraKey]
end

local function ApplyFontStyle(fontString, anchorFrame, layout, fontSize, colour, unitFrame, unit)
	local FontsDB = UUF:GetFontSettings(unitFrame, unit)
	local FontMedia = UUF:GetFontMedia(unitFrame, unit)
	fontString:ClearAllPoints()
	fontString:SetPoint(layout[1], anchorFrame, layout[2], layout[3], layout[4])
	fontString:SetFont(FontMedia, fontSize, FontsDB.FontFlag)
	if colour then fontString:SetTextColor(unpack(colour)) end
	if FontsDB.Shadow.Enabled then
		fontString:SetShadowColor(unpack(FontsDB.Shadow.Colour))
		fontString:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
	else
		fontString:SetShadowColor(0, 0, 0, 0)
		fontString:SetShadowOffset(0, 0)
	end
end

local function GetAuraDurationDB(unitFrame, unit, AuraDB)
	if AuraDB.Duration then return AuraDB.Duration end
	local CooldownTextDB = UUF.db.profile.General.CooldownText
	if CooldownTextDB.Advanced then return UUF:GetUnitDB(unitFrame, unit).Auras.AuraDuration end
	return CooldownTextDB
end

local function GetAuraDurationFormatter(DurationDB)
	local decimalThreshold = 0
	if DurationDB then
		if DurationDB.ShowDecimalSeconds then
			decimalThreshold = DurationDB.DecimalThreshold or 3
		elseif DurationDB.ShowDecimalsUnderThree then
			decimalThreshold = 3
		end
	end
	local formatter = decimalThreshold > 0 and AuraDurationFormatter or AuraDurationNoDecimalsFormatter
	local breakpoints = {}
	for _, breakpoint in ipairs(UUF.db.profile.General.CooldownText.CooldownBreakpoints) do
		if decimalThreshold > 0 or breakpoint.displayStyle ~= "decimalSeconds" then
			local breakpointCopy = {}
			for key, value in pairs(breakpoint) do breakpointCopy[key] = value end
			if breakpointCopy.displayStyle == "decimalSeconds" then
				breakpointCopy.threshold = 0
			elseif breakpointCopy.displayStyle == "secondsOnly" then
				breakpointCopy.threshold = decimalThreshold > 0 and decimalThreshold or 0
				breakpointCopy.min = 1
			end
			breakpoints[#breakpoints + 1] = breakpointCopy
		end
	end
	formatter:SetBreakpoints(breakpoints)
	return formatter
end

local function CreateAuraButton(container, button)
	local size = container.size or 16
	button:SetSize(size, size)
	button:EnableMouse(true)

	local cooldown = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	cooldown:SetAllPoints()
	cooldown:SetDrawSwipe(container.showCooldownSwipe ~= false)
	cooldown:SetDrawEdge(false)
	cooldown:SetDrawBling(false)
	cooldown:SetReverse(container.inverseCooldownSwipe == true)
	cooldown:SetHideCountdownNumbers(not container.showDuration)
	button.Cooldown = cooldown
	button:SetDurationCooldown(cooldown)

	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetAllPoints()
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	button.Icon = icon
	button:SetIcon(icon)

	local textParent
	if container.showCount then
		textParent = CreateFrame("Frame", nil, button)
		textParent:SetAllPoints()
		textParent:SetFrameLevel(cooldown:GetFrameLevel() + 1)
	end

	if container.showCount then
		local count = textParent:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		count:SetPoint("BOTTOMRIGHT", -1, 0)
		button.Count = count
		button:SetApplicationCount(count, {
			formatter = container.countFormatter,
		})
	end

	if container.showBuffBorder or container.showDebuffBorder then
		local border = button:CreateTexture(nil, "OVERLAY")
		border:SetAllPoints()
		button.Border = border
		button:SetAuraBorder(border, {
			showIcon = container.showBorderSymbol,
			showWhenHarmful = container.showDebuffBorder,
			showWhenHelpful = container.showBuffBorder,
			style = container.borderStyle,
		})
	end

	if container.cancelButton then
		button:SetCancelAuraButtons(container.cancelButton)
	end
end

local function AddAuraFilter(filters, auraType, source, token, exclusions)
	local filter = auraType
	if source then filter = filter .. "|" .. source end
	if token then filter = filter .. "|" .. token end
	if exclusions then
		for _, exclusion in ipairs(exclusions) do
			local negatedExclusion = exclusion:sub(1, 1) == "!" and exclusion:sub(2) or "!" .. exclusion
			if negatedExclusion ~= token then filter = filter .. "|" .. negatedExclusion end
		end
	end
	filters[#filters + 1] = filter
end

local function GetAuraFilters(AuraDB, auraType)
	local filters = {}
	local playerTokens = {}
	local otherTokens = {}
	local showAllPlayer, showAllOthers
	for _, filter in ipairs(UUF.AURA_FILTERS) do
		if AuraDB.Filters[filter.Key] then
			if filter.Source == "PLAYER" then
				if filter.Token then playerTokens[#playerTokens + 1] = filter.Token else showAllPlayer = true end
			else
				if filter.Token then otherTokens[#otherTokens + 1] = filter.Token else showAllOthers = true end
			end
		end
	end

	if showAllPlayer then
		AddAuraFilter(filters, auraType, "PLAYER")
	else
		local playerExclusions = {}
		for _, token in ipairs(playerTokens) do
			AddAuraFilter(filters, auraType, "PLAYER", token, playerExclusions)
			playerExclusions[#playerExclusions + 1] = token
		end
	end

	if showAllOthers then
		AddAuraFilter(filters, auraType, "!PLAYER")
	else
		local otherExclusions = {}
		for _, token in ipairs(otherTokens) do
			AddAuraFilter(filters, auraType, "!PLAYER", token, otherExclusions)
			otherExclusions[#otherExclusions + 1] = token
		end
	end

	return filters, playerTokens, otherTokens, showAllPlayer, showAllOthers
end

local function CreateAuraContainer(unitFrame, unit, auraKey)
	local AuraDB = GetAuraDB(unitFrame, unit, auraKey)
	local container = unitFrame:CreateAuras({
		maxWidth = AuraDB and math.max((AuraDB.Size + AuraDB.Layout[5]) * AuraDB.Wrap - AuraDB.Layout[5], 1) or 1,
		initialAnchor = auraKey,
		growthX = AuraDB and AuraDB.GrowthDirection == "LEFT" and "LEFT" or "RIGHT",
		growthY = AuraDB and AuraDB.WrapDirection or "UP",
	})
	if not container then return end

	local state = {Groups = {}, ActiveGroups = {}, ActiveSpellIDGroups = {}, Size = AuraDB and AuraDB.Size or 1, UnitFrame = unitFrame, Unit = unit, AuraKey = auraKey}
	AuraContainerState[container] = state
	container.size = state.Size
	container.showCount = true
	container.showDuration = true
	container.showCooldownSwipe = true
	container.inverseCooldownSwipe = true
	container.showBuffBorder = true
	container.showDebuffBorder = true
	container.borderStyle = AuraButtonBorderStyle.Color
	container.durationFormatter = GetAuraDurationFormatter(AuraDB and GetAuraDurationDB(unitFrame, unit, AuraDB))
	return container
end

local function UpdateAuraContainer(container, unitFrame, unit, auraKey)
	if not container then return end
	local AuraDB = GetAuraDB(unitFrame, unit, auraKey)
	local state = AuraContainerState[container]
	if not AuraDB then
		for _, groupKey in pairs(state.Groups) do container:SetAuraGroupMaxFrameCount(groupKey, 0) end
		container:Hide()
		return
	end
	local auraType = AuraDB.Type == "Debuffs" and "HARMFUL" or "HELPFUL"
	local hasSpellIDs = next(AuraDB.SpellIDs)
	local candidateFilters = hasSpellIDs and {includeSpellIDs = AuraDB.SpellIDs} or nil
	state.Size = AuraDB.Size
	container.size = AuraDB.Size
	local DurationDB = GetAuraDurationDB(unitFrame, unit, AuraDB)
	container.showCount = not AuraDB.Count.HideStacks
	container.showDuration = not DurationDB.HideDuration
	container.showCooldownSwipe = DurationDB.ShowCooldownSwipe ~= false
	container.inverseCooldownSwipe = DurationDB.InverseCooldownSwipe == true
	container.showBuffBorder = AuraDB.ShowType == true
	container.showDebuffBorder = AuraDB.ShowType == true
	container.borderStyle = AuraButtonBorderStyle.Color
	container.durationFormatter = GetAuraDurationFormatter(DurationDB)
	local filters, playerTokens, otherTokens, showAllPlayer, showAllOthers = GetAuraFilters(AuraDB, auraType)
	local hasAuraFilters = #filters > 0
	local activeSpellIDGroups = {}
	if not hasAuraFilters and not hasSpellIDs then
		AddAuraFilter(filters, auraType)
	elseif hasSpellIDs then
		if not hasAuraFilters then
			AddAuraFilter(filters, auraType)
			activeSpellIDGroups[filters[#filters]] = true
		else
			if not showAllPlayer then
				AddAuraFilter(filters, auraType, "PLAYER", nil, playerTokens)
				activeSpellIDGroups[filters[#filters]] = true
			end
			if not showAllOthers then
				AddAuraFilter(filters, auraType, "!PLAYER", nil, otherTokens)
				activeSpellIDGroups[filters[#filters]] = true
			end
		end
	end
	local activeGroups = {}
	local layout = {
		elementWidth = state.Size,
		elementHeight = state.Size,
		elementSpacingX = AuraDB.Layout[5],
		elementSpacingY = AuraDB.Layout[5],
	}
	local reverse = AuraDB.Sorting == "BLIZZARD_REVERSED" or AuraDB.Sorting == "DURATION_REVERSED"
	local sortMethod = (AuraDB.Sorting == "DURATION" or AuraDB.Sorting == "DURATION_REVERSED") and AuraContainerSortMethod.ExpirationOnly or AuraContainerSortMethod.Default
	local sortDirection = reverse and AuraContainerSortDirection.Reverse or AuraContainerSortDirection.Normal
	for _, filter in ipairs(filters) do
		local groupKey = state.Groups[filter]
		local groupCandidateFilters = activeSpellIDGroups[filter] and candidateFilters or nil
		if not groupKey then
			container.size = state.Size
			groupKey = container:AddGroup(filter, {
				candidateFilters = groupCandidateFilters,
				maxFrameCount = 0,
				layout = layout,
				sortMethod = sortMethod,
				sortDirection = sortDirection,
				initializeFrame = GenerateClosure(CreateAuraButton, container),
			})
			state.Groups[filter] = groupKey
		end
		activeGroups[filter] = true
		container:SetAuraGroupCandidateFilters(groupKey, groupCandidateFilters)
		container:SetAuraGroupLayout(groupKey, layout)
		container:SetAuraGroupSortMethod(groupKey, sortMethod, sortDirection)
	end
	state.ActiveGroups = activeGroups
	state.ActiveSpellIDGroups = activeSpellIDGroups

	local width = math.max((state.Size + AuraDB.Layout[5]) * AuraDB.Wrap - AuraDB.Layout[5], 1)
	local rows = math.max(math.ceil(AuraDB.Num / AuraDB.Wrap), 1)
	local height = math.max((state.Size + AuraDB.Layout[5]) * rows - AuraDB.Layout[5], 1)
	local anchorParent = AuraDB.AnchorParent == "Health" and unitFrame.Health or unitFrame
	local centered = AuraDB.GrowthDirection == "CENTER"
	local containerAnchor = centered and (AuraDB.WrapDirection == "DOWN" and "TOP" or "BOTTOM") or AuraDB.Layout[1]
	local auraAnchor = centered and (AuraDB.WrapDirection == "DOWN" and "TOPLEFT" or "BOTTOMLEFT") or AuraDB.Layout[1]
	container:ClearAllPoints()
	container:SetPoint(containerAnchor, anchorParent, AuraDB.Layout[2], AuraDB.Layout[3], AuraDB.Layout[4])
	container:SetSize(width, height)
	container:SetFrameStrata(UUF:GetUnitDB(unitFrame, unit).Auras.FrameStrata)
	container:SetAuraLayoutRowWidth(width)
	container:SetAuraLayoutAnchorPoint(auraAnchor)
	container:SetAuraLayoutGrowthDirection(AuraDB.GrowthDirection == "LEFT" and -1 or 1, AuraDB.WrapDirection == "DOWN" and -1 or 1)
end

function UUF:UpdateUnitAuraEligibility(unitFrame, unit)
	if UUF.AURA_TEST_MODE or not unitFrame or not unit then return end
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	if not AurasDB then return end
	local unitToken = unitFrame.unit
	if not unitToken then unitToken = unit == "partyplayer" and "player" or unit end
	local canAssist = UnitCanAssist("player", unitToken)
	local assistabilityKnown = not UUF:IsSecretValue(canAssist)
	for auraKey, container in pairs(unitFrame.AuraContainers or {}) do
		local AuraDB = AurasDB.Containers[auraKey]
		local state = container and AuraContainerState[container]
		if AuraDB and state then
			local auraType = AuraDB.Type == "Debuffs" and "HARMFUL" or "HELPFUL"
			local spellIDsEligible = assistabilityKnown and (auraType == "HELPFUL" and canAssist or auraType == "HARMFUL" and not canAssist)
			local shown = false
			container:SetUnit(unitToken)
			for configuredFilter, configuredGroupKey in pairs(state.Groups) do
				local groupShown = state.ActiveGroups[configuredFilter] and (not state.ActiveSpellIDGroups[configuredFilter] or spellIDsEligible)
				container:SetAuraGroupMaxFrameCount(configuredGroupKey, groupShown and AuraDB.Num or 0)
				if groupShown then shown = true end
			end
			container:SetShown(shown)
			container:UpdateAllAuras()
		end
	end
end

local function SyncAuraContainers(unitFrame, unit)
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	if not AurasDB then return end
	for auraKey, container in pairs(unitFrame.AuraContainers) do
		if not AurasDB.Containers[auraKey] then
			UpdateAuraContainer(container, unitFrame, unit, auraKey)
			unitFrame.AuraContainers[auraKey] = nil
			AuraContainerState[container].AuraKey = nil
		end
	end
	for _, auraKey in ipairs(UUF:GetAuraContainerKeys(AurasDB)) do
		local container = unitFrame.AuraContainers[auraKey]
		if not container then
			for _, availableContainer in ipairs(unitFrame.AuraContainerPool) do
				local state = AuraContainerState[availableContainer]
				if not state.AuraKey then
					container = availableContainer
					state.AuraKey = auraKey
					unitFrame.AuraContainers[auraKey] = container
					break
				end
			end
		end
		if container then UpdateAuraContainer(container, unitFrame, unit, auraKey) end
	end
end

function UUF:CreateUnitAuras(unitFrame, unit)
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	if not AurasDB then return end
	unitFrame.AuraContainers = {}
	unitFrame.AuraContainerPool = {}
	for _ = 1, UUF.MAX_AURA_CONTAINERS do
		local container = CreateAuraContainer(unitFrame, unit, nil)
		if container then unitFrame.AuraContainerPool[#unitFrame.AuraContainerPool + 1] = container end
	end
	AuraUnitFrames[unitFrame] = unit
	UUF:UpdateUnitAuras(unitFrame, unit)
end

function UUF:UpdateUnitAuras(unitFrame, unit)
	if not unitFrame or not unit then return end
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	if not AurasDB then return end
	AuraUnitFrames[unitFrame] = unit
	SyncAuraContainers(unitFrame, unit)
	UUF:UpdateUnitAuraEligibility(unitFrame, unit)
	if UUF.AURA_TEST_MODE then UUF:CreateTestAuras(unitFrame, unit) end
end

function UUF:UpdateUnitAurasStrata(unit)
	if not unit then return end
	if unit == "party" then
		for index = 1, UUF.MAX_PARTY_FRAMES do UUF:UpdateUnitAurasStrata("party" .. index) end
		if UUF.PARTYPLAYER then UUF:UpdateUnitAurasStrata("partyplayer") end
		return
	elseif unit == "augmentation" then
		UUF:ForEachAugmentationRaidFrame(function(raidFrame, frameUnit)
			if not frameUnit then return end
			local AurasDB = UUF:GetUnitDB(raidFrame, frameUnit).Auras
			if raidFrame.AuraContainers then for _, container in pairs(raidFrame.AuraContainers) do container:SetFrameStrata(AurasDB.FrameStrata) end end
		end, false)
		return
	end
	local unitFrame = UUF[unit:upper()]
	if not unitFrame and unit:match("^raid") then
		UUF:ForEachRaidFrame(function(raidFrame, frameUnit) if frameUnit == unit then unitFrame = raidFrame end end, false)
	end
	if not unitFrame then return end
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	if unitFrame.AuraContainers then for _, container in pairs(unitFrame.AuraContainers) do container:SetFrameStrata(AurasDB.FrameStrata) end end
end

local function HideFakeAuras(container)
	if not container then return end
	for index = 1, container.maxFake or 0 do
		local button = container["fake" .. index]
		if button then button:Hide() end
	end
end

local function CreateFakeAuraButtonBorder(button)
	local top = button:CreateTexture(nil, "OVERLAY", nil, 7)
	top:SetColorTexture(0, 0, 0, 1)
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetHeight(1)
	local bottom = button:CreateTexture(nil, "OVERLAY", nil, 7)
	bottom:SetColorTexture(0, 0, 0, 1)
	bottom:SetPoint("BOTTOMLEFT")
	bottom:SetPoint("BOTTOMRIGHT")
	bottom:SetHeight(1)
	local left = button:CreateTexture(nil, "OVERLAY", nil, 7)
	left:SetColorTexture(0, 0, 0, 1)
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")
	left:SetWidth(1)
	local right = button:CreateTexture(nil, "OVERLAY", nil, 7)
	right:SetColorTexture(0, 0, 0, 1)
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")
	right:SetWidth(1)
end

local function UpdateFakeAuras(container, unitFrame, unit, AuraDB, texture)
	if not container then return end
	if not AuraDB then
		HideFakeAuras(container)
		container:Hide()
		return
	end
	local state = AuraContainerState[container]
	if state then
		for _, groupKey in pairs(state.Groups) do container:SetAuraGroupMaxFrameCount(groupKey, 0) end
		container:UpdateAllAuras()
	end
	container:Show()
	local anchorParent = AuraDB.AnchorParent == "Health" and unitFrame.Health or unitFrame
	local centered = AuraDB.GrowthDirection == "CENTER"
	local containerAnchor = centered and (AuraDB.WrapDirection == "DOWN" and "TOP" or "BOTTOM") or AuraDB.Layout[1]
	local auraAnchor = centered and (AuraDB.WrapDirection == "DOWN" and "TOPLEFT" or "BOTTOMLEFT") or AuraDB.Layout[1]
	container:ClearAllPoints()
	container:SetPoint(containerAnchor, anchorParent, AuraDB.Layout[2], AuraDB.Layout[3], AuraDB.Layout[4])
	if centered then
		local columns = math.min(AuraDB.Num, AuraDB.Wrap)
		local width = math.max((AuraDB.Size + AuraDB.Layout[5]) * columns - AuraDB.Layout[5], 1)
		local rows = math.max(math.ceil(AuraDB.Num / AuraDB.Wrap), 1)
		container:SetSize(width, math.max((AuraDB.Size + AuraDB.Layout[5]) * rows - AuraDB.Layout[5], 1))
	end
	container:SetFrameStrata(UUF:GetUnitDB(unitFrame, unit).Auras.FrameStrata)
	for index = 1, AuraDB.Num do
		local button = container["fake" .. index]
		if not button then
			button = CreateFrame("Button", nil, container)
			CreateFakeAuraButtonBorder(button)
			button.Icon = button:CreateTexture(nil, "BORDER")
			button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
			button.Count = button:CreateFontString(nil, "OVERLAY")
			button.Duration = button:CreateFontString(nil, "OVERLAY")
			container["fake" .. index] = button
		end
		local row = math.floor((index - 1) / AuraDB.Wrap)
		local column = (index - 1) % AuraDB.Wrap
		local x = column * (AuraDB.Size + AuraDB.Layout[5]) * (AuraDB.GrowthDirection == "LEFT" and -1 or 1)
		local y = row * (AuraDB.Size + AuraDB.Layout[5]) * (AuraDB.WrapDirection == "DOWN" and -1 or 1)
		button:SetSize(AuraDB.Size, AuraDB.Size)
		button:ClearAllPoints()
		button:SetPoint(auraAnchor, container, auraAnchor, x, y)
		button.Icon:SetTexture(texture)
		button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		ApplyFontStyle(button.Count, button, AuraDB.Count.Layout, AuraDB.Count.FontSize, AuraDB.Count.Colour, unitFrame, unit)
		button.Count:SetText(index)
		button.Count:SetShown(not AuraDB.Count.HideStacks)
		local CooldownTextDB = GetAuraDurationDB(unitFrame, unit, AuraDB)
		local fontSize = CooldownTextDB.FontSize
		if CooldownTextDB.ScaleByIconSize then fontSize = math.max(CooldownTextDB.FontSize * AuraDB.Size / 36, 1) end
		ApplyFontStyle(button.Duration, button, CooldownTextDB.Layout, fontSize, CooldownTextDB.Colour, unitFrame, unit)
		button.Duration:SetText("10m")
		button.Duration:SetShown(not CooldownTextDB.HideDuration)
		button:Show()
	end
	for index = AuraDB.Num + 1, container.maxFake or AuraDB.Num do
		local button = container["fake" .. index]
		if button then button:Hide() end
	end
	container.maxFake = math.max(container.maxFake or 0, AuraDB.Num)
end

function UUF:CreateTestAuras(unitFrame, unit)
	if not unitFrame or not unit then return end
	local AurasDB = UUF:GetUnitDB(unitFrame, unit).Auras
	if UUF.AURA_TEST_MODE then
		for auraKey, container in pairs(unitFrame.AuraContainers or {}) do
			local AuraDB = AurasDB.Containers[auraKey]
			UpdateFakeAuras(container, unitFrame, unit, AuraDB, AuraDB and AuraDB.Type == "Debuffs" and 135768 or 135769)
		end
		return
	end
	if unitFrame.AuraContainers then for _, container in pairs(unitFrame.AuraContainers) do HideFakeAuras(container) end end
	UUF:UpdateUnitAuras(unitFrame, unit)
end
