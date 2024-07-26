-- TransmogOutfitter_Utils.lua
local addonName, addonTable = ...

local DEBUG_MODE = false -- Set this to true to enable debugging

local function PrintMessage(message)
    if DEBUG_MODE then
        print(addonName .. ": " .. message)
    end
end

addonTable.PrintMessage = PrintMessage

local function CopyModelSettings(fromModel, toModel)
    for slotName, itemID in pairs(fromModel.textureChanges) do
        toModel:TryOn("item:" .. itemID)
    end
end

addonTable.CopyModelSettings = CopyModelSettings
