-- TransmogOutfitter_Utils.lua
local addonName, addonTable = ...

local NUM_PRESETS = 6

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
    local presetHeight = 210

    for i = 1, NUM_PRESETS do
        local row = math.floor((i - 1) / maxColumns)
        local col = (i - 1) % maxColumns

        local modelFrame = CreateFrame("DressUpModel", nil, presetFrame)
        modelFrame:SetSize(presetWidth, presetHeight - 60)
        modelFrame:SetPoint("TOPLEFT", presetFrame, "TOPLEFT", 10 + col * (presetWidth + 10), -40 - row * presetHeight)
        modelFrame:SetUnit("player")
        modelFrame:Undress()
        modelFrames[i] = modelFrame

        local button = CreateFrame("Button", nil, modelFrame, "UIPanelButtonTemplate")
        button:SetSize(presetWidth, 20)
        button:SetPoint("TOP", modelFrame, "BOTTOM", 0, -5)
        button:SetText("Load Preset " .. i)
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

    local deleteCacheButton = CreateFrame("Button", nil, presetFrame, "UIPanelButtonTemplate")
    deleteCacheButton:SetSize(100, 20)
    deleteCacheButton:SetPoint("TOPRIGHT", presetFrame, "TOPRIGHT", -10, -10)
    deleteCacheButton:SetText("Delete Cache")
    deleteCacheButton:SetScript("OnClick", function()
        addonTable.savedPresets = {}
        addonTable.SavePresets()
        presetFrame:Hide()
        ShowSavedPresets(parentFrame)
    end)

    addonTable.presetFrame = presetFrame
    addonTable.modelFrames = modelFrames
end

addonTable.CreatePresetUI = CreatePresetUI
