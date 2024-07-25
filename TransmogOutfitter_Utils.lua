-- TransmogOutfitter_Utils.lua

local addonName, addonTable = ...

-- Example utility function
local function PrintMessage(message)
    print(addonName .. ": " .. message)
end

addonTable.PrintMessage = PrintMessage

-- Other utility functions can be added here
