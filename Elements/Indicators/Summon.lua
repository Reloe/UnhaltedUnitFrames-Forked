local _, UUF = ...

function UUF:CreateUnitSummonIndicator(unitFrame, unit)
	local SummonDB = UUF:GetUnitDB(unitFrame, unit).Indicators.Summon
	if not SummonDB then return end

	local SummonIndicator = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_SummonIndicator", "OVERLAY")
	SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
	SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
	unitFrame.UUFSummonIndicator = SummonIndicator

	if SummonDB.Enabled then
		unitFrame.SummonIndicator = SummonIndicator
	else
		SummonIndicator:Hide()
	end

	return SummonIndicator
end

function UUF:UpdateUnitSummonIndicator(unitFrame, unit)
	local SummonDB = UUF:GetUnitDB(unitFrame, unit).Indicators.Summon
	if not SummonDB then return end

	if SummonDB.Enabled then
		unitFrame.SummonIndicator = unitFrame.SummonIndicator or unitFrame.UUFSummonIndicator or UUF:CreateUnitSummonIndicator(unitFrame, unit)
		if not unitFrame:IsElementEnabled("SummonIndicator") then unitFrame:EnableElement("SummonIndicator") end

		unitFrame.SummonIndicator:ClearAllPoints()
		unitFrame.SummonIndicator:SetSize(SummonDB.Size, SummonDB.Size)
		unitFrame.SummonIndicator:SetPoint(SummonDB.Layout[1], unitFrame.HighLevelContainer, SummonDB.Layout[2], SummonDB.Layout[3], SummonDB.Layout[4])
		unitFrame.SummonIndicator:ForceUpdate()
	elseif unitFrame.SummonIndicator then
		if unitFrame:IsElementEnabled("SummonIndicator") then unitFrame:DisableElement("SummonIndicator") end
		unitFrame.SummonIndicator:Hide()
		unitFrame.SummonIndicator = nil
	end
end
