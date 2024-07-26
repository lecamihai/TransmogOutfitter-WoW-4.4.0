local addonName, addonTable = ...

addonTable.slotButtons = {
    "HeadButton",
    "ShoulderButton",
    "ChestButton",
    "WaistButton",
    "LegsButton",
    "FeetButton",
    "WristButton",
    "HandsButton",
    "BackButton",
    "MainHandButton",
    "SecondaryHandButton",
    "RangedButton",
    "TabardButton",
    "ShirtButton"
}

addonTable.slotNames = {
    ["HeadButton"] = "Head",
    ["ShoulderButton"] = "Shoulder",
    ["ChestButton"] = "Chest",
    ["WaistButton"] = "Waist",
    ["LegsButton"] = "Legs",
    ["FeetButton"] = "Feet",
    ["WristButton"] = "Wrist",
    ["HandsButton"] = "Hands",
    ["BackButton"] = "Back",
    ["MainHandButton"] = "Main Hand",
    ["SecondaryHandButton"] = "Off Hand",
    ["RangedButton"] = "Ranged",
    ["TabardButton"] = "Tabard",
    ["ShirtButton"] = "Shirt"
}

addonTable.slotIDs = {
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
    ["ShirtButton"] = 4,
}

local function Create3DFrame()
    print("Creating 3D Frame")

    -- Create the main frame with BackdropTemplate
    local frame = CreateFrame("Frame", "My3DFrame", UIParent, "BackdropTemplate")
    frame:SetSize(300, 400)
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10) -- Position for easier visibility
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

    local isDragging = false
    local lastMouseX, lastMouseY
    local rotationSpeed = 0.02 -- Rotation speed
    local zoomSpeed = 0.1 -- Zoom speed
    local pitchSpeed = 0.2 -- Reduced pitch speed for finer control
    local isRotating = false -- Flag for rotating model
    local isCameraMoving = false -- Flag for moving camera
    local currentRotation = 0 -- Current rotation angle
    local currentPitch = 0 -- Current camera pitch
    local zoom = 1.0 -- Current zoom level

    local function OnMouseWheel(self, delta)
        zoom = zoom + (delta * zoomSpeed)
        zoom = math.max(zoom, 0.1) -- Prevent zoom out too far
        model:SetModelScale(zoom)
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
            frame.model:SetModelScale(newScale)
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

    print("3D Frame created successfully")
    return frame, model
end

addonTable.Create3DFrame = Create3DFrame

local function ApplyItemToModel(itemID, slotName)
    if itemID and itemID ~= 0 then
        print("Trying on item ID:", itemID, "for slot:", slotName)
        addonTable.my3DModel:TryOn("item:" .. itemID)
    else
        print("No valid item ID found for slot:", slotName)
    end
end

addonTable.ApplyItemToModel = ApplyItemToModel

local function UpdateTransmogModel()
    print("Updating Transmog Model")
    addonTable.my3DModel:Undress() -- Reset the model
    for button, name in pairs(addonTable.slotNames) do
        local slotID = addonTable.slotIDs[button]
        if slotID then
            local itemID = GetInventoryItemID("player", slotID)
            if itemID then
                print("Item ID found for slot:", button, name, "Item ID:", itemID)
                addonTable.ApplyItemToModel(itemID, name)
            else
                print("No item found in slot:", button, name)
            end
        else
            print("No slot ID found for button:", button)
        end
    end
    addonTable.my3DModel:RefreshUnit() -- Refresh the model
end

addonTable.UpdateTransmogModel = UpdateTransmogModel

local function PrintSelectedItemName()
    local transmogLocation = TransmogUtil.CreateTransmogLocation(1, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
    local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID = C_Transmog.GetSlotVisualInfo(transmogLocation)
    
    if pendingSourceID and pendingSourceID ~= 0 then
        local sourceInfo = C_TransmogCollection.GetSourceInfo(pendingSourceID)
        if sourceInfo then
            print("Selected hat item:", sourceInfo.name)
            addonTable.ApplyItemToModel(sourceInfo.itemID, "Head")
        else
            print("Selected item info not available")
        end
    else
        print("No item selected")
    end
end

addonTable.PrintSelectedItemName = PrintSelectedItemName

local function HookTransmogSlots()
    C_Timer.After(1, function()
        local transmogFrame = WardrobeTransmogFrame
        if transmogFrame then
            local slot = transmogFrame.HeadSlot
            if slot then
                slot:HookScript("OnClick", function()
                    print("Head slot clicked")
                    addonTable.PrintSelectedItemName()
                end)
                print("Hooked head slot")
            else
                print("Head slot not found")
            end
        else
            print("WardrobeTransmogFrame not found, retrying...")
            C_Timer.After(1, HookTransmogSlots) -- Retry after 1 second
            return
        end
    end)
end

addonTable.HookTransmogSlots = HookTransmogSlots
