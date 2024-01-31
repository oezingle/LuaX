--local clean_node            = require("src.util.xml.parse.clean_node")
local get_indent            = require("src.util.xml.parse.get_indent")
local remove_default_indent = require("src.util.xml.parse.remove_default_indent")
local replace_fragments     = require("src.util.xml.parse.replace_fragments")
local convert_text_nodes    = require("src.util.xml.parse.convert_text_nodes")

local htmlparser = require("lib.htmlparser")

--[[
    TODO needs to support this kind of syntax

    <Element value={0}>

    </Element>
]]

---@param xml string
---@return HTMLParser.Node
local function parse_xml(xml)
    -- replace fragments, remove default indent.
    local xml_deindented = remove_default_indent(replace_fragments(xml))

    local indent = get_indent(xml_deindented)

    local doc = htmlparser.parse(xml_deindented)

    return convert_text_nodes(doc, indent)
end

return parse_xml
