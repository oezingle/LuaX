local ipairs_with_nil = require "src.util.ipairs_with_nil"

---@param input any
---@return string
local stringify = function(input)
    error("should have been replaced!")
end

--- Try really really hard to stringify a table safely.
--- Obviously this table has to be serializable
---
--- Don't take this stringifier for a good implementation,
--- it's only really bothered with LuaX
---
---@param input table
---@return string
local function stringify_table(input)
    local elements = {}

    -- number keys need to be handled differently to others, because of the way LuaX works.
    for k, v in pairs(input) do
        if type(k) ~= "number" then
            local key = stringify(k)
            local value = stringify(v)

            local format = string.format("[%s]=%s", key, value)

            table.insert(elements, format)
        end
    end

    for _, v in ipairs_with_nil(input) do
        local value = stringify(v)

        if #value ~= 0 then
            table.insert(elements, value)
        end
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

    if t == "function" then
        local dump = string.dump(input)

        return string.format("load(%q)", dump)
    end

    error(string.format("Cannot stringify %s", t))
end

return stringify_table