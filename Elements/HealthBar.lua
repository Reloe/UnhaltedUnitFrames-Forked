local _, UUF = ...
local StatusBarInterpolation = Enum.StatusBarInterpolation
local oUF = UUF.oUF

local function SetHealthBackgroundColour(unitFrame, unit, HealthBarDB, forceUpdate)
	local backgroundUnit = unitFrame.unit or unit
	local isDead = HealthBarDB.ColourBackdropWhenDead and UnitIsDeadOrGhost(backgroundUnit)
	local backgroundClass
	local backgroundReaction
	if HealthBarDB.ColourBackgroundByClass then
		local unitToColour = backgroundUnit ~= "pet" and backgroundUnit or "player"
		backgroundClass = select(2, UnitClass(unitToColour))
		if not backgroundClass then backgroundReaction = UnitReaction(unitToColour, "player") end
	end
	if not forceUpdate and unitFrame.HealthBackgroundClass == backgroundClass and unitFrame.HealthBackgroundReaction == backgroundReaction and unitFrame.HealthBackgroundIsDead == isDead then return end
	unitFrame.HealthBackgroundClass = backgroundClass
	unitFrame.HealthBackgroundReaction = backgroundReaction
	unitFrame.HealthBackgroundIsDead = isDead

    if isDead then
        local deadBackdropColour = oUF.colors.deadBackdrop
        local r, g, b = deadBackdropColour:GetRGB()
        unitFrame.HealthBackground:SetStatusBarColor(r, g, b, HealthBarDB.BackgroundOpacity)
    elseif HealthBarDB.ColourBackgroundByClass then
        local unitToColour = backgroundUnit ~= "pet" and backgroundUnit or "player"
        local r, g, b = UUF:GetUnitColour(unitToColour, unitFrame)
        unitFrame.HealthBackground:SetStatusBarColor(r, g, b, HealthBarDB.BackgroundOpacity)
    else
        unitFrame.HealthBackground:SetStatusBarColor(HealthBarDB.Background[1], HealthBarDB.Background[2], HealthBarDB.Background[3], HealthBarDB.BackgroundOpacity)
    end
end

function UUF:CreateUnitHealthBar(unitFrame, unit)
    local FrameDB = UUF:GetUnitDB(unitFrame, unit).Frame
    local HealthBarDB = UUF:GetUnitDB(unitFrame, unit).HealthBar
    local unitContainer = unitFrame.Container

    if not unitFrame.HealthBar then
        if not unitFrame.HealthBackground then
            unitFrame.HealthBackground = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealthBackground", unitContainer)
            unitFrame.HealthBackground:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
            unitFrame.HealthBackground:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
            unitFrame.HealthBackground:SetStatusBarTexture(UUF:GetStatusBarTexture(unitFrame, unit, "Background"))
            unitFrame.HealthBackground:SetFrameLevel(unitContainer:GetFrameLevel() + 1)
            SetHealthBackgroundColour(unitFrame, unit, HealthBarDB, true)
        end

        local HealthBar = CreateFrame("StatusBar", UUF:FetchFrameName(unit) .. "_HealthBar", unitContainer)
        HealthBar:SetPoint("TOPLEFT", unitContainer, "TOPLEFT", 1, -1)
        HealthBar:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        HealthBar:SetStatusBarTexture(UUF:GetStatusBarTexture(unitFrame, unit, "Foreground"))
        HealthBar:SetFrameLevel(unitContainer:GetFrameLevel() + 2)
        HealthBar:SetStatusBarColor(HealthBarDB.Foreground[1], HealthBarDB.Foreground[2], HealthBarDB.Foreground[3], HealthBarDB.ForegroundOpacity)
        HealthBar.colorClass = HealthBarDB.ColourByClass
        HealthBar.colorReaction = HealthBarDB.ColourByClass
        HealthBar.colorHealth = not HealthBarDB.ColourByClass
        HealthBar.colorTapping = HealthBarDB.ColourWhenTapped
        HealthBar.colorDisconnected = HealthBarDB.ColourWhenDisconnected
        HealthBar.smoothing = HealthBarDB.Smooth ~= false and StatusBarInterpolation.ExponentialEaseOut or StatusBarInterpolation.Immediate
		HealthBar.PostUpdateColor = function(healthBar, unit, colour)
			local currentHealthBarDB = UUF:GetUnitDB(unitFrame, unit).HealthBar
			if UUF:UsesRaidClassColours(unitFrame, unit) and currentHealthBarDB.ColourByClass and UnitIsPlayer(unit) and (not currentHealthBarDB.ColourWhenDisconnected or UnitIsConnected(unit)) and (not currentHealthBarDB.ColourWhenTapped or not UnitIsTapDenied(unit)) then
				local r, g, b = UUF:GetConfiguredClassColour(select(2, UnitClass(unit)), unitFrame, unit)
				if r then healthBar:SetStatusBarColor(r, g, b, currentHealthBarDB.ForegroundOpacity) return end
			end
			if colour and colour ~= oUF.colors.health then return end
			if unit == "pet" and currentHealthBarDB.ColourByClass then
				local r, g, b = UUF:GetConfiguredClassColour(select(2, UnitClass("player")), unitFrame, unit)
				if r then healthBar:SetStatusBarColor(r, g, b, currentHealthBarDB.ForegroundOpacity) return end
			end
			healthBar:SetStatusBarColor(currentHealthBarDB.Foreground[1], currentHealthBarDB.Foreground[2], currentHealthBarDB.Foreground[3], currentHealthBarDB.ForegroundOpacity)
		end

        if unit == "pet" and HealthBarDB.ColourByClass then
            HealthBar.colorClass = false
            HealthBar.colorReaction = false
            HealthBar.colorHealth = false
        end

        unitFrame.Health = HealthBar

        unitFrame.Health.PostUpdate = function(_, _, curHP, maxHP)
            local unitHP = unitFrame.HealthBackground
            maxHP = maxHP or 1
            curHP = curHP or 0
            unitHP:SetMinMaxValues(0, maxHP)
            unitHP:SetValue(UnitHealthMissing(unitFrame.unit, true), unitFrame.Health.smoothing)
			SetHealthBackgroundColour(unitFrame, unit, UUF:GetUnitDB(unitFrame, unit).HealthBar)
        end

        if HealthBarDB.Inverse then
            unitFrame.Health:SetReverseFill(true)
            unitFrame.HealthBackground:SetReverseFill(false)
        else
            unitFrame.Health:SetReverseFill(false)
            unitFrame.HealthBackground:SetReverseFill(true)
        end

    end
end

function UUF:UpdateUnitHealthBar(unitFrame, unit)
    local FrameDB = UUF:GetUnitDB(unitFrame, unit).Frame
    local HealthBarDB = UUF:GetUnitDB(unitFrame, unit).HealthBar
    local DispelHighlightDB = UUF:GetUnitDB(unitFrame, unit).HealthBar.DispelHighlight

    if unitFrame and (unit == "player" or unit == "target" or unit == "targettarget" or unit == "focus" or unit == "focustarget" or unit == "pet") then
        UUF:PositionUnitFrame(unitFrame, unit)
    end

    if unitFrame.Health then
        unitFrame.Health:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        unitFrame.Health:SetStatusBarColor(HealthBarDB.Foreground[1], HealthBarDB.Foreground[2], HealthBarDB.Foreground[3], HealthBarDB.ForegroundOpacity)
        unitFrame.Health.colorClass = HealthBarDB.ColourByClass
        unitFrame.Health.colorReaction = HealthBarDB.ColourByClass
        unitFrame.Health.colorHealth = not HealthBarDB.ColourByClass
        unitFrame.Health.colorTapping = HealthBarDB.ColourWhenTapped
        unitFrame.Health.colorDisconnected = HealthBarDB.ColourWhenDisconnected
        unitFrame.Health.smoothing = HealthBarDB.Smooth ~= false and StatusBarInterpolation.ExponentialEaseOut or StatusBarInterpolation.Immediate
        unitFrame.Health:SetStatusBarTexture(UUF:GetStatusBarTexture(unitFrame, unit, "Foreground"))
        if unit == "pet" and HealthBarDB.ColourByClass then
            unitFrame.Health.colorClass = false
            unitFrame.Health.colorReaction = false
            unitFrame.Health.colorHealth = false
        end
    end

    if unitFrame.HealthBackground then
        unitFrame.HealthBackground:SetSize(FrameDB.Width - 2, FrameDB.Height - 2)
        SetHealthBackgroundColour(unitFrame, unit, HealthBarDB, true)
        unitFrame.HealthBackground:SetStatusBarTexture(UUF:GetStatusBarTexture(unitFrame, unit, "Background"))
    end

    if HealthBarDB.Inverse then
        unitFrame.Health:SetReverseFill(true)
        unitFrame.HealthBackground:SetReverseFill(false)
    else
        unitFrame.Health:SetReverseFill(false)
        unitFrame.HealthBackground:SetReverseFill(true)
    end

    if unitFrame.DispelHighlight then
        UUF:UpdateUnitDispelHighlight(unitFrame, unit)
    end

    unitFrame.Health:ForceUpdate()
end
