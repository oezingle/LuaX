local clean_text = require("src.util.xml.parse.clean_text")

---@param str string
local function string_empty(str)
    if str:match("^%s*$") then
        return true
    else
        return false
    end
end

---@param text string
---@param children HTMLParser.Node[]
---@param mt HTMLParser.Node
---@param indent string
---@param depth integer
local function add_textslice(text, children, mt, indent, depth)
    if not string_empty(text) then
        text = clean_text(text, indent, depth)

        ---@type HTMLParser.Node
        local literal = setmetatable({
            attributes = {
                value = text
            },
            index = #children,
        }, { __index = mt })

        table.insert(children, literal)
    end
end

--- the HTMLParser library includes other nodes inside of node:getcontet()
--- but otherwise works quite nicely so this function adds text nodes using
--- the HTML content of the parents to check for other children
---
---@param node HTMLParser.Node
---@param indent string
---@param depth integer?
---@return HTMLParser.Node
local function convert_text_nodes(node, indent, depth)
    if node.name == "LITERAL_NODE" then
        return node
    end

    depth = depth or 0

    local text = node:getcontent()

    -- transpiling doesn't matter speed wise so completeness makes my life easier
    local literal_mt = {
        name = "LITERAL_NODE",
        select = node.select,
        classes = {},
        getcontent = function(self)
            return self.attributes.value
        end,
        nodes = {},
        parent = node,
        gettext = function(self)
            return self.attributes.value
        end,
        level = node.level + 1,
        root = node.root,
        deepernodes = {},
        deeperelements = {},
        deeperattributes = {},
        deeperids = {},
        deeperclasses = {}
    }

    if not string_empty(text) then
        local new_children = {}

        local str_index = 1

        for _, child in ipairs(node.nodes) do
            local child_hmtl = child:gettext()

            local child_start, child_end = text:find(child_hmtl)

            if not child_start or not child_end then
                error("HTML child not found in parent string")
            end

            local textslice = text:sub(str_index, child_start - 1)

            add_textslice(textslice, new_children, literal_mt, indent, depth)

            table.insert(new_children, child)

            str_index = child_end + 1
        end

        local textslice = text:sub(str_index)

        add_textslice(textslice, new_children, literal_mt, indent, depth)

        node.nodes = new_children
    end

    -- down here because i don't care about performance
    for _, child in ipairs(node.nodes) do
        convert_text_nodes(child, indent, depth + 1)
    end

    return node
end

return convert_text_nodes
