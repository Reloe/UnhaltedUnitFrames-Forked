local InterfaceVersion = select(4, GetBuildInfo())
if InterfaceVersion <= 16000 or InterfaceVersion >= 20000 then return end

-- Version 0 lets LibDispel initialize normally using the prepared event frame.
local LibDispel = LibStub:NewLibrary("LibDispel-1.0", 0) or LibStub("LibDispel-1.0")
local DispelFrame = LibDispel.frame or CreateFrame("Frame")
local RegisterEvent = DispelFrame.RegisterEvent
LibDispel.frame = DispelFrame

function DispelFrame:RegisterEvent(event, ...)
    if event == "LEARNED_SPELL_IN_TAB" then event = "LEARNED_SPELL_IN_SKILL_LINE" end
    return RegisterEvent(self, event, ...)
end
