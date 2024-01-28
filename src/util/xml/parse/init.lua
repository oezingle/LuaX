local clean_node            = require("src.util.xml.parse.clean_node")
local get_indent            = require("src.util.xml.parse.get_indent")
local remove_default_indent = require("src.util.xml.parse.remove_default_indent")
local replace_fragments     = require("src.util.xml.parse.replace_fragments")

-- local htmlparser = require("lib.htmlparser")
local slaxml     = require("lib.slaxml")

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
