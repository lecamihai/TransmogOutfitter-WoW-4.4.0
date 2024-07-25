-- TransmogOutfitter_Main.lua

local addonName, addonTable = ...

-- Create the main frame and handle events
local my3DFrame, my3DModel

local function OnEvent(self, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        local slotID = ...
        if slotID == 1 then -- Head slot
            print("Head slot changed")
            addonTable.PrintSelectedItemName()
        end
    elseif event == "TRANSMOGRIFY_OPEN" then
        print("TRANSMOGRIFY_OPEN event triggered")
        addonTable.HookTransmogSlots()
        addonTable.PrintSelectedItemName()
    elseif event == "TRANSMOGRIFY_CLOSE" then
        print("TRANSMOGRIFY_CLOSE event triggered")
    elseif event == "TRANSMOGRIFY_UPDATE" then
        print("TRANSMOGRIFY_UPDATE event triggered")
        addonTable.PrintSelectedItemName()
    elseif event == "ADDON_LOADED" then
        local addon = ...
        if addon == addonName then
            addonTable.LoadPresets() -- Load presets when addon is loaded
            addonTable.CreatePresetUI(my3DFrame)
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

print("Addon loaded and 3D frame should be visible")
