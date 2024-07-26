-- TransmogOutfitter_Presets.lua

local addonName, addonTable = ...

addonTable.savedPresets = addonTable.savedPresets or {}

local function LoadPresets()
    if TransmogOutfitter_SavedPresets then
        addonTable.savedPresets = TransmogOutfitter_SavedPresets
    else
        addonTable.savedPresets = {}
    end
end

local function SaveCurrentOutfit()
    local preset = {
        textures = addonTable.textureChanges -- Save the logged changes
    }
    table.insert(addonTable.savedPresets, preset)
    TransmogOutfitter_SavedPresets = addonTable.savedPresets
    print("Outfit saved. Total presets: " .. #addonTable.savedPresets)
    
    -- Update the corresponding preset 3D model
    local presetIndex = #addonTable.savedPresets
    local presetModel = addonTable.modelFrames[presetIndex]
    for slotName, itemID in pairs(addonTable.textureChanges) do
        presetModel:TryOn("item:" .. itemID)
    end
end

local function LoadOutfit(preset)
    addonTable.my3DModel:Undress()
    for slotName, itemID in pairs(preset.textures) do
        addonTable.ApplyItemToModel(itemID, slotName)
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
