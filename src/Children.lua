local ipairs_with_nil = require("src.util.ipairs_with_nil")

local Children = {}

---@param children LuaX.ElementNode[] | LuaX.ElementNode | nil
function Children.count (children)
    if not children then
        return 0
    elseif children.type then
        return 1
    else
        local count = 0

        for _, child in ipairs_with_nil(children) do
            count = count + Children.count(child)
        end
    end
end

---@generic T
---@param children LuaX.ElementNode[] | LuaX.ElementNode | nil
---@param cb fun(child: LuaX.ElementNode, index: number): T
---@return T[]
function Children.map(children, cb)
    if not children or children.type then
        children = { children }
    end

    local mapped = {}

    for i, child in ipairs_with_nil(children) do
        mapped[i] = cb(child, i)
    end

    return mapped
end

return Children