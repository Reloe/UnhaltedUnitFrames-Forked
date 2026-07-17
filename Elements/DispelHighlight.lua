local _, UUF = ...

local DispelSlots = {
	{Key = "Magic", Level = 5},
	{Key = "Curse", Level = 4},
	{Key = "Disease", Level = 3},
	{Key = "Poison", Level = 2},
	{Key = "Bleed", Level = 1},
}

local DispelHighlightState = setmetatable({}, {__mode = "k"})
local DispelCapabilityEventFrame = CreateFrame("Frame")
local DisabledCandidateFilters = {includeDispelTypes = {}}
local DispelCandidateFilters = {}
for _, dispelSlot in ipairs(DispelSlots) do DispelCandidateFilters[dispelSlot.Key] = {includeDispelTypes = {[dispelSlot.Key] = true}} end

DispelCapabilityEventFrame:RegisterEvent("SPELLS_CHANGED")
DispelCapabilityEventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
DispelCapabilityEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
DispelCapabilityEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
DispelCapabilityEventFrame:RegisterEvent("UNIT_FACTION")
DispelCapabilityEventFrame:SetScript("OnEvent", function(_, event, eventUnit)
	for unitFrame, state in pairs(DispelHighlightState) do
		local unit = state.Unit
		local unitToken = unitFrame.unit
		if not unitToken then unitToken = unit == "partyplayer" and "player" or unit end
		local update = event == "SPELLS_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "UNIT_FACTION" and (eventUnit == "player" or unitToken == eventUnit) or event == "PLAYER_TARGET_CHANGED" and unit == "target" or event == "PLAYER_FOCUS_CHANGED" and unit == "focus"
		if update then UUF:UpdateUnitDispelHighlight(unitFrame, unit) end
	end
end)

function UUF:CreateUnitDispelHighlight(unitFrame, unit)
	local container = unitFrame:CreateAuras({maxWidth = 1, initialAnchor = "CENTER"})
	if not container then return end
	local state = {Unit = unit, Slots = {}, EnabledTypes = {}}
	local DispelHighlightDB = UUF:GetUnitDB(unitFrame, unit).HealthBar.DispelHighlight
	DispelHighlightState[unitFrame] = state
	container.maxCols = 1
	container.size = 1
	container.spacing = -1
	container.CreateButton = function(_, options, button)
		button:SetSize(1, 1)
		button:SetFrameLevel(unitFrame.Health:GetFrameLevel() + options.Level)
		button:EnableMouse(false)
		local texture = button:CreateTexture(nil, "ARTWORK", nil, 3)
		texture:SetBlendMode("BLEND")
		if DispelHighlightDB.Style == "GRADIENT" then
			texture:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 1, -1)
			texture:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -1, 1)
			texture:SetTexture("Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png")
			texture:SetAlpha(1)
		else
			local statusBarTexture = unitFrame.Health:GetStatusBarTexture()
			texture:SetPoint("TOPLEFT", unitFrame.Health, "TOPLEFT")
			texture:SetPoint("BOTTOMRIGHT", statusBarTexture or unitFrame.Health, "BOTTOMRIGHT")
			texture:SetColorTexture(1, 1, 1, 1)
			texture:SetAlpha(0.75)
		end
		local colour = UUF.db.profile.General.Colours.Dispel[options.DispelType]
		texture:SetVertexColor(colour[1], colour[2], colour[3])
	end

	for index, dispelSlot in ipairs(DispelSlots) do
		container:AddSlot("HARMFUL|DISPELLABLE", {
			candidateFilters = DisabledCandidateFilters,
			DispelType = dispelSlot.Key,
			Level = dispelSlot.Level,
		})
		state.Slots[dispelSlot.Key] = container:GetDebugName() .. index
	end
	container:SetPoint("CENTER", unitFrame.Health, "CENTER")
	container:SetSize(1, 1)
	unitFrame.DispelHighlight = container
	UUF:UpdateUnitDispelHighlight(unitFrame, unit)
end

function UUF:UpdateUnitDispelHighlight(unitFrame, unit)
	local container = unitFrame.DispelHighlight
	local state = DispelHighlightState[unitFrame]
	if not container or not state then return end
	state.Unit = unit
	local unitToken = unitFrame.unit
	if not unitToken then unitToken = unit == "partyplayer" and "player" or unit end
	local DispelHighlightDB = UUF:GetUnitDB(unitFrame, unit).HealthBar.DispelHighlight
	local onlyShowDispellableByPlayer = DispelHighlightDB.OnlyShowDispellableByPlayer ~= false
	local dispelTypes = onlyShowDispellableByPlayer and UUF.LD:GetMyDispelTypes() or nil
	for dispelType, slotKey in pairs(state.Slots) do
		local typeEnabled = not onlyShowDispellableByPlayer or dispelTypes and dispelTypes[dispelType] and true or false
		if state.EnabledTypes[dispelType] ~= typeEnabled then
			state.EnabledTypes[dispelType] = typeEnabled
			container:SetAuraSlotCandidateFilters(slotKey, typeEnabled and DispelCandidateFilters[dispelType] or DisabledCandidateFilters)
		end
	end
	local canAssist = UnitCanAssist("player", unitToken)
	local enabled = DispelHighlightDB.Enabled and not UUF:IsSecretValue(canAssist) and canAssist
	container:SetUnit(unitToken)
	container:SetShown(enabled)
	if not enabled then return end
	container:UpdateAllAuras()
end
