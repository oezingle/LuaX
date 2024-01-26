
-- https://stackoverflow.com/questions/1426954/split-string-in-lua

---@param inputstr string
---@param sep string? the seperator pattern
local function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


return split