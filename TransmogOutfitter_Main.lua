local addonName, addonTable = ...
local my3DFrame, my3DModel

local NUM_PRESETS = 6 -- Define the number of presets
local hasLoggedIn = false -- Flag to track if the user has logged in and performed the initial update

local function OpenPresetsWindow()
    -- Ensure the presets window is open
    if not addonTable.presetFrame:IsShown() then
        addonTable.presetFrame:Show()
    end
end

local function RefreshModels()
    OpenPresetsWindow()
    C_Timer.After(0.1, function()
        addonTable.LoadPresets()
        for i = 1, NUM_PRESETS do
            addonTable.LoadPreset(i) -- Load each preset model
        end
        addonTable.PrintSelectedItemName(1) -- Initialize with head slot
    end)
end

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
        
        -- Automatically update models only once after login
        if not hasLoggedIn then
            RefreshModels()
            hasLoggedIn = true -- Set the flag after the update
        else
            addonTable.LoadPresets()
        end
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
eventFrame:RegisterEvent("PLAYER_LOGIN")
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
