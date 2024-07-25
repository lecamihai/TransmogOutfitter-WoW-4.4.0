-- TransmogOutfitter_Presets.lua

local addonName, addonTable = ...

addonTable.savedPresets = addonTable.savedPresets or {}

local function LoadPresets()
    if TransmogOutfitter_SavedPresets then
        addonTable.savedPresets = TransmogOutfitter_SavedPresets
    else
        -- Initialize with default presets if no saved presets
        addonTable.savedPresets = {}
    end
end

local function SaveCurrentOutfit()
    local preset = {}
    for slot, name in pairs(addonTable.slotNames) do
        local itemID = GetInventoryItemID("player", slot)
        if itemID then
            preset[name] = itemID
        end
    end
    table.insert(addonTable.savedPresets, preset)
    TransmogOutfitter_SavedPresets = addonTable.savedPresets
    print("Outfit saved. Total presets: " .. #addonTable.savedPresets)
end

local function LoadOutfit(preset)
    addonTable.my3DModel:Undress()
    for name, itemID in pairs(preset) do
        addonTable.ApplyItemToModel(itemID, name)
    end
    addonTable.my3DModel:RefreshUnit()
end

local function ShowSavedPresets(frame)
    local presetsFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    presetsFrame:SetSize(200, 400)
    presetsFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 10, 0)
    presetsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 24,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    presetsFrame:SetBackdropBorderColor(0, 1, 1, 1)
    
    local titleText = presetsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOP", presetsFrame, "TOP", 0, -10)
    titleText:SetText("Saved Presets")

    local yOffset = -30
    for i, preset in ipairs(addonTable.savedPresets) do
        local button = CreateFrame("Button", nil, presetsFrame, "UIPanelButtonTemplate")
        button:SetSize(180, 20)
        button:SetPoint("TOP", presetsFrame, "TOP", 0, yOffset)
        button:SetText("Preset " .. i)
        button:SetScript("OnClick", function() LoadOutfit(preset) end)
        yOffset = yOffset - 25
    end

    local saveButton = CreateFrame("Button", nil, presetsFrame, "UIPanelButtonTemplate")
    saveButton:SetSize(180, 20)
    saveButton:SetPoint("BOTTOM", presetsFrame, "BOTTOM", 0, 10)
    saveButton:SetText("Save Current Outfit")
    saveButton:SetScript("OnClick", SaveCurrentOutfit)
end

addonTable.LoadPresets = LoadPresets
addonTable.SaveCurrentOutfit = SaveCurrentOutfit
addonTable.LoadOutfit = LoadOutfit
addonTable.ShowSavedPresets = ShowSavedPresets
