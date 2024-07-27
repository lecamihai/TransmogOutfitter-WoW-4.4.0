-- TransmogOutfitter_3DModelFrame.lua
local addonName, addonTable = ...

addonTable = addonTable or {}

-- Slot names to slot IDs mapping
addonTable.slotNames = {
    ["HeadButton"] = 1,
    ["ShoulderButton"] = 3,
    ["ChestButton"] = 5,
    ["WaistButton"] = 6,
    ["LegsButton"] = 7,
    ["FeetButton"] = 8,
    ["WristButton"] = 9,
    ["HandsButton"] = 10,
    ["BackButton"] = 15,
    ["MainHandButton"] = 16,
    ["SecondaryHandButton"] = 17,
    ["RangedButton"] = 18,
    ["TabardButton"] = 19,
    ["ShirtButton"] = 4
}

-- Slot IDs to slot names mapping
addonTable.slotIDs = {
    [1] = "HeadButton",
    [3] = "ShoulderButton",
    [5] = "ChestButton",
    [6] = "WaistButton",
    [7] = "LegsButton",
    [8] = "FeetButton",
    [9] = "WristButton",
    [10] = "HandsButton",
    [15] = "BackButton",
    [16] = "MainHandButton",
    [17] = "SecondaryHandButton",
    [18] = "RangedButton",
    [19] = "TabardButton",
    [4] = "ShirtButton"
}

-- Function to update the size of the 3D model
local function UpdateModelSize(frame)
    local modelFrame = addonTable.my3DModel
    if modelFrame then
        local width, height = frame:GetSize()
        modelFrame:SetSize(width, height)
    end
end

-- Store zoom level
local zoomLevel = 1.0

-- Function to set and get zoom level
local function SetZoomLevel(modelFrame, zoom)
    modelFrame:SetModelScale(zoom)
end

local function GetZoomLevel(modelFrame)
    return modelFrame:GetModelScale()
end

-- Function to create the 3D frame
local function Create3DFrame()
    -- Create the main frame with BackdropTemplate
    local frame = CreateFrame("Frame", "My3DFrame", UIParent, "BackdropTemplate")
    frame:SetSize(300, 400)
    frame:SetPoint("CENTER", UIParent, "CENTER", 100, 200) -- Position for easier visibility
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetResizable(true)

    -- Add black background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 1) -- Black background

    -- Add teal border with increased thickness
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Background texture (not used, but needed for backdrop)
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Border texture
        edgeSize = 24, -- Increased border thickness
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropBorderColor(0, 1, 1, 1) -- Teal border color

    -- Add title bar
    local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    titleBar:SetHeight(30)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Background texture
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- Border texture
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Dark gray background for title bar
    titleBar:SetBackdropBorderColor(0, 1, 1, 1) -- Teal border

    -- Get character name
    local characterName = UnitName("player")

    -- Add title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(characterName)

    -- Add resize handle
    local resizeHandle = CreateFrame("Button", nil, frame)
    resizeHandle:SetSize(20, 20) -- Size of the resize handle
    resizeHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4) -- Position the handle in the bottom-right corner
    resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    -- Minimum and Maximum sizes
    local MIN_WIDTH, MIN_HEIGHT = 300, 400
    local MAX_WIDTH, MAX_HEIGHT = 800, 1000

    -- Resize handle scripts
    resizeHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:GetParent():StartSizing("BOTTOMRIGHT")
            self:GetParent().isSizing = true
        end
    end)
    resizeHandle:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            local parent = self:GetParent()
            parent:StopMovingOrSizing()
            parent.isSizing = false

            -- Enforce min/max size
            local width, height = parent:GetWidth(), parent:GetHeight()
            if width < MIN_WIDTH then parent:SetWidth(MIN_WIDTH) end
            if height < MIN_HEIGHT then parent:SetHeight(MIN_HEIGHT) end
            if width > MAX_WIDTH then parent:SetWidth(MAX_WIDTH) end
            if height > MAX_HEIGHT then parent:SetHeight(MAX_HEIGHT) end
        end
    end)

    -- Add model
    local model = CreateFrame("DressUpModel", nil, frame)
    model:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
    model:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    model:SetSize(300, 360) -- Adjusted size to fit below the title bar
    model:SetUnit("player")
    frame.model = model

    -- Initialize zoom level
    zoomLevel = GetZoomLevel(model)

    local isDragging = false
    local lastMouseX, lastMouseY
    local rotationSpeed = 0.02 -- Rotation speed
    local zoomSpeed = 0.1 -- Zoom speed
    local pitchSpeed = 0.2 -- Reduced pitch speed for finer control
    local isRotating = false -- Flag for rotating model
    local isCameraMoving = false -- Flag for moving camera
    local currentRotation = 0 -- Current rotation angle
    local currentPitch = 0 -- Current camera pitch

    local function OnMouseWheel(self, delta)
        zoomLevel = zoomLevel + (delta * zoomSpeed)
        zoomLevel = math.max(zoomLevel, 0.1) -- Prevent zoom out too far
        SetZoomLevel(model, zoomLevel)
    end

    local function OnMouseDown(self, button)
        if button == "RightButton" then
            isRotating = true
            lastMouseX, lastMouseY = GetCursorPosition()
        elseif button == "LeftButton" then
            isCameraMoving = true
            lastMouseX, lastMouseY = GetCursorPosition()
        end
    end

    local function OnMouseUp(self, button)
        if button == "RightButton" then
            isRotating = false
        elseif button == "LeftButton" then
            isCameraMoving = false
        end
    end

    local function OnUpdate(self, elapsed)
        if isRotating then
            local currentMouseX, currentMouseY = GetCursorPosition()
            local deltaX = currentMouseX - lastMouseX
            currentRotation = currentRotation + deltaX * rotationSpeed
            model:SetRotation(currentRotation)
            lastMouseX, lastMouseY = currentMouseX, currentMouseY
        end

        if isCameraMoving then
            local currentMouseX, currentMouseY = GetCursorPosition()
            local deltaY = currentMouseY - lastMouseY
            currentPitch = currentPitch + deltaY * pitchSpeed

            -- Limit the camera pitch so the head and feet are always visible
            local minPitch = -100
            local maxPitch = 100
            currentPitch = math.max(minPitch, math.min(maxPitch, currentPitch))

            model:SetPosition(0, 0, currentPitch / 100) -- Adjust the divisor to control sensitivity
            lastMouseX, lastMouseY = currentMouseX, currentMouseY
        end

        if frame.isSizing then
            -- Enforce min/max size
            local width, height = frame:GetWidth(), frame:GetHeight()
            if width < MIN_WIDTH then frame:SetWidth(MIN_WIDTH) end
            if height < MIN_HEIGHT then frame:SetHeight(MIN_HEIGHT) end
            if width > MAX_WIDTH then frame:SetWidth(MAX_WIDTH) end
            if height > MAX_HEIGHT then frame:SetHeight(MAX_HEIGHT) end

            -- Adjust model size
            local newScale = height / 600 -- Adjusted scale factor for more gradual resizing
            SetZoomLevel(frame.model, zoomLevel) -- Keep zoom level consistent
            frame.model:SetSize(width, height - 30) -- Adjust model size to match frame size
        end
    end

    frame:SetScript("OnMouseWheel", OnMouseWheel)
    frame:SetScript("OnMouseDown", OnMouseDown)
    frame:SetScript("OnMouseUp", OnMouseUp)
    frame:SetScript("OnUpdate", OnUpdate)

    -- Set dragging to only be allowed when the title bar is clicked
    titleBar:SetScript("OnMouseDown", function(self)
        frame.isDragging = true
        frame:StartMoving()
    end)
    titleBar:SetScript("OnMouseUp", function(self)
        frame.isDragging = false
        frame:StopMovingOrSizing()
    end)

    -- Add a button to show saved presets
    local presetsButton = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
    presetsButton:SetSize(100, 20)
    presetsButton:SetPoint("RIGHT", titleText, "LEFT", -10, 0)
    presetsButton:SetText("Saved Presets")
    presetsButton:SetScript("OnClick", function()
        if addonTable.presetFrame:IsShown() then
            addonTable.presetFrame:Hide()
        else
            addonTable.presetFrame:Show()
        end
    end)

    -- Handle resizing of the frame
    frame:SetScript("OnSizeChanged", function(self)
        UpdateModelSize(self)
    end)

    -- Initial size update
    UpdateModelSize(frame)

    return frame, model
end

addonTable.Create3DFrame = Create3DFrame

local function ApplyItemToModel(itemID, slotName)
    if itemID and itemID ~= 0 then
        if slotName == "RangedButton" then
            -- Hide main hand and off hand when ranged weapon is equipped
            addonTable.my3DModel:UndressSlot(16)
            addonTable.my3DModel:UndressSlot(17)
        elseif slotName == "MainHandButton" or slotName == "SecondaryHandButton" then
            -- Hide ranged weapon when main hand or off hand is equipped
            addonTable.my3DModel:UndressSlot(18)
        end
        addonTable.my3DModel:TryOn("item:" .. itemID)
    end
end

addonTable.ApplyItemToModel = ApplyItemToModel

local function UpdateTransmogModel()
    addonTable.my3DModel:Undress() -- Reset the model
    addonTable.my3DModel:RefreshUnit() -- Refresh the model
end

addonTable.UpdateTransmogModel = UpdateTransmogModel

local function PrintSelectedItemName(slotID)
    -- List of transmog slots
    local transmogLocations = {
        [1] = "HeadSlot", -- Head
        [3] = "ShoulderSlot", -- Shoulders
        [5] = "ChestSlot", -- Chest
        [6] = "WaistSlot", -- Waist
        [7] = "LegsSlot", -- Legs
        [8] = "FeetSlot", -- Feet
        [9] = "WristSlot", -- Wrist
        [10] = "HandsSlot", -- Hands
        [15] = "BackSlot", -- Back
        [16] = "MainHandSlot", -- Main Hand
        [17] = "SecondaryHandSlot", -- Off Hand
        [18] = "RangedSlot", -- Ranged
        [19] = "TabardSlot", -- Tabard
        [4] = "ShirtSlot" -- Shirt
    }

    for transmogSlotID, slotName in pairs(transmogLocations) do
        if not slotID or transmogSlotID == slotID then
            local transmogLocation = TransmogUtil.CreateTransmogLocation(transmogSlotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasUndo, isHideVisual, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation)

            local itemID = nil
            if pendingSourceID and pendingSourceID ~= 0 and not isHideVisual then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(pendingSourceID)
                if sourceInfo then
                    itemID = sourceInfo.itemID
                end
            elseif appliedSourceID and appliedSourceID ~= 0 and not isHideVisual then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID)
                if sourceInfo then
                    itemID = sourceInfo.itemID
                end
            elseif baseSourceID and baseSourceID ~= 0 then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(baseSourceID)
                if sourceInfo then
                    itemID = sourceInfo.itemID
                end
            else
                itemID = GetInventoryItemID("player", transmogSlotID)
            end

            if itemID then
                addonTable.ApplyItemToModel(itemID, slotName)
            else
                -- Hide the item if no valid item ID is found
                if transmogSlotID == 16 or transmogSlotID == 17 then
                    addonTable.my3DModel:UndressSlot(transmogSlotID)
                end
            end
        end
    end
end

addonTable.PrintSelectedItemName = PrintSelectedItemName

local function HookTransmogSlots()
    C_Timer.After(1, function()
        local transmogFrame = WardrobeTransmogFrame
        if transmogFrame then
            for buttonName, slotID in pairs(addonTable.slotNames) do
                local slot = transmogFrame[buttonName]
                if slot then
                    slot:HookScript("OnMouseUp", function()
                        addonTable.PrintSelectedItemName(slotID)
                    end)
                else
                    C_Timer.After(1, HookTransmogSlots) -- Retry after 1 second
                end
            end
        else
            C_Timer.After(1, HookTransmogSlots) -- Retry after 1 second
        end
    end)
end

addonTable.HookTransmogSlots = HookTransmogSlots

-- Event handling for transmog updates
local function OnEvent(self, event, ...)
    local arg1 = ...

    if event == "TRANSMOGRIFY_OPEN" then
        addonTable.HookTransmogSlots()
    elseif event == "TRANSMOGRIFY_SUCCESS" or event == "TRANSMOGRIFY_UPDATE" then
        local slotID = nil

        if type(arg1) == "table" then
            -- Check if the table has a slotID field
            if arg1.slotID then
                slotID = arg1.slotID
            else
                -- Handle unexpected table structure
            end
        elseif type(arg1) == "number" then
            slotID = arg1
        else
        end

        if slotID then
            addonTable.PrintSelectedItemName(slotID)
        end
    end
end

-- Event frame to handle events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TRANSMOGRIFY_OPEN")
eventFrame:RegisterEvent("TRANSMOGRIFY_CLOSE")
eventFrame:RegisterEvent("TRANSMOGRIFY_SUCCESS")
eventFrame:RegisterEvent("TRANSMOGRIFY_UPDATE")
eventFrame:SetScript("OnEvent", OnEvent)
