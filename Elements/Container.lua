local _, UUF = ...

function UUF:UpdateUnitContainerLayers(unitFrame, unit)
    if not unitFrame or not unitFrame.Container or not unitFrame.HighLevelContainer then return end
    local frameUnit = unit or unitFrame.UUFConfiguredUnit or unitFrame.unit
    local normalizedUnit = frameUnit and UUF:GetNormalizedUnit(frameUnit)
    local isGroupFrame = normalizedUnit == "party" or normalizedUnit == "raid"
    if not isGroupFrame then unitFrame.Container:SetFrameStrata(unitFrame:GetFrameStrata()) end
    unitFrame.Container:SetFrameLevel(unitFrame:GetFrameLevel())
    if not isGroupFrame then unitFrame.HighLevelContainer:SetFrameStrata(unitFrame:GetFrameStrata()) end
    unitFrame.HighLevelContainer:SetFrameLevel(unitFrame:GetFrameLevel() + 50)
end

function UUF:CreateUnitContainer(unitFrame, unit)
    if not unitFrame.Container then
        unitFrame.Container = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_Container", unitFrame, "BackdropTemplate")
        unitFrame.Container:SetBackdrop(UUF.BACKDROP)
        unitFrame.Container:SetBackdropColor(0, 0, 0, 0)
        unitFrame.Container:SetBackdropBorderColor(0, 0, 0, 1)
        unitFrame.Container:SetAllPoints(unitFrame)

        if not unitFrame.HighLevelContainer then
            unitFrame.HighLevelContainer = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_HighLevelContainer", unitFrame)
            unitFrame.HighLevelContainer:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 0, 0)
            unitFrame.HighLevelContainer:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", 0, 0)
        end
    end
    UUF:UpdateUnitContainerLayers(unitFrame, unit)
end
