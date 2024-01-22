
---@alias LuaX.ComponentLookup table<string, LuaX.ComponentInstance>

---@type { components: LuaX.ComponentLookup, register: fun(components: LuaX.ComponentLookup), get_by_name: fun(name: string): LuaX.ComponentInstance | nil }
local registry = {
    components = {}
}

function registry.register (components)
    for name, component in pairs(components) do
        registry.components[name] = component
    end    
end

function registry.get_by_name(name)
    return registry.components[name]
end

return registry