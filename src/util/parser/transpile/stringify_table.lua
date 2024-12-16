local ipairs_with_nil = require "src.util.ipairs_with_nil"
-- TODO lua-ext also provides table stringification - probably does it better.
-- TODO FIXME switch to lua-ext now that it's a dep

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

        table.insert(elements, value)
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

    -- TODO FIXME test this!
    if t == "function" then
        local dump = string.dump(input)

        -- TODO if debug exists, use it to name chunk?

        -- this will look DISGUSTING printed out but it's a hack that works (i believe)
        return string.format("load(%q)", dump)
    end

    error(string.format("Cannot stringify %s", t))
end

return stringify_table
