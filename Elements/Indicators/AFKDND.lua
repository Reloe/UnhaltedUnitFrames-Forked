local _, UUF = ...

UUF.AFKDNDIndicatorFrames = UUF.AFKDNDIndicatorFrames or {}

local AFKDND_DEFAULTS = {
	Enabled = true,
	FontSize = 12,
	Layout = {"CENTER", "CENTER", 0, 0},
	Colour = {1, 1, 1, 1},
}

local AFKDNDUpdateFrame = CreateFrame("Frame")
AFKDNDUpdateFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
AFKDNDUpdateFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
AFKDNDUpdateFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
AFKDNDUpdateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
AFKDNDUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
AFKDNDUpdateFrame:SetScript("OnEvent", function()
	for unitFrame, unit in pairs(UUF.AFKDNDIndicatorFrames) do
		UUF:UpdateAFKDNDIndicatorState(unitFrame, unit)
	end
end)

function UUF:GetAFKDNDIndicatorDB(unitFrame, unit)
	local UnitDB = UUF:GetUnitDB(unitFrame, unit)
	if not UnitDB or not UnitDB.Indicators then return AFKDND_DEFAULTS end
	UnitDB.Indicators.AFKDND = UnitDB.Indicators.AFKDND or {}
	local IndicatorDB = UnitDB.Indicators.AFKDND
	if IndicatorDB.Enabled == nil then IndicatorDB.Enabled = AFKDND_DEFAULTS.Enabled end
	IndicatorDB.FontSize = IndicatorDB.FontSize or AFKDND_DEFAULTS.FontSize
	IndicatorDB.Layout = IndicatorDB.Layout or {unpack(AFKDND_DEFAULTS.Layout)}
	IndicatorDB.Colour = IndicatorDB.Colour or {unpack(AFKDND_DEFAULTS.Colour)}
	if IndicatorDB.Colour[4] == nil then IndicatorDB.Colour[4] = 1 end
	return IndicatorDB
end

function UUF:UpdateAFKDNDIndicatorState(unitFrame, unit)
	if not unitFrame or not unitFrame.AFKDNDIndicator then return end
	local stateUnit = unit == "partyplayer" and "player" or unit
	if UnitIsAFK(stateUnit) then
		unitFrame.AFKDNDIndicator:SetText("AFK")
		unitFrame.AFKDNDIndicator:Show()
	elseif UnitIsDND(stateUnit) then
		unitFrame.AFKDNDIndicator:SetText("DND")
		unitFrame.AFKDNDIndicator:Show()
	else
		unitFrame.AFKDNDIndicator:Hide()
	end
end

function UUF:UnregisterAFKDNDIndicatorFrame(unitFrame)
	if not unitFrame then return end
	UUF.AFKDNDIndicatorFrames[unitFrame] = nil
	if unitFrame.AFKDNDIndicator then unitFrame.AFKDNDIndicator:Hide() end
end

function UUF:CreateUnitAFKDNDIndicator(unitFrame, unit)
	local IndicatorDB = UUF:GetAFKDNDIndicatorDB(unitFrame, unit)
	local FontsDB = UUF:GetFontSettings(unitFrame, unit)
	local FontMedia = UUF:GetFontMedia(unitFrame, unit)
	local Indicator = unitFrame.HighLevelContainer:CreateFontString(UUF:FetchFrameName(unit) .. "_AFKDNDIndicator", "OVERLAY", "GameFontNormal")
	Indicator:SetFont(FontMedia, IndicatorDB.FontSize, FontsDB.FontFlag)
	Indicator:SetVertexColor(IndicatorDB.Colour[1], IndicatorDB.Colour[2], IndicatorDB.Colour[3], IndicatorDB.Colour[4] or 1)
	Indicator:SetPoint(IndicatorDB.Layout[1], unitFrame.HighLevelContainer, IndicatorDB.Layout[2], IndicatorDB.Layout[3], IndicatorDB.Layout[4])
	Indicator:SetJustifyH(UUF:SetJustification(IndicatorDB.Layout[1]))
	if FontsDB.Shadow.Enabled then
		Indicator:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
		Indicator:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
	else
		Indicator:SetShadowColor(0, 0, 0, 0)
		Indicator:SetShadowOffset(0, 0)
	end
	unitFrame.AFKDNDIndicator = Indicator
	UUF:UpdateUnitAFKDNDIndicator(unitFrame, unit)
	return Indicator
end

function UUF:UpdateUnitAFKDNDIndicator(unitFrame, unit)
	local IndicatorDB = UUF:GetAFKDNDIndicatorDB(unitFrame, unit)
	if IndicatorDB.Enabled then
		unitFrame.AFKDNDIndicator = unitFrame.AFKDNDIndicator or UUF:CreateUnitAFKDNDIndicator(unitFrame, unit)
		local FontsDB = UUF:GetFontSettings(unitFrame, unit)
		local FontMedia = UUF:GetFontMedia(unitFrame, unit)
		unitFrame.AFKDNDIndicator:ClearAllPoints()
		unitFrame.AFKDNDIndicator:SetFont(FontMedia, IndicatorDB.FontSize, FontsDB.FontFlag)
		unitFrame.AFKDNDIndicator:SetVertexColor(IndicatorDB.Colour[1], IndicatorDB.Colour[2], IndicatorDB.Colour[3], IndicatorDB.Colour[4] or 1)
		unitFrame.AFKDNDIndicator:SetPoint(IndicatorDB.Layout[1], unitFrame.HighLevelContainer, IndicatorDB.Layout[2], IndicatorDB.Layout[3], IndicatorDB.Layout[4])
		unitFrame.AFKDNDIndicator:SetJustifyH(UUF:SetJustification(IndicatorDB.Layout[1]))
		if FontsDB.Shadow.Enabled then
			unitFrame.AFKDNDIndicator:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
			unitFrame.AFKDNDIndicator:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
		else
			unitFrame.AFKDNDIndicator:SetShadowColor(0, 0, 0, 0)
			unitFrame.AFKDNDIndicator:SetShadowOffset(0, 0)
		end
		UUF.AFKDNDIndicatorFrames[unitFrame] = unit
		UUF:UpdateAFKDNDIndicatorState(unitFrame, unit)
	elseif unitFrame.AFKDNDIndicator then
		UUF:UnregisterAFKDNDIndicatorFrame(unitFrame)
		unitFrame.AFKDNDIndicator = nil
	end
end
