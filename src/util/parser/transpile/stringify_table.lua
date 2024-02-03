-- TODO lua-ext also provides table stringification - probably does it better.

---@param input any
---@return string
local stringify = function(input)
    error("should have been replaced!")
end

--- Try really really hard to stringify a table safely.
--- Obviously this table has to be serializable
---
--- Don't take this stringifier as a good implementation
--- of a general stringifier - it only wants to make XML into Lua
---
---@param input table
---@return string
local function stringify_table(input)
    local elements = {}

    for k, v in pairs(input) do
        local key = stringify(k)
        local value = stringify(v)

        local format = string.format("[%s]=%s", key, value)

        table.insert(elements, format)
    end

    return string.format("{ %s }", table.concat(elements, ", "))
end

stringify = function(input)
    local t = type(input)

    if t == "nil" or t == "number" or t == "boolean" then
        return tostring(input)
    end

    if t == "string" then
        if input:match("^{.*}$") then
            -- parse a literal
            return input:sub(2, -2)
        else 
            return string.format("%q", input)
        end
    end

    if t == "table" then
        return stringify_table(input)
    end

    error(string.format("Cannot stringify %s", t))
end

return stringify_table
