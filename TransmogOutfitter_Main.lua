-- TransmogOutfitter_Main.lua
local addonName, addonTable = ...

-- Create the main frame and handle events
local my3DFrame, my3DModel

local function OnEvent(self, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        local slotID = ...
        addonTable.UpdateTransmogModel()
    elseif event == "TRANSMOGRIFY_OPEN" then
        addonTable.HookTransmogSlots()
        addonTable.UpdateTransmogModel() -- Initialize with all slots
        addonTable.my3DFrame:Show() -- Show 3D frame when Transmogrify window is opened
    elseif event == "TRANSMOGRIFY_CLOSE" then
        addonTable.my3DFrame:Hide() -- Hide 3D frame when Transmogrify window is closed
    elseif event == "TRANSMOGRIFY_UPDATE" then
        local slotID = ...
        addonTable.UpdateTransmogModel()
    elseif event == "ADDON_LOADED" then
        local addon = ...
        if addon == addonName then
            addonTable.LoadPresets()
            addonTable.CreatePresetUI(addonTable.my3DFrame)
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("TRANSMOGRIFY_OPEN")
eventFrame:RegisterEvent("TRANSMOGRIFY_CLOSE")
eventFrame:RegisterEvent("TRANSMOGRIFY_UPDATE")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnEvent)

-- Initialize the 3D frame
my3DFrame, my3DModel = addonTable.Create3DFrame()
addonTable.my3DFrame = my3DFrame
addonTable.my3DModel = my3DModel

-- Ensure 3D frame is shown on addon load and update model
my3DFrame:Show()
my3DModel:SetUnit("player")
addonTable.UpdateTransmogModel()

-- Initially hide the 3D frame
my3DFrame:Hide()
