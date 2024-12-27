
--- Determine if the existing child of container can be modified to become child, 
--- Or if it must be replaced
---@param child LuaX.ElementNode
---@param container LuaX.NativeElement
---@param key LuaX.Key
local function can_modify_child (child, container, key)
    local existing_children = container:get_children_by_key(key)

    -- Child is currently nil
    if not existing_children then
        return false, existing_children
    end

    -- This is a NativeElement[], not a single NativeElement
    if #existing_children ~= 0 then
        return false, existing_children
    end

    ---@type LuaX.NativeElement
    local existing_child = existing_children

    -- get_type isn't implemented, assume incompatible :(
    if not existing_child.get_type then
        return false, existing_children
    end 

    if existing_child:get_type() ~= child.type then              
        return false, existing_children
    end

    return true, existing_child
end

return can_modify_child