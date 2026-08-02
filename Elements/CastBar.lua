local _, UUF = ...

local function SetCastBarColour(castBar, unit, CastBarDB)
	local r, g, b, a
	if CastBarDB.ColourByClass then
		local unitForClass = unit == "pet" and "player" or unit
		local hasClassColour
		hasClassColour, r, g, b = UUF:GetUnitClassColour(unitForClass, nil, unit)
		if hasClassColour then a = CastBarDB.ForegroundOpacity end
	end
	if not r then r, g, b, a = unpack(CastBarDB.Foreground) end
	if UUF.IsInterruptOnCooldown and C_CurveUtil.EvaluateColorValueFromBoolean and (castBar.casting or castBar.channeling or castBar.empowering) and castBar.notInterruptible ~= nil and UnitCanAttack("player", unit) and UUF:IsInterruptOnCooldown() then
		local CDR, CDG, CDB, CDA = unpack(CastBarDB.InterruptCooldownColour or CastBarDB.InterruptOnCooldownColour)
		r = C_CurveUtil.EvaluateColorValueFromBoolean(castBar.notInterruptible, r, CDR)
		g = C_CurveUtil.EvaluateColorValueFromBoolean(castBar.notInterruptible, g, CDG)
		b = C_CurveUtil.EvaluateColorValueFromBoolean(castBar.notInterruptible, b, CDB)
		a = C_CurveUtil.EvaluateColorValueFromBoolean(castBar.notInterruptible, a or 1, CDA or a or 1)
	end
	castBar:SetStatusBarColor(r, g, b, a)
end

function UUF:CreateUnitCastBar(unitFrame, unit)
    local GeneralDB = UUF.db.profile.General
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local CastBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar
    local SpellNameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.SpellName
    local DurationDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.Duration

    local CastBarContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_CastBarContainer", unitFrame, "BackdropTemplate")
    CastBarContainer:SetBackdrop(UUF.BACKDROP)
    CastBarContainer:SetBackdropColor(0, 0, 0, 0)
    CastBarContainer:SetBackdropBorderColor(0, 0, 0, 1)
    CastBarContainer:ClearAllPoints()
    CastBarContainer:SetPoint(CastBarDB.Layout[1], unitFrame, CastBarDB.Layout[2], CastBarDB.Layout[3], CastBarDB.Layout[4])
    if CastBarDB.MatchParentWidth then CastBarContainer:SetWidth(FrameDB.Width) else CastBarContainer:SetWidth(CastBarDB.Width) end
    CastBarContainer:SetHeight(CastBarDB.Height)
    CastBarContainer:SetFrameStrata(CastBarDB.FrameStrata)
    CastBarContainer:Hide()

    local CastBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_CastBar", CastBarContainer)
    CastBar:SetStatusBarTexture(UUF.Media.Foreground)
    CastBar:ClearAllPoints()
    CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
    CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
    CastBar:SetFrameLevel(CastBarContainer:GetFrameLevel() + 1)
    CastBar.timeToHold = CastBarDB.HoldTime
    SetCastBarColour(CastBar, unit, CastBarDB)

    CastBar.Background = CastBar:CreateTexture(nil, "BACKGROUND")
    CastBar.Background:SetAllPoints(CastBar)
    CastBar.Background:SetTexture(UUF.Media.Background)
    CastBar.Background:SetVertexColor(unpack(CastBarDB.Background))

    CastBar.NotInterruptibleOverlay = CastBar:CreateTexture(nil, "ARTWORK", nil, 1)
    CastBar.NotInterruptibleOverlay:SetPoint("TOPLEFT", CastBar:GetStatusBarTexture(), "TOPLEFT")
    CastBar.NotInterruptibleOverlay:SetPoint("BOTTOMRIGHT", CastBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    CastBar.NotInterruptibleOverlay:SetTexture(UUF.Media.Foreground)
    CastBar.NotInterruptibleOverlay:SetVertexColor(unpack(CastBarDB.NotInterruptibleColour))
    CastBar.NotInterruptibleOverlay:SetAlpha(0)

    CastBar.Icon = CastBar:CreateTexture(UUF:FetchFrameName(unit) .. "_CastBarIcon", "ARTWORK")
    CastBar.Icon:SetSize(CastBarDB.Height - 2, CastBarDB.Height - 2)
    CastBar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    CastBar.Icon:ClearAllPoints()
    if CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "LEFT" then
        CastBar.Icon:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
        CastBar:ClearAllPoints()
        CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", CastBarDB.Height - 1, -1)
        CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
    elseif CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "RIGHT" then
        CastBar.Icon:SetPoint("TOPRIGHT", CastBarContainer, "TOPRIGHT", -1, -1)
        CastBar:ClearAllPoints()
        CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
        CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -(CastBarDB.Height - 1), 1)
    elseif not CastBarDB.Icon.Enabled then
        CastBar.Icon:Hide()
        CastBar:ClearAllPoints()
        CastBar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
        CastBar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
    end

    local SpellNameText = CastBar:CreateFontString(UUF:FetchFrameName(unit) .. "_CastBarSpellNameText", "OVERLAY", "GameFontNormal")
    SpellNameText:ClearAllPoints()
    SpellNameText:SetPoint(SpellNameDB.Layout[1], CastBar, SpellNameDB.Layout[2], SpellNameDB.Layout[3], SpellNameDB.Layout[4])
    SpellNameText:SetFont(UUF.Media.Font, SpellNameDB.FontSize, GeneralDB.Fonts.FontFlag)
    SpellNameText:SetTextColor(unpack(SpellNameDB.Colour))
    if GeneralDB.Fonts.Shadow.Enabled then
        SpellNameText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        SpellNameText:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
    else
        SpellNameText:SetShadowColor(0, 0, 0, 0)
        SpellNameText:SetShadowOffset(0, 0)
    end
    SpellNameText:SetJustifyH(UUF:SetJustification(SpellNameDB.Layout[1]))

    local DurationText = CastBar:CreateFontString(UUF:FetchFrameName(unit) .. "_CastBarDurationText", "OVERLAY", "GameFontNormal")
    DurationText:ClearAllPoints()
    DurationText:SetPoint(DurationDB.Layout[1], CastBar, DurationDB.Layout[2], DurationDB.Layout[3], DurationDB.Layout[4])
    DurationText:SetFont(UUF.Media.Font, DurationDB.FontSize, GeneralDB.Fonts.FontFlag)
    DurationText:SetTextColor(unpack(DurationDB.Colour))
    if GeneralDB.Fonts.Shadow.Enabled then
        DurationText:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
        DurationText:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
    else
        DurationText:SetShadowColor(0, 0, 0, 0)
        DurationText:SetShadowOffset(0, 0)
    end
    DurationText:SetJustifyH(UUF:SetJustification(DurationDB.Layout[1]))

    if CastBarDB.Inverse then
        CastBar:SetReverseFill(true)
    else
        CastBar:SetReverseFill(false)
    end

    CastBar.Text = SpellNameText
    CastBar.Time = DurationText
    CastBar.UUFIcon = CastBar.Icon
    CastBar:HookScript("OnValueChanged", function(self, value) if self.Castbar then self.Castbar:SetValue(value) end end)
    CastBar:HookScript("OnHide", function() CastBarContainer:Hide() end)

    CastBar.PostCastStart = function(frameCastBar)
			local currentCastBarDB = UUF:GetUnitDB(unitFrame, unit).CastBar
			local currentSpellNameDB = currentCastBarDB.Text.SpellName
			SetCastBarColour(frameCastBar, unit, currentCastBarDB)

            local spellInfo = C_Spell.GetSpellInfo(frameCastBar.spellID)
            local spellName = spellInfo and spellInfo.name
            if spellName then
                if not UUF:IsSecretValue(spellName) then
					if currentSpellNameDB.MaxChars and currentSpellNameDB.MaxChars > 0 then spellName = string.format("%." .. currentSpellNameDB.MaxChars .. "s", spellName) end
                    spellName = UUF:CleanTruncateUTF8String(spellName)
                end
				local targetName = currentCastBarDB.ShowTarget and not UnitSpellTargetName and UnitName(unit .. "target")
				if currentCastBarDB.ShowTarget and UnitSpellTargetName and (frameCastBar.casting or (frameCastBar.channeling or frameCastBar.empowering) and UnitShouldDisplaySpellTargetName(unit)) then targetName = UnitSpellTargetName(unit) end
                if UUF:IsSecretValue(targetName) or targetName then frameCastBar.Text:SetFormattedText("%s » %s", spellName, targetName) else frameCastBar.Text:SetText(spellName) end
            else
                frameCastBar.Text:SetText("")
            end

            if frameCastBar.NotInterruptibleOverlay and frameCastBar.notInterruptible ~= nil then frameCastBar.NotInterruptibleOverlay:SetAlphaFromBoolean(frameCastBar.notInterruptible, 1, 0) end
            CastBarContainer:Show()
    end

    CastBar.PostCastInterruptible = function(frameCastBar)
        if frameCastBar.NotInterruptibleOverlay and frameCastBar.notInterruptible ~= nil then frameCastBar.NotInterruptibleOverlay:SetAlphaFromBoolean(frameCastBar.notInterruptible, 1, 0) end
			SetCastBarColour(frameCastBar, unit, UUF:GetUnitDB(unitFrame, unit).CastBar)
    end
    CastBar.PostCastFail = function(frameCastBar)
			frameCastBar:SetStatusBarColor(unpack(UUF:GetUnitDB(unitFrame, unit).CastBar.InterruptedFailedColour))
        if frameCastBar.NotInterruptibleOverlay then frameCastBar.NotInterruptibleOverlay:SetAlpha(0) end
    end
    CastBar.PostCastInterrupted = CastBar.PostCastFail
    unitFrame.UUFCastbar = CastBar

    if CastBarDB.Enabled then
        unitFrame.Castbar = CastBar
        if not CastBarDB.Icon.Enabled then CastBar.Icon = nil end
        if SpellNameDB.Enabled then CastBar.Text:SetAlpha(1) else CastBar.Text:SetAlpha(0) end
        if DurationDB.Enabled then CastBar.Time:SetAlpha(1) else CastBar.Time:SetAlpha(0) end
    else
        CastBarContainer:Hide()
        CastBar:Hide()
    end

    return CastBar
end

function UUF:UpdateUnitCastBar(unitFrame, unit)
    local GeneralDB = UUF.db.profile.General
    local FrameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Frame
    local CastBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar
    local CastBarContainer = (unitFrame.Castbar or unitFrame.UUFCastbar) and (unitFrame.Castbar or unitFrame.UUFCastbar):GetParent()

    if CastBarDB.Enabled then
        unitFrame.Castbar = unitFrame.Castbar or unitFrame.UUFCastbar or UUF:CreateUnitCastBar(unitFrame, unit)
        CastBarContainer = unitFrame.Castbar and unitFrame.Castbar:GetParent()

        if not unitFrame:IsElementEnabled("Castbar") then unitFrame:EnableElement("Castbar") end

        if unitFrame.Castbar then
            if CastBarContainer then CastBarContainer:ClearAllPoints() end
            if CastBarContainer then CastBarContainer:SetPoint(CastBarDB.Layout[1], unitFrame, CastBarDB.Layout[2], CastBarDB.Layout[3], CastBarDB.Layout[4]) end
            if CastBarContainer then CastBarContainer:SetFrameStrata(CastBarDB.FrameStrata) end
            unitFrame.Castbar:ClearAllPoints()
            unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
            unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
            if CastBarDB.MatchParentWidth then
                if CastBarContainer then
                    CastBarContainer:SetWidth(FrameDB.Width)
                end
            else
                if CastBarContainer then
                    CastBarContainer:SetWidth(CastBarDB.Width)
                end
            end
            if CastBarContainer then CastBarContainer:SetHeight(CastBarDB.Height) end
            unitFrame.Castbar:SetStatusBarTexture(UUF.Media.Foreground)
            unitFrame.Castbar.timeToHold = CastBarDB.HoldTime
            unitFrame.Castbar.Background:SetTexture(UUF.Media.Background)
            SetCastBarColour(unitFrame.Castbar, unit, CastBarDB)
            unitFrame.Castbar.Background:SetVertexColor(unpack(CastBarDB.Background))

            if unitFrame.Castbar.NotInterruptibleOverlay then
                unitFrame.Castbar.NotInterruptibleOverlay:SetTexture(UUF.Media.Foreground)
                unitFrame.Castbar.NotInterruptibleOverlay:SetVertexColor(unpack(CastBarDB.NotInterruptibleColour))
            end

            if CastBarDB.Inverse then
                unitFrame.Castbar:SetReverseFill(true)
            else
                unitFrame.Castbar:SetReverseFill(false)
            end

            if CastBarDB.Icon.Enabled then
                unitFrame.Castbar.Icon = unitFrame.Castbar.UUFIcon
                unitFrame.Castbar.Icon:SetSize(CastBarDB.Height - 2, CastBarDB.Height - 2)
                unitFrame.Castbar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                unitFrame.Castbar.Icon:ClearAllPoints()
                if CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "LEFT" then
                    unitFrame.Castbar.Icon:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                    unitFrame.Castbar:ClearAllPoints()
                    unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", CastBarDB.Height - 1, -1)
                    unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
                elseif CastBarDB.Icon.Enabled and CastBarDB.Icon.Position == "RIGHT" then
                    unitFrame.Castbar.Icon:SetPoint("TOPRIGHT", CastBarContainer, "TOPRIGHT", -1, -1)
                    unitFrame.Castbar:ClearAllPoints()
                    unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                    unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -(CastBarDB.Height - 1), 1)
                elseif not CastBarDB.Icon.Enabled then
                    unitFrame.Castbar.Icon:Hide()
                    unitFrame.Castbar:ClearAllPoints()
                    unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                    unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
                end
                unitFrame.Castbar.Icon:Show()
            else
                if unitFrame.Castbar.Icon then unitFrame.Castbar.Icon:Hide() end
                unitFrame.Castbar.Icon = nil
                unitFrame.Castbar:ClearAllPoints()
                unitFrame.Castbar:SetPoint("TOPLEFT", CastBarContainer, "TOPLEFT", 1, -1)
                unitFrame.Castbar:SetPoint("BOTTOMRIGHT", CastBarContainer, "BOTTOMRIGHT", -1, 1)
            end

            if unitFrame.Castbar.Text then
                local SpellNameDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.SpellName
                unitFrame.Castbar.Text:ClearAllPoints()
                unitFrame.Castbar.Text:SetPoint(SpellNameDB.Layout[1], unitFrame.Castbar, SpellNameDB.Layout[2], SpellNameDB.Layout[3], SpellNameDB.Layout[4])
                unitFrame.Castbar.Text:SetFont(UUF.Media.Font, SpellNameDB.FontSize, GeneralDB.Fonts.FontFlag)
                unitFrame.Castbar.Text:SetTextColor(unpack(SpellNameDB.Colour))
                if GeneralDB.Fonts.Shadow.Enabled then
                    unitFrame.Castbar.Text:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                    unitFrame.Castbar.Text:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
                else
                    unitFrame.Castbar.Text:SetShadowColor(0, 0, 0, 0)
                    unitFrame.Castbar.Text:SetShadowOffset(0, 0)
                end
                unitFrame.Castbar.Text:SetJustifyH(UUF:SetJustification(SpellNameDB.Layout[1]))
                if SpellNameDB.Enabled then unitFrame.Castbar.Text:SetAlpha(1) else unitFrame.Castbar.Text:SetAlpha(0) end
            end

            if unitFrame.Castbar.Time then
                local DurationDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.Duration
                unitFrame.Castbar.Time:ClearAllPoints()
                unitFrame.Castbar.Time:SetPoint(DurationDB.Layout[1], unitFrame.Castbar, DurationDB.Layout[2], DurationDB.Layout[3], DurationDB.Layout[4])
                unitFrame.Castbar.Time:SetFont(UUF.Media.Font, DurationDB.FontSize, GeneralDB.Fonts.FontFlag)
                unitFrame.Castbar.Time:SetTextColor(unpack(DurationDB.Colour))
                if GeneralDB.Fonts.Shadow.Enabled then
                    unitFrame.Castbar.Time:SetShadowColor(GeneralDB.Fonts.Shadow.Colour[1], GeneralDB.Fonts.Shadow.Colour[2], GeneralDB.Fonts.Shadow.Colour[3], GeneralDB.Fonts.Shadow.Colour[4])
                    unitFrame.Castbar.Time:SetShadowOffset(GeneralDB.Fonts.Shadow.XPos, GeneralDB.Fonts.Shadow.YPos)
                else
                    unitFrame.Castbar.Time:SetShadowColor(0, 0, 0, 0)
                    unitFrame.Castbar.Time:SetShadowOffset(0, 0)
                end
                unitFrame.Castbar.Time:SetJustifyH(UUF:SetJustification(DurationDB.Layout[1]))
                if DurationDB.Enabled then unitFrame.Castbar.Time:SetAlpha(1) else unitFrame.Castbar.Time:SetAlpha(0) end
            end
        end
    else
        local castBar = unitFrame.Castbar or unitFrame.UUFCastbar
        if not castBar then return end
        if unitFrame.Castbar and unitFrame:IsElementEnabled("Castbar") then unitFrame:DisableElement("Castbar") end
        castBar:Hide()
        unitFrame.Castbar = nil
        if CastBarContainer then
            CastBarContainer:Hide()
        end
    end
    if UUF.CASTBAR_TEST_MODE then UUF:CreateTestCastBar(unitFrame, unit) end
end

function UUF:CreateTestCastBar(unitFrame, unit)
    if not unit then return end
    if not unitFrame then return end
    local GeneralDB = UUF.db.profile.General
    local CastBarDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar
    local CastBarContainer = unitFrame.Castbar and unitFrame.Castbar:GetParent()
    if UUF.CASTBAR_TEST_MODE then
        if unitFrame.Castbar and CastBarDB.Enabled then
            unitFrame:DisableElement("Castbar")
            CastBarContainer:Show()
            CastBarContainer:SetFrameStrata(CastBarDB.FrameStrata)
            unitFrame.Castbar:Show()
            unitFrame.Castbar.Background:Show()
            local spellName = "Ethereal Portal"
            local maxChars = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].CastBar.Text.SpellName.MaxChars
            if maxChars and maxChars > 0 then spellName = string.format("%." .. maxChars .. "s", spellName) end
            spellName = UUF:CleanTruncateUTF8String(spellName)
            if CastBarDB.ShowTarget then unitFrame.Castbar.Text:SetFormattedText("%s » %s", spellName, "Target") else unitFrame.Castbar.Text:SetText(spellName) end
            unitFrame.Castbar.Time:SetText("2.5")
            unitFrame.Castbar:SetMinMaxValues(0, 1000)
            unitFrame.Castbar:SetValue(500)
            SetCastBarColour(unitFrame.Castbar, unit, CastBarDB)
            if unitFrame.Castbar.NotInterruptibleOverlay then
                unitFrame.Castbar.NotInterruptibleOverlay:SetAlpha(0)
            end
            if CastBarDB.Icon.Enabled and unitFrame.Castbar.Icon then unitFrame.Castbar.Icon:SetTexture("Interface\\Icons\\ability_mage_netherwindpresence") unitFrame.Castbar.Icon:Show() end
        else
            if CastBarContainer then CastBarContainer:Hide() end
            if unitFrame.Castbar and unitFrame.Castbar.Icon then unitFrame.Castbar.Icon:Hide() end
        end
    else
        if unitFrame.Castbar then
            unitFrame.Castbar:Hide()
            if CastBarContainer then CastBarContainer:Hide() end
            if CastBarDB.Enabled then
                if unitFrame:IsElementEnabled("Castbar") then unitFrame:DisableElement("Castbar") end
                unitFrame:EnableElement("Castbar")
            end
        end
    end
end

local InterruptCooldownFrame = CreateFrame("Frame")
InterruptCooldownFrame:RegisterEvent("SPELLS_CHANGED")
InterruptCooldownFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
InterruptCooldownFrame:SetScript("OnEvent", function()
	if not UUF.db or not UUF.GetNormalizedUnit then return end
	for i = 1, 9 do
		local unitFrame = i == 1 and UUF.PLAYER or i == 2 and UUF.TARGET or i == 3 and UUF.FOCUS or i == 4 and UUF.PET or UUF["BOSS" .. (i - 4)]
		local castBar = unitFrame and unitFrame.Castbar
		local unit = unitFrame and unitFrame.unit
		local UnitDB = unit and UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)]
		if castBar and castBar:IsShown() and (castBar.casting or castBar.channeling or castBar.empowering) and UnitDB and UnitDB.CastBar then SetCastBarColour(castBar, unit, UnitDB.CastBar) end
	end
end)
