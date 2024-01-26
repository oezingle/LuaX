
local NativeElement = require("v3.util.NativeElement")
local string_split = require("v3.util.polyfill.string.split")
local list_reduce = require("v3.util.polyfill.list.reduce")
local wibox = require("wibox")

---@class WiboxElement : LuaX.NativeElement
local WiboxElement = NativeElement:extend("WiboxElement")

function WiboxElement:init(native, type)
    self.wibox = native

    self.type = type
end

function WiboxElement:set_prop(prop, value)
    self.wibox[prop] = value
end
function WiboxElement:get_prop(prop)
    return self.wibox[prop]
end

function WiboxElement:insert_child(index, element)
    table.insert(self.wibox.children, index, element.wibox)
end
function WiboxElement:delete_child(index)
    table.remove(self.wibox.children, index)
end

function WiboxElement:get_type()
    return self.type
end

function WiboxElement.create_element(component)
    -- every widget & layout starts with wibox. , so remove it here
    local wibox_name = string.sub(component, 7)

    local fields = string_split(wibox_name, "%.")

    local widget_type = list_reduce(fields, function(object, key)
        return object[key]
    end, wibox)

    local widget = wibox.widget { widget = widget_type }

    return WiboxElement(widget, component)
end

-- TODO should chain to parent, not a new widget
function WiboxElement.create_literal(value)
    local widget = wibox.widget {
        widget = wibox.widget.textbox,
        text = value
    }

    return WiboxElement(widget, "wibox.widget.textbox")
end

function WiboxElement.get_root(native)
    return WiboxElement(native, "UNKNOWN (root element)")
end

return WiboxElement
