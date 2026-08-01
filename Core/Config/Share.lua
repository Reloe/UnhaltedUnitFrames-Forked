local _, UUF = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")
local UUF_IMPORT_PREFIX = "!UUF_"

local function SerializeLuaValue(value, indentation, serializedTables)
    local valueType = type(value)
    if valueType == "string" then return string.format("%q", value) end
    if valueType == "number" or valueType == "boolean" then return tostring(value) end
    if valueType ~= "table" then return "nil" end
    if serializedTables[value] then return "nil" end

    serializedTables[value] = true
    local keys = {}
    local arrayLength = 0
    local isArray = true
    local hasNestedTables = false
    for key, tableValue in pairs(value) do
        keys[#keys + 1] = key
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            isArray = false
        elseif key > arrayLength then
            arrayLength = key
        end
        if type(tableValue) == "table" then hasNestedTables = true end
    end

    if #keys == 0 then
        serializedTables[value] = nil
        return "{}"
    end
    if isArray and arrayLength ~= #keys then isArray = false end

    if isArray and not hasNestedTables then
        local values = {}
        for index = 1, arrayLength do values[index] = SerializeLuaValue(value[index], indentation + 1, serializedTables) end
        serializedTables[value] = nil
        return "{" .. table.concat(values, ", ") .. "}"
    end

    table.sort(keys, function(firstKey, secondKey)
        local firstType = type(firstKey)
        local secondType = type(secondKey)
        if firstType == secondType then return firstKey < secondKey end
        if firstType == "number" then return true end
        if secondType == "number" then return false end
        return tostring(firstKey) < tostring(secondKey)
    end)

    local lines = {"{"}
    local indentationText = string.rep("    ", indentation + 1)
    for _, key in ipairs(keys) do
        local keyText = ""
        if not isArray then
            keyText = type(key) == "string" and key:match("^[%a_][%w_]*$") and key .. " = " or "[" .. SerializeLuaValue(key, indentation + 1, serializedTables) .. "] = "
        end
        lines[#lines + 1] = indentationText .. keyText .. SerializeLuaValue(value[key], indentation + 1, serializedTables) .. ","
    end
    lines[#lines + 1] = string.rep("    ", indentation) .. "}"
    serializedTables[value] = nil
    return table.concat(lines, "\n")
end

local function BuildEncodedProfile(profileData)
    local serializedInfo = Serialize:Serialize(profileData)
    local compressedInfo = Compress:CompressDeflate(serializedInfo)
    local encodedInfo = Compress:EncodeForPrint(compressedInfo)
    return UUF_IMPORT_PREFIX .. encodedInfo
end

local function ParseEncodedProfile(encodedInfo)
    if type(encodedInfo) ~= "string" or encodedInfo:sub(1, #UUF_IMPORT_PREFIX) ~= UUF_IMPORT_PREFIX then
        return nil
    end

    local decodedInfo = Compress:DecodeForPrint(encodedInfo:sub(#UUF_IMPORT_PREFIX + 1))
    if not decodedInfo then
        return nil
    end

    local decompressedInfo = Compress:DecompressDeflate(decodedInfo)
    if not decompressedInfo then
        return nil
    end

    local success, data = Serialize:Deserialize(decompressedInfo)
    if not success or type(data) ~= "table" then
        return nil
    end

    return data
end

local function ValidateProfileTable(profile)
    if type(profile) ~= "table" or type(profile.General) ~= "table" or type(profile.Units) ~= "table" then
        return false
    end

    local tablesBeingValidated = {}
    local function ValidateTable(source, defaults)
        if tablesBeingValidated[source] then
            return false
        end

        tablesBeingValidated[source] = true
        for key, value in pairs(source) do
            local keyType = type(key)
            local valueType = type(value)
            if (keyType ~= "string" and keyType ~= "number")
                or (valueType ~= "table" and valueType ~= "string" and valueType ~= "number" and valueType ~= "boolean") then
                return false
            end

            local defaultValue = type(defaults) == "table" and rawget(defaults, key) or nil
            if defaultValue ~= nil and type(defaultValue) ~= valueType then
                return false
            end

            if valueType == "table" and not ValidateTable(value, type(defaultValue) == "table" and defaultValue or nil) then
                return false
            end
        end
        tablesBeingValidated[source] = nil
        return true
    end

    return ValidateTable(profile, UUF:GetDefaultDB().profile)
end

local function CopyImportedProfile(source, destination)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(destination[key]) ~= "table" then
                destination[key] = {}
            end
            CopyImportedProfile(value, destination[key])
        else
            destination[key] = value
        end
    end
end

local function ApplyImportedProfileToCurrent(profile)
    -- Preserve AceDB's active profile reference and fill defaults omitted by older exports.
    UUF.db:ResetProfile(true, true)
    CopyImportedProfile(profile, UUF.db.profile)

    UUF:RefreshProfiles()
    if UUFG.RefreshProfiles then
        UUFG.RefreshProfiles()
    end
    local general = UUF.db.profile and UUF.db.profile.General
    local uiScale = general and general.UIScale
    UIParent:SetScale((uiScale and uiScale.Scale) or 1)
    UUF:UpdateAllUnitFrames()
end

local function ImportProfile(profile, profileName)
    if not ValidateProfileTable(profile) or type(profileName) ~= "string" or profileName == "" then
        UUF:PrettyPrint("Invalid Import String.")
        return false
    end

    if UUF.db.global.UseGlobalProfile then
        UUF.db.global.GlobalProfile = profileName
    end
    UUF.db:SetProfile(profileName)
    ApplyImportedProfileToCurrent(profile)
    return true
end

function UUF:ExportSavedVariables()
    local profileData = { profile = UUF.db.profile, }
    return BuildEncodedProfile(profileData)
end

function UUF:ExportDefaultsTable()
    return "local Defaults = " .. SerializeLuaValue({
        global = UUF.db.global,
        profile = UUF.db.profile,
    }, 0, {})
end

function UUF:ImportSavedVariables(encodedInfo, profileName)
    local data = ParseEncodedProfile(encodedInfo)
    if not data or not ValidateProfileTable(data.profile) then
        UUF:PrettyPrint("Invalid Import String.")
        return
    end

    if profileName then
        ImportProfile(data.profile, profileName)
    else
        StaticPopupDialogs["UUF_IMPORT_NEW_PROFILE"] = {
            text = UUF.ADDON_NAME.." - ".."Profile Name?",
            button1 = "Import",
            button2 = "Cancel",
            hasEditBox = true,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(self)
                local editBox = self.EditBox
                local newProfileName = editBox:GetText() or string.format("Imported_%s-%s-%s", date("%d"), date("%m"), date("%Y"))
                if not newProfileName or newProfileName == "" then
                    UUF:PrettyPrint("Please enter a valid profile name.")
                    return
                end

                ImportProfile(data.profile, newProfileName)
            end,
        }
        StaticPopup_Show("UUF_IMPORT_NEW_PROFILE")
    end

end

function UUFG:ExportUUF(profileKey)
    local profile = UUF.db.profiles[profileKey]
    if not profile then return nil end

    local profileData = { profile = profile, }
    return BuildEncodedProfile(profileData)
end

function UUFG:ImportUUF(importString, profileKey)
    local profileData = ParseEncodedProfile(importString)
    if not profileData or not ValidateProfileTable(profileData.profile) then
        UUF:PrettyPrint("Invalid Import String.")
        return
    end

    ImportProfile(profileData.profile, profileKey)
end
