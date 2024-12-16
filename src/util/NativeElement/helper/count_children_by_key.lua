local ipairs_with_nil = require("src.util.ipairs_with_nil")
local key_first = require("src.util.key.key_first")
local VirtualElement = require("src.util.NativeElement.VirtualElement")

--local NativeTextElement = require("src.util.NativeElement.NativeTextElement")

--[[

children_by_key({
    NativeElement,
    {
        NativeElement,
        NativeElement,
    },
    {
        NativeElement,
        NativeElement,
        {
            NativeElement
        }
    }
}, { 3, 3, 1 })
]]

---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
local function count_children_by_key(children_by_key, key)
    local count = 0

    -- first could be nil, despite what the type checker says - if the key is empty
    local first, restkey = key_first(key)

    for index, child in ipairs_with_nil(children_by_key, first) do
        if child then
            if child.class then
                if child.class ~= VirtualElement then
                    count = count + 1
                end
            else
                -- we must count previous children and their subchildren in their entirety.
                -- to avoid missing these subchildren, we pass in an empty key to previous childs
                local pass_key = index == first

                local passed_key = pass_key and restkey or {}

                count = count + count_children_by_key(child, passed_key)
            end    
        end
    end

    return count
end

return count_children_by_key
