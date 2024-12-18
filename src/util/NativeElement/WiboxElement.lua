local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")
local string_split = require("src.util.polyfill.string.split")
local list_reduce = require("src.util.polyfill.list.reduce")
local wibox = require("wibox")

---@class LuaX.WiboxElement : LuaX.NativeElement
---@field texts WiboxText[]
local WiboxElement = NativeElement:extend("WiboxElement")

function WiboxElement:init(native, type)
    -- print(type, "create")

    self.wibox = native

    self.texts = {}

    self.signal_handlers = {}

    self.type = type
end

---@param prop string
---@param value any
function WiboxElement:set_prop(prop, value)
    -- print(self:get_type(), "set prop", prop, value)

    local wibox = self.wibox

    -- support LuaX::onload
    if prop:match("^LuaX::") then
        local prop_name = prop:sub(7)

        if prop_name == "onload" then
            value(self, wibox)
        end
    elseif prop:match("^signal::") then
        local signal_name = prop:sub(9)

        if value then
            wibox:weak_connect_signal(signal_name, value)
        end

        self.signal_handlers[prop] = value
    else
        wibox[prop] = value
    end
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

        -- TODO can I remove this? WiboxText calls for us
        self:_reload_text()
    else
        if self.wibox.insert then
            self.wibox:insert(index, element.wibox)
        elseif self.wibox.get_children and self.wibox.set_children then
            local children = self.wibox:get_children()

            table.insert(children, element.wibox)

            self.wibox:set_children(children)
        else
            error(string.format("Unable to insert child to wibox %s", self.wibox))
        end
    end
end

function WiboxElement:delete_child(index, is_text)
    if is_text then
        table.remove(self.texts, index)
    else
        if self.wibox.remove then
            self.wibox:remove(index)
        elseif self.wibox.get_children and self.wibox.set_children then
            local children = self.wibox:get_children()

            table.remove(children, index)

            self.wibox:set_children(children)
        else
            error(string.format("Unable to insert child with wibox %s", self.wibox))
        end
    end
end

function WiboxElement:get_type()
    return self.type
end

---@param component string
function WiboxElement.create_element(component)
    -- every widget & layout starts with wibox. , so remove it here
    local wibox_name = string.sub(component, 7)

    local fields = string_split(wibox_name, "%.")

    local widget_type = list_reduce(fields, function(object, key)
        return object[key]
    end, wibox)

    assert(widget_type, string.format("No known widget of name %q", component))

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
---@field protected parent LuaX.WiboxElement
---@field value string
local WiboxText = NativeTextElement:extend("WiboxText")

function WiboxText:set_value(value)
    self.value = value

    self.parent:_reload_text()
end

function WiboxText:get_value()
    return self.value
end

---@param value string
---@param parent LuaX.WiboxElement
function WiboxElement.create_literal(value, parent)
    return WiboxText(value, parent)
end

return WiboxElement
