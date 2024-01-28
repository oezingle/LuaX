local ignore_node = require("src.util.xml.parse.ignore_node")
local clean_text  = require("src.util.xml.parse.clean_text")

local list_filter = require("src.util.polyfill.list.filter")
local list_map = require("src.util.polyfill.list.map")

---@generic T : SLAXML.Node
---
---@param node T
---@param indent string
---@param depth integer?
---@return T
local function clean_node(node, indent, depth)
    depth = depth or 0

    if node.kids then
        ---@diagnostic disable-next-line:inject-field
        node.kids = list_filter(node.kids, function(child)
            return not ignore_node(child)
        end)

        ---@diagnostic disable-next-line:inject-field
        node.kids = list_map(node.kids, function(child)
            return clean_node(child, indent, depth + 1)
        end)
    end

    if node.type == "text" then
        node.value = clean_text(node.value, indent, depth)
    end

    return node
end

return clean_node
