
local slaxml = require("lib.slaxml")
-- local clean_input = require("v3.util.xml.clean_input")

---@param xml string
---@return XML.Node.Document
local function parse_xml (xml)
    -- clean_input

    local doc = slaxml:dom(xml, { simple = true })

    return doc
end

return parse_xml