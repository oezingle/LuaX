local get_element_name = require("src.util.Renderer.helper.get_element_name")

---@param children LuaX.NativeElement.ChildrenByKey
---@param prev_key string?
---@param lines table?
local function recurse_children(children, prev_key, lines)
    local lines = lines or {}

    prev_key = prev_key or ""

    for i, child in ipairs(children or {}) do
        if child.class then
            local name = get_element_name(child)

            table.insert(lines, string.format("%s%d\t\t%s",
                prev_key, i, name
            ))

            ---@diagnostic disable-next-line:invisible
            local subchildren = child._children_by_key

            recurse_children(subchildren, prev_key .. tostring(i) .. "/", lines)
        else
            recurse_children(child, prev_key .. tostring(i) .. ".", lines)
        end
    end

    return lines
end


---@param children LuaX.NativeElement | LuaX.NativeElement.ChildrenByKey
local function print_children_by_key(children)
    if children.class then
        ---@diagnostic disable-next-line:invisible
        children = children._children_by_key
    end

    local lines = recurse_children(children)

    print(table.concat(lines, "\n"))
end

return print_children_by_key
