local NativeElement = require("v3.util.NativeElement.init")
local split         = require("v3.util.polyfill.string.split")

---@class LuaX.XMLElement : LuaX.NativeElement
---@field native { type: string, props: table<string, any>, children: LuaX.XMLElement[] }
---@operator call:LuaX.XMLElement
local XMLElement = NativeElement:extend("XMLElement")

function XMLElement:init(native)
    self.native = native
end

function XMLElement.create_element(element_type)
    return XMLElement({ type = element_type, props = {}, children = {} })
end

function XMLElement:set_prop(prop, value)
    self.native.props[prop] = value
end

function XMLElement:set_child(index, element)
    self.native.children[index] = element
end

function XMLElement.get_root(xml)
    return XMLElement(xml)
end

-- This is NOT a good xml serializer
function XMLElement:__tostring()
    local type = self.native.type

    local props = {}
    for prop, value in pairs(self.native.props or {}) do
        local prop_str = string.format("%s=\"%s\"", prop, tostring(value))

        table.insert(props, prop_str)
    end
    local props_str = table.concat(props, " ")

    if #self.native.children == 0 then
        return string.format("<%s %s/>", type, props_str)
    end

    local children = {}
    for _, child in ipairs(self.native.children) do
        local child_strings = split(tostring(child), "\n")
        
        for _, child_string in ipairs(child_strings) do
            table.insert(children, "\t" .. child_string)            
        end
    end

    return string.format("<%s %s>\n%s\n</%s>", type, props_str, table.concat(children, "\n"), type)
end

return XMLElement