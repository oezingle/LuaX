
---@param str string
local function string_empty (str)
    if str:match("^%s*$") then
        return true
    else
        return false
    end
end

---@param node SLAXML.Node
local function ignore_node (node)
    if node.type == "comment" then
        return true
    end

    if node.type == "text" then
        local text = node.value

        if string_empty(text) then
            return true
        end
    end

    return false
end

return ignore_node