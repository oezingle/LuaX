local clean_node            = require("v3.util.xml.clean_node")
local get_indent            = require("v3.util.xml.get_indent")
local remove_default_indent = require("v3.util.xml.remove_default_indent")
local replace_fragments     = require("v3.util.xml.replace_fragments")

local slaxml                = require("lib.slaxml")

--[[
    TODO needs to support this kind of syntax
    
    <Element value={0}>

    </Element>
]]

---@param xml string
---@return SLAXML.Node.Document
local function parse_xml(xml)
    -- replace fragments, remove default indent.
    local xml_deindented = remove_default_indent(replace_fragments(xml))

    local indent = get_indent(xml_deindented)

    local doc = slaxml:dom(xml_deindented, { simple = true })

    return clean_node(doc, indent)
end

return parse_xml
