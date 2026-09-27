local UUF = select(2, ...)
local InterfaceVersion = select(4, GetBuildInfo())
local IsForeverClient = InterfaceVersion > 16000 and InterfaceVersion < 20000
local HasPetHappiness = type(GetPetHappiness) == "function" or IsForeverClient and C_StableInfo and type(C_StableInfo.GetStablePetInfo) == "function"

UUF.HasPetHappiness = not not HasPetHappiness

local HappinessTextureCoordinates = {
	[1] = {0.375, 0.5625, 0, 0.359375},
	[2] = {0.1875, 0.375, 0, 0.359375},
	[3] = {0, 0.1875, 0, 0.359375},
}

function UUF:CreateUnitPetHappiness(unitFrame, unit)
	if unit ~= "pet" or not HasPetHappiness then return end
	local PetHappinessDB = UUF:GetUnitDB(unitFrame, unit).Indicators.PetHappiness
	local HappinessIndicator = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PetHappiness", unitFrame)
	HappinessIndicator:SetFrameLevel(unitFrame:GetFrameLevel() + 5)
	HappinessIndicator.Icon = HappinessIndicator:CreateTexture(nil, "ARTWORK")
	HappinessIndicator.Icon:SetAllPoints()
	HappinessIndicator.Icon:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
	HappinessIndicator:RegisterEvent("UNIT_HAPPINESS")
	HappinessIndicator:RegisterEvent("UNIT_PET")
	HappinessIndicator:RegisterEvent("PLAYER_ENTERING_WORLD")
	if IsForeverClient then HappinessIndicator:RegisterEvent("PET_INFO_UPDATE") end
	HappinessIndicator:SetScript("OnEvent", function()
		UUF:UpdateUnitPetHappiness(unitFrame, unit)
	end)
	unitFrame.PetHappiness = HappinessIndicator
	UUF:UpdateUnitPetHappiness(unitFrame, unit)
end

function UUF:UpdateUnitPetHappiness(unitFrame, unit)
	if unit ~= "pet" or not HasPetHappiness then return end
	local PetHappinessDB = UUF:GetUnitDB(unitFrame, unit).Indicators.PetHappiness
	local HappinessIndicator = unitFrame.PetHappiness
	if not HappinessIndicator then
		UUF:CreateUnitPetHappiness(unitFrame, unit)
		return
	end
	if not PetHappinessDB.Enabled then
		HappinessIndicator:Hide()
		return
	end
	if UnitClassBase("player") ~= "HUNTER" then
		HappinessIndicator:Hide()
		return
	end

	HappinessIndicator:ClearAllPoints()
	HappinessIndicator:SetSize(PetHappinessDB.Size, PetHappinessDB.Size)
	if PetHappinessDB.Position == "LEFT" then
		HappinessIndicator:SetPoint("RIGHT", unitFrame, "LEFT", -2, 0)
	else
		HappinessIndicator:SetPoint("LEFT", unitFrame, "RIGHT", 2, 0)
	end

	local Happiness
	if type(GetPetHappiness) == "function" then
		Happiness = GetPetHappiness()
	elseif C_StableInfo and type(C_StableInfo.GetStablePetInfo) == "function" then
		local PetInfo = C_StableInfo.GetStablePetInfo(1)
		Happiness = PetInfo and PetInfo.happinessLevel
	end
	local TextureCoordinates = not UUF:IsSecretValue(Happiness) and HappinessTextureCoordinates[Happiness]
	if not UnitIsVisible("pet") or not TextureCoordinates then
		HappinessIndicator:Hide()
		return
	end

	HappinessIndicator.Icon:SetTexCoord(unpack(TextureCoordinates))
	HappinessIndicator:Show()
end
