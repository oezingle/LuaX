
--- Return the component's name as a string, either for a lua local,
--- or quoted as a component for NativeElement to use
---
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param name string
local function get_component_name(components, components_mode, name)
    -- LuaX.<name> is always treated as a global
    if name:sub(1, 5) == "LuaX." then
        return string.format("%q", name:sub(6))
    end

    local search_name =
        -- Turn MyContext.Provider or MyContext["Provider"] into just MyContext
        name:match("^(.-)[%.%[]") or
        -- Default to just the name if we can't match table key calls
        name

    -- try both shortened name and full-length name
    local has_component = not not (components[search_name] or components[name])

    local mode_global = components_mode == "global"

    local is_global = has_component == mode_global

    if is_global then
        return string.format("%q", name)
    else
        return name
    end
end

return get_component_name