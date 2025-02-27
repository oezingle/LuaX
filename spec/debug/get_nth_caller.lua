local get_function_name = require "src.util.debug.get_function_name"

---@param n integer
local function get_nth_caller (n)
    local info = debug.getinfo(2 + n, "Sl")

    if info.source == "[C]" then
        return "[C]"
    end

    local src = info.source:sub(2) .. ":" .. tostring(info.linedefined)

    local name = get_function_name(src)

    return (name or src) .. " (line " .. tostring(info.currentline) .. ")"
end

return get_nth_caller