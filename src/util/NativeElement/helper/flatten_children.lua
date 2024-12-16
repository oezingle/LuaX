
local key_add = require("src.util.key.key_add")
local ipairs_with_nil = require("src.util.ipairs_with_nil")

---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
---@param elements { element: LuaX.NativeElement, key: LuaX.Key }[]?
local function flatten_children (children_by_key, key, elements)
    elements = elements or {}

    if not children_by_key then
        -- nil is allowed, we just ignore    
    elseif children_by_key.class then
        table.insert(elements, { 
            key = key,
            element = children_by_key --[[ @as LuaX.NativeElement ]]
        })
    else
        for i, entry in ipairs_with_nil(children_by_key) do
            local new_key = key_add(key, i)

            flatten_children(entry, new_key, elements)
        end
    end

    return elements
end

return flatten_children