-- TransmogOutfitter_Main.lua
-- Create the main frame and handle events
local addonName, addonTable = ...
local my3DFrame, my3DModel

local NUM_PRESETS = 6 -- Define the number of presets

local function OnEvent(self, event, ...)
    local arg1 = ...

    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == addonName then
            addonTable.my3DFrame, addonTable.my3DModel = addonTable.Create3DFrame()
            addonTable.LoadPresets()
            addonTable.CreatePresetUI(addonTable.my3DFrame)
            addonTable.my3DFrame:Hide()
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local slotID = ...
        addonTable.PrintSelectedItemName(slotID)
    elseif event == "TRANSMOGRIFY_OPEN" then
        addonTable.HookTransmogSlots()
        addonTable.my3DFrame:Show()
        addonTable.LoadPresets() -- Ensure presets are loaded
        for i = 1, NUM_PRESETS do
            addonTable.LoadPreset(i) -- Load each preset model
        end
        addonTable.PrintSelectedItemName(1) -- Initialize with head slot
    elseif event == "TRANSMOGRIFY_CLOSE" then
        addonTable.my3DFrame:Hide()
    elseif event == "TRANSMOGRIFY_UPDATE" then
        local slotID = ...
        addonTable.PrintSelectedItemName(slotID)
    elseif event == "TRANSMOGRIFY_SUCCESS" then
        local slotID = ...
        addonTable.PrintSelectedItemName(slotID)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("TRANSMOGRIFY_OPEN")
eventFrame:RegisterEvent("TRANSMOGRIFY_CLOSE")
eventFrame:RegisterEvent("TRANSMOGRIFY_UPDATE")
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
