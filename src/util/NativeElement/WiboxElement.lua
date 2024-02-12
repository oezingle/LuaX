local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")
local string_split = require("src.util.polyfill.string.split")
local list_reduce = require("src.util.polyfill.list.reduce")
local wibox = require("wibox")


---@class WiboxElement : LuaX.NativeElement
---@field texts WiboxText[]
local WiboxElement = NativeElement:extend("WiboxElement")

function WiboxElement:init(native, type)
    self.wibox = native

    self.texts = {}

    self.signal_handlers = {}

    self.type = type
end

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

function WiboxElement:insert_child(index, element, is_text)
    if is_text then
        table.insert(self.texts, index, element)

        self:_reload_text()
    else
        self.wibox:insert(index, element.wibox)
    end
end

function WiboxElement:delete_child(index, is_text)
    if is_text then
        table.remove(self.texts, index)
    else
        self.wibox:remove(index)
    end
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

function WiboxElement.get_root(native)
    return WiboxElement(native, "UNKNOWN (root element)")
end

function WiboxElement:_reload_text()
    local texts = {}

    for _, text_element in ipairs(self.texts) do
        table.insert(texts, text_element.value)
    end

    local text = table.concat(texts, "")

    self:set_prop("text", text)
end

---@class WiboxText : LuaX.NativeTextElement
---@field protected parent WiboxElement
---@field value string
local WiboxText = NativeTextElement:extend("WiboxText")

function WiboxText:set_value(value)
    self.value = value

    self.parent:_reload_text()
end

-- TODO seems like it might not working.
function WiboxText:get_prop(prop) 
    if prop ~= "value" then
       return nil 
    end

    return self.value
end

---@param value string
---@param parent WiboxElement
function WiboxElement.create_literal(value, parent)
    return WiboxText(value, parent)
end

return WiboxElement
