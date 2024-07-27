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

local function SavePresets()
    TransmogOutfitter_SavedPresets = addonTable.savedPresets
end

addonTable.SavePresets = SavePresets

local function SavePreset(index)
    local preset = {}
    preset.name = UnitName("player") -- Save the character's name as the preset name

    for buttonName, slotID in pairs(addonTable.slotNames) do
        if slotID then
            local transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasUndo, isHideVisual, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation)
            
            local sourceID
            if pendingSourceID and pendingSourceID ~= 0 then
                sourceID = pendingSourceID
            elseif appliedSourceID and appliedSourceID ~= 0 then
                sourceID = appliedSourceID
            elseif baseSourceID and baseSourceID ~= 0 then
                sourceID = baseSourceID
            end
            
            if sourceID then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                if sourceInfo then
                    preset[slotID] = {
                        itemID = sourceInfo.itemID,
                        sourceID = sourceID,
                        visualID = sourceInfo.visualID,
                        name = sourceInfo.name
                    }
                else
                    preset[slotID] = {
                        itemID = nil,
                        sourceID = sourceID,
                        visualID = nil,
                        name = "Unknown"
                    }
                end
            else
                preset[slotID] = {
                    itemID = nil,
                    sourceID = nil,
                    visualID = nil,
                    name = "Unknown"
                }
            end
        end
    end

    addonTable.savedPresets[index] = preset
    SavePresets()

    local presetModel = addonTable.modelFrames[index]
    presetModel:Undress()
    for slotID, data in pairs(preset) do
        if data.itemID then
            presetModel:TryOn("item:" .. data.itemID)
        end
    end

    if preset[16] and preset[16].itemID then
        presetModel:TryOn("item:" .. preset[16].itemID)
    end
    if preset[17] and preset[17].itemID then
        presetModel:TryOn("item:" .. preset[17].itemID)
    end

    print("Preset saved.")
end

addonTable.SavePreset = SavePreset

local function CreatePendingInfo(sourceID)
    local pendingInfo = CreateFromMixins(TransmogPendingInfoMixin)
    pendingInfo:Init(Enum.TransmogPendingType.Apply, sourceID, Enum.TransmogCollectionType.Appearance)
    return pendingInfo
end

local function LoadPreset(index)
    local preset = addonTable.savedPresets[index]
    if not preset then
        print("No preset found for index:", index)
        return
    end

    addonTable.my3DModel:Undress()
    
    for slotID, data in pairs(preset) do
        if type(slotID) == "number" and data.itemID then
            addonTable.ApplyItemToModel(data.itemID, addonTable.slotIDs[slotID])
        end
    end
    
    addonTable.my3DModel:RefreshUnit()

    for slotID, data in pairs(preset) do
        if type(slotID) == "number" and data.sourceID then
            local transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            local pendingInfo = CreatePendingInfo(data.sourceID)

            if type(transmogLocation) ~= "table" or not pendingInfo.transmogID then
                print("Invalid transmogLocation or pendingInfo for SlotID:", slotID)
            else
                local success, err = pcall(function()
                    C_Transmog.SetPending(transmogLocation, pendingInfo)
                end)
                if not success then
                    print("Error setting pending transmog for SlotID:", slotID, err)
                end
            end
        end
    end

    if WardrobeTransmogFrame and WardrobeTransmogFrame.Update then
        WardrobeTransmogFrame:Update()
    end
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
        button:SetText(preset.name or "Preset " .. i)
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
        presetsFrame:Hide()
        ShowSavedPresets(frame)
    end)
end

addonTable.ShowSavedPresets = ShowSavedPresets
