local key_first = require "src.util.key.key_first"

---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
---@param child LuaX.NativeElement | nil
local function set_child_by_key(children_by_key, key, child)
    local first, restkey = key_first(key)

    if children_by_key.class then
        error("set_child_by_key found a NativeElement when it expected an array!")
    end

    if #restkey == 0 then
        children_by_key[first] = child
    else
        if not children_by_key[first] then
            children_by_key[first] = {}
        end

        set_child_by_key(children_by_key[first], restkey, child)
    end
end

return set_child_by_key