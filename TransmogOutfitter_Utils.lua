-- TransmogOutfitter_Utils.lua
local addonName, addonTable = ...

-- Example utility function
local function PrintMessage(message)
    print(message)
end

addonTable.PrintMessage = PrintMessage

-- Function to print a table recursively
local function PrintTable(t, indent)
    if not indent then
        indent = 0
    end
    local indentStr = string.rep("  ", indent)

    if type(t) == "table" then
        print(indentStr .. "{")
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(indentStr .. "  [" .. tostring(k) .. "] = ")
                PrintTable(v, indent + 1)
            else
                print(indentStr .. "  [" .. tostring(k) .. "] = " .. tostring(v))
            end
        end
        print(indentStr .. "}")
    else
        print(indentStr .. tostring(t))
    end
end

addonTable.PrintTable = PrintTable
