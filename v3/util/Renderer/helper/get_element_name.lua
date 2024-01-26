
--- This is the best lua gives us for getting function names, as getinfo will only return a name if we give it a stack depth.
---@param fn function
---@return string
local function get_function_location (fn)
    if not debug then
        return "UNKNOWN (no debug library)"
    end

    if not debug.getinfo then
        return "UNKNOWN (no debug.getinfo)"
    end

    local success, res = pcall(function ()
        local info = debug.getinfo(fn, "S")

        local location = info.short_src .. ":" .. info.linedefined

        return location
    end)

    if success then
        return string.format("Function defined at %s", res)
    end

    return "UNKNOWN (error calling debug.getinfo)"
end

---@param element LuaX.ElementNode | LuaX.NativeElement | nil
---@return string
local function get_element_name (element)
    if element == nil then
        return "nil"
    end

    if element.type then
        local element_type = element.type

        local t = type(element_type)

        if t == "function" then
            return get_function_location(element_type)
        elseif t == "string" then
            return element_type
        else
            return string.format("UNKNOWN (%s %s)", t, tostring(element_type))
        end
    end

    if element.class then
        if element.get_type then
            return element:get_type()
        end

        return "UNKNOWN (NativeElement or some 30log class)"
    end

    return "UNKNOWN"
end

return get_element_name