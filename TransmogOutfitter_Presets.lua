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

addonTable.LoadPresets = LoadPresets

local function SavePreset(index)
    local preset = {}
    preset.name = UnitName("player") -- Save the character's name as the preset name

    for buttonName, slotName in pairs(addonTable.slotNames) do
        local slotID = addonTable.slotIDs[buttonName]
        if slotID then
            local transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            local _, _, _, _, pendingSourceID, _, _, _, _ = C_Transmog.GetSlotVisualInfo(transmogLocation)
            local itemID = GetInventoryItemID("player", slotID)
            if pendingSourceID and pendingSourceID ~= 0 then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(pendingSourceID)
                if sourceInfo then
                    preset[slotName] = sourceInfo.itemID
                end
            elseif itemID then
                preset[slotName] = itemID
            end
        end
    end

    addonTable.savedPresets[index] = preset
    TransmogOutfitter_SavedPresets = addonTable.savedPresets

    -- Update the corresponding preset 3D model
    local presetModel = addonTable.modelFrames[index]
    presetModel:Undress()
    for slotName, itemID in pairs(preset) do
        presetModel:TryOn("item:" .. itemID)
    end
end

addonTable.SavePreset = SavePreset

local function LoadPreset(index)
    local preset = addonTable.savedPresets[index]
    if not preset then return end
    
    addonTable.my3DModel:Undress()
    for slotName, itemID in pairs(preset) do
        addonTable.ApplyItemToModel(itemID, slotName)
    end
    addonTable.my3DModel:RefreshUnit()
end

addonTable.LoadPreset = LoadPreset

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
        button:SetText(preset.name or "Preset " .. i) -- Show the character's name or preset index
        button:SetScript("OnClick", function() addonTable.LoadPreset(i) end)
        yOffset = yOffset - 25
    end

    local saveButton = CreateFrame("Button", nil, presetsFrame, "UIPanelButtonTemplate")
    saveButton:SetSize(180, 20)
    saveButton:SetPoint("BOTTOM", presetsFrame, "BOTTOM", 0, 10)
    saveButton:SetText("Save Current Outfit")
    saveButton:SetScript("OnClick", function()
        local index = #addonTable.savedPresets + 1
        addonTable.SavePreset(index)
        presetsFrame:Hide() -- Refresh the presets list
        ShowSavedPresets(frame)
    end)
end

addonTable.ShowSavedPresets = ShowSavedPresets
