local _, UUF = ...

function UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit)
    local LeaderAssistantDB = UUF:GetUnitDB(unitFrame, unit).Indicators.LeaderAssistantIndicator

    if LeaderAssistantDB then
        local Leader = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_LeaderIndicator", "OVERLAY")
        Leader:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
        Leader:SetPoint(LeaderAssistantDB.Layout[1], unitFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])

        local Assistant = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_AssistantIndicator", "OVERLAY")
        Assistant:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
        Assistant:SetPoint(LeaderAssistantDB.Layout[1], unitFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
        unitFrame.UUFLeaderIndicator = Leader
        unitFrame.UUFAssistantIndicator = Assistant

        if LeaderAssistantDB.Enabled then
            unitFrame.LeaderIndicator = Leader
            unitFrame.AssistantIndicator = Assistant
        else
            unitFrame.LeaderIndicator = nil
            unitFrame.AssistantIndicator = nil
        end
        return Leader, Assistant
    end
end

function UUF:UpdateUnitLeaderAssistantIndicator(unitFrame, unit)
    local LeaderAssistantDB = UUF:GetUnitDB(unitFrame, unit).Indicators.LeaderAssistantIndicator

    if LeaderAssistantDB.Enabled then
        if not unitFrame.UUFLeaderIndicator or not unitFrame.UUFAssistantIndicator then
            UUF:CreateUnitLeaderAssistantIndicator(unitFrame, unit)
        end
        unitFrame.LeaderIndicator = unitFrame.UUFLeaderIndicator
        unitFrame.AssistantIndicator = unitFrame.UUFAssistantIndicator

        if not unitFrame:IsElementEnabled("LeaderIndicator") then unitFrame:EnableElement("LeaderIndicator") end
        if not unitFrame:IsElementEnabled("AssistantIndicator") then unitFrame:EnableElement("AssistantIndicator") end

        if unitFrame.LeaderIndicator then
            unitFrame.LeaderIndicator:ClearAllPoints()
            unitFrame.LeaderIndicator:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
            unitFrame.LeaderIndicator:SetPoint(LeaderAssistantDB.Layout[1], unitFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
            unitFrame.LeaderIndicator:Show()
            unitFrame.LeaderIndicator:ForceUpdate()
        end

        if unitFrame.AssistantIndicator then
            unitFrame.AssistantIndicator:ClearAllPoints()
            unitFrame.AssistantIndicator:SetSize(LeaderAssistantDB.Size, LeaderAssistantDB.Size)
            unitFrame.AssistantIndicator:SetPoint(LeaderAssistantDB.Layout[1], unitFrame.HighLevelContainer, LeaderAssistantDB.Layout[2], LeaderAssistantDB.Layout[3], LeaderAssistantDB.Layout[4])
            unitFrame.AssistantIndicator:Show()
            unitFrame.AssistantIndicator:ForceUpdate()
        end
    else
        if not unitFrame.LeaderIndicator and not unitFrame.AssistantIndicator then return end
        if unitFrame:IsElementEnabled("LeaderIndicator") then unitFrame:DisableElement("LeaderIndicator") end
        if unitFrame:IsElementEnabled("AssistantIndicator") then unitFrame:DisableElement("AssistantIndicator") end
        if unitFrame.LeaderIndicator then
            unitFrame.LeaderIndicator:Hide()
            unitFrame.LeaderIndicator = nil
        end

        if unitFrame.AssistantIndicator then
            unitFrame.AssistantIndicator:Hide()
            unitFrame.AssistantIndicator = nil
        end
    end
end
