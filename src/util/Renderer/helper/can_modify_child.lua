local NativeElement = require "src.util.NativeElement.NativeElement"

-- TODO seems to always return false.
--- Determine if the existing child of container can be modified to become child, 
--- Or if it must be replaced
---@param child LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
local function can_modify_child (child, container, key)
    local existing_children = container:get_children_by_key(key)

    -- Child is currently nil
    if not existing_children then
        return false, existing_children
    end

    -- This is a NativeElement[], not a single NativeElement
    if not existing_children.class then
        return false, existing_children
    end

    ---@type LuaX.NativeElement
    local existing_child = existing_children

    -- This child needs to become nil
    if not child then
        return false, existing_children
    end

    -- get_type isn't implemented
    if not existing_child.get_type then
        return false, existing_children
    end 

    if existing_child:get_type() ~= child.type then              
        return false, existing_children
    end

    return true, existing_child
end

return can_modify_child