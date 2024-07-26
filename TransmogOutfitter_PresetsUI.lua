-- TransmogOutfitter_PresetsUI.lua

local addonName, addonTable = ...

-- Number of presets
local NUM_PRESETS = 6

-- Function to save the current outfit to a preset
local function SavePreset(index)
    local preset = {}
    for slot, name in pairs(addonTable.slotNames) do
        local itemID = GetInventoryItemID("player", slot)
        if itemID then
            preset[name] = itemID
        end
    end
    addonTable.savedPresets[index] = preset
    TransmogOutfitter_SavedPresets = addonTable.savedPresets
    print("Preset " .. index .. " saved.")
end

-- Function to load a preset
local function LoadPreset(index)
    local preset = addonTable.savedPresets[index]
    if not preset then return end
    
    addonTable.my3DModel:Undress()
    for name, itemID in pairs(preset) do
        addonTable.ApplyItemToModel(itemID, name)
    end
    addonTable.my3DModel:RefreshUnit()
    print("Preset " .. index .. " loaded.")
end

-- Function to create the preset UI
local function CreatePresetUI(parentFrame)
    local presetFrame = CreateFrame("Frame", "PresetFrame", parentFrame, "BackdropTemplate")
    presetFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 24,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    presetFrame:SetBackdropBorderColor(0, 1, 1, 1)
    
    local titleText = presetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOP", presetFrame, "TOP", 0, -10)
    titleText:SetText("Saved Presets")

    local modelFrames = {}
    local maxColumns = 3
    local presetWidth = 180
    local presetHeight = 210 -- Height of each preset model and buttons

    for i = 1, NUM_PRESETS do
        local row = math.floor((i - 1) / maxColumns)
        local col = (i - 1) % maxColumns

        local modelFrame = CreateFrame("DressUpModel", nil, presetFrame)
        modelFrame:SetSize(presetWidth, presetHeight - 60)
        modelFrame:SetPoint("TOPLEFT", presetFrame, "TOPLEFT", 10 + col * (presetWidth + 10), -40 - row * presetHeight)
        modelFrame:SetUnit("player")
        modelFrames[i] = modelFrame

        local button = CreateFrame("Button", nil, modelFrame, "UIPanelButtonTemplate")
        button:SetSize(presetWidth, 20)
        button:SetPoint("TOP", modelFrame, "BOTTOM", 0, -5)
        button:SetText("Preset " .. i)
        button:SetScript("OnClick", function() addonTable.LoadPreset(i) end)

        local saveButton = CreateFrame("Button", nil, modelFrame, "UIPanelButtonTemplate")
        saveButton:SetSize(presetWidth, 20)
        saveButton:SetPoint("TOP", button, "BOTTOM", 0, -5)
        saveButton:SetText("Save Preset " .. i)
        saveButton:SetScript("OnClick", function() addonTable.SavePreset(i) end)
    end

    local numRows = math.ceil(NUM_PRESETS / maxColumns)
    local numCols = math.min(NUM_PRESETS, maxColumns)
    local frameWidth = 20 + numCols * (presetWidth + 10) - 10
    local frameHeight = 40 + numRows * presetHeight
    presetFrame:SetSize(frameWidth, frameHeight)

    presetFrame:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 10, 0)
    presetFrame:Hide()

    addonTable.presetFrame = presetFrame
    addonTable.modelFrames = modelFrames
end

addonTable.CreatePresetUI = CreatePresetUI
addonTable.SavePreset = SavePreset
addonTable.LoadPreset = LoadPreset
