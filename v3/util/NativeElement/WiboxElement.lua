local NativeElement = require("v3.util.NativeElement")
local string_split = require("v3.util.polyfill.string.split")
local list_reduce = require("v3.util.polyfill.list.reduce")
local wibox = require("wibox")

---@class WiboxElement : LuaX.NativeElement
local WiboxElement = NativeElement:extend("WiboxElement")

function WiboxElement:init(native, type)
    self.wibox = native

    self.signal_handlers = {}

    self.type = type
end

--[[
local function print_signal_handlers(wibox, signal_name)
    do
        local handlers = wibox._signals[signal_name]

        for k, v in pairs(handlers) do
            print(k, "{")

            for k2, v2 in pairs(v) do
                print("", k2, v2)
            end

            print("}")
        end
    end
end
]]

---@param prop string
---@param value any
function WiboxElement:set_prop(prop, value)
    local wibox = self.wibox

    if prop:match("^signal::") then
        local signal_name = prop:sub(9)

        if self.signal_handlers[prop] then
            local signal_handler = self.signal_handlers[prop]

            wibox:disconnect_signal(signal_name, signal_handler)
        end

        if value then
            wibox:connect_signal(signal_name, value)
        end

        self.signal_handlers[prop] = value

        return
    end

    wibox[prop] = value
end

function WiboxElement:get_prop(prop)
    if self.signal_handlers[prop] then
        return self.signal_handlers[prop]
    end

    return self.wibox[prop]
end

function WiboxElement:insert_child(index, element)
    -- wibox.layout.fixed:insert (index, widget)
    
    self.wibox:insert(index, element.wibox)
    
    --table.insert(self.wibox.children, index, element.wibox)
end

function WiboxElement:delete_child(index)
    print("delete_child", index)

    self.wibox:remove(index)

    -- table.remove(self.wibox.children, index)
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
