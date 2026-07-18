local _, UUF = ...

local function CreateUnitTag(unitFrame, unit, tagDB)
	local TagDB = UUF:GetUnitDB(unitFrame, unit).Tags[tagDB]
	local FontsDB = UUF:GetFontSettings(unitFrame, unit)
	local FontMedia = UUF:GetFontMedia(unitFrame, unit)

	if not unitFrame.Tags[tagDB] then
		unitFrame.Tags[tagDB] = unitFrame.HighLevelContainer:CreateFontString(UUF:FetchFrameName(unit) .. "_" .. tagDB, "ARTWORK", "GameFontNormal")
		unitFrame.Tags[tagDB]:SetFont(FontMedia, TagDB.FontSize, FontsDB.FontFlag)
		unitFrame.Tags[tagDB]:SetVertexColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
		if FontsDB.Shadow.Enabled then
			unitFrame.Tags[tagDB]:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
			unitFrame.Tags[tagDB]:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
		else
			unitFrame.Tags[tagDB]:SetShadowColor(0, 0, 0, 0)
			unitFrame.Tags[tagDB]:SetShadowOffset(0, 0)
		end
		unitFrame.Tags[tagDB]:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4])
		unitFrame.Tags[tagDB]:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))
		if TagDB.Layout[1] == "TOPLEFT" or TagDB.Layout[1] == "TOP" or TagDB.Layout[1] == "TOPRIGHT" then
			unitFrame.Tags[tagDB]:SetJustifyV("TOP")
		elseif TagDB.Layout[1] == "BOTTOMLEFT" or TagDB.Layout[1] == "BOTTOM" or TagDB.Layout[1] == "BOTTOMRIGHT" then
			unitFrame.Tags[tagDB]:SetJustifyV("BOTTOM")
		else
			unitFrame.Tags[tagDB]:SetJustifyV("MIDDLE")
		end
		if TagDB.Tag and string.find(TagDB.Tag, ":target", 1, true) then
			unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag, (unit == "partyplayer" and "player" or unit) .. "target")
		else
			unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
		end
		unitFrame.Tags[tagDB].UUFTagString = TagDB.Tag
		unitFrame.Tags[tagDB].UUFTagUnit = unit
	end
end

function UUF:UpdateUnitTag(unitFrame, unit, tagDB)
	local TagDB = UUF:GetUnitDB(unitFrame, unit).Tags[tagDB]
	local FontsDB = UUF:GetFontSettings(unitFrame, unit)
	local FontMedia = UUF:GetFontMedia(unitFrame, unit)

	if not unitFrame.Tags[tagDB] then CreateUnitTag(unitFrame, unit, tagDB) end
	if not unitFrame.Tags[tagDB] then return end

	unitFrame.Tags[tagDB]:SetFont(FontMedia, TagDB.FontSize, FontsDB.FontFlag)
	unitFrame.Tags[tagDB]:SetVertexColor(TagDB.Colour[1], TagDB.Colour[2], TagDB.Colour[3], 1)
	if FontsDB.Shadow.Enabled then
		unitFrame.Tags[tagDB]:SetShadowColor(FontsDB.Shadow.Colour[1], FontsDB.Shadow.Colour[2], FontsDB.Shadow.Colour[3], FontsDB.Shadow.Colour[4])
		unitFrame.Tags[tagDB]:SetShadowOffset(FontsDB.Shadow.XPos, FontsDB.Shadow.YPos)
	else
		unitFrame.Tags[tagDB]:SetShadowColor(0, 0, 0, 0)
		unitFrame.Tags[tagDB]:SetShadowOffset(0, 0)
	end
	unitFrame.Tags[tagDB]:ClearAllPoints()
	unitFrame.Tags[tagDB]:SetPoint(TagDB.Layout[1], unitFrame.HighLevelContainer, TagDB.Layout[2], TagDB.Layout[3], TagDB.Layout[4])
	unitFrame.Tags[tagDB]:SetJustifyH(UUF:SetJustification(TagDB.Layout[1]))
	if TagDB.Layout[1] == "TOPLEFT" or TagDB.Layout[1] == "TOP" or TagDB.Layout[1] == "TOPRIGHT" then
		unitFrame.Tags[tagDB]:SetJustifyV("TOP")
	elseif TagDB.Layout[1] == "BOTTOMLEFT" or TagDB.Layout[1] == "BOTTOM" or TagDB.Layout[1] == "BOTTOMRIGHT" then
		unitFrame.Tags[tagDB]:SetJustifyV("BOTTOM")
	else
		unitFrame.Tags[tagDB]:SetJustifyV("MIDDLE")
	end
	if unitFrame.Tags[tagDB].UUFTagString ~= TagDB.Tag or unitFrame.Tags[tagDB].UUFTagUnit ~= unit then
		unitFrame.Tags[tagDB].extraUnits = nil
		if TagDB.Tag and string.find(TagDB.Tag, ":target", 1, true) then
			unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag, (unit == "partyplayer" and "player" or unit) .. "target")
		else
			unitFrame:Tag(unitFrame.Tags[tagDB], TagDB.Tag)
		end
		unitFrame.Tags[tagDB].UUFTagString = TagDB.Tag
		unitFrame.Tags[tagDB].UUFTagUnit = unit
	end
	unitFrame.Tags[tagDB]:UpdateTag()
end

function UUF:CreateUnitTags(unitFrame, unit)
    unitFrame.Tags = unitFrame.Tags or {}
    for tagName, _ in pairs(UUF:GetUnitDB(unitFrame, unit).Tags) do
        CreateUnitTag(unitFrame, unit, tagName)
    end
end

function UUF:UpdateUnitTags(unit, tagName)
	if not unit then return end
	local UnitDB = UUF:GetUnitDB(nil, unit)
	if not UnitDB or not UnitDB.Tags then return end
	UUF.SEPARATOR = UUF.db.profile.General.Separator or "||"
	UUF.TOT_SEPARATOR = UUF.db.profile.General.ToTSeparator or "»"

	local function UpdateFrameTags(unitFrame, frameUnit)
		if not unitFrame then return end
		if tagName then
			UUF:UpdateUnitTag(unitFrame, frameUnit, tagName)
		else
			for configuredTag in pairs(UnitDB.Tags) do UUF:UpdateUnitTag(unitFrame, frameUnit, configuredTag) end
		end
	end

	if unit == "boss" then
		for i = 1, UUF.MAX_BOSS_FRAMES do UpdateFrameTags(UUF["BOSS" .. i], "boss" .. i) end
	elseif unit == "party" then
		for i = 1, UUF.MAX_PARTY_FRAMES do UpdateFrameTags(UUF["PARTY" .. i], "party" .. i) end
		UpdateFrameTags(UUF.PARTYPLAYER, "partyplayer")
	elseif unit == "raid" then
		UUF:ForEachRaidFrame(UpdateFrameTags, true, UUF.RAID_TEST_MODE)
	elseif unit == "augmentation" then
		UUF:ForEachAugmentationRaidFrame(UpdateFrameTags, false)
	else
		UpdateFrameTags(UUF[unit:upper()], unit)
	end
end
