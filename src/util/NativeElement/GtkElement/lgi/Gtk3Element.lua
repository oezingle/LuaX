local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local GObject = lgi.GObject

local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")

---@class LuaX.GtkElement.LGI_V3 : LuaX.GtkElement
local Gtk3Element = NativeElement:extend("LuaX.GtkElement (lgi,3.0)")

-- TODO generate events and connect to signals on the fly 
-- https://stackoverflow.com/questions/5822191/attaching-double-click-event-to-a-label
-- https://github.com/lgi-devs/lgi/blob/master/docs/guide.md#34-signals

--[[
Gtk3Element.components = {
    "Gtk.Box",
    "Gtk.VBox",
    "Gtk.HBox",
    "Gtk.Label"
}
]]

function Gtk3Element:init(native, widget_name)
    self.widget = native
    -- show elements by default
    self.widget:show()

    self.widget_name = widget_name

    self.texts = {}

    self.signal_functions = {}
    self.signal_ids = {}
end

function Gtk3Element:set_prop(prop, value)
    if prop:match("^on_") then
        local existing_handler = self.signal_ids[prop]
        if existing_handler then
            -- LGI doesn't implement signal disconnection.
            GObject.signal_handler_disconnect(self.widget, existing_handler)
        end

        self.signal_functions[prop] = value
        self.signal_ids[prop] = self.widget[prop]:connect(value)
    else
        self.widget["set_" .. prop](self.widget, value)
    end
end

function Gtk3Element:get_prop(prop)
    if prop:match("^on_") then
        return self.signal_functions[prop]
    end

    return self.widget["get_" .. prop](self.widget)
end

---@protected
function Gtk3Element:get_trailing_children(index)
    local children = self.widget:get_children()

    local after = {}
    for i = index, #children do
        local child = children[i]

        table.insert(after, child)
        child:ref()
        self.widget:remove(child)
    end

    return after
end

---@protected
function Gtk3Element:reinsert_trailing_children(list)
    for _, child in ipairs(list) do
        self.widget:add(child)
        child:unref()
    end
end

-- TODO some widgets have set_child - if :add doesn't exist (must check using pcall) then use set_child and throw error if multiple children set
-- TODO test
function Gtk3Element:insert_child(index, element, is_text)
    if is_text then
        table.insert(self.texts, index, element)

        -- TODO can I remove this?
        self:_reload_text()
    else
        print(self:get_type(), "insert", index, is_text)

        local after = self:get_trailing_children(index)

        self.widget:add(element.widget)

        self:reinsert_trailing_children(after)
    end
end

-- TODO test
function Gtk3Element:delete_child(index, is_text)
    if is_text then
        table.remove(self.texts, index)
    else
        local after = self:get_trailing_children(index + 1)

        local children = self.widget:get_children()
        local remove_child = children[index]

        self.widget:remove(remove_child)
        remove_child:destroy()

        self:reinsert_trailing_children(after)
    end
end

function Gtk3Element:get_type()
    return self.widget_name
end

---@param name string
function Gtk3Element.create_element(name)
    ---@type string|nil
    local elem = name:match("Gtk%.(%S+)")

    assert(elem, "GtkElement must be specified by Gtk.<Name>")

    local native = Gtk[elem]()

    assert(native, string.format("No Gtk.%s", elem))

    return Gtk3Element(native, name)
end

function Gtk3Element.get_root(native)
    return Gtk3Element(native, "root")
end

function Gtk3Element:_reload_text()
    local texts = {}

    for _, text_element in ipairs(self.texts) do
        table.insert(texts, text_element.value)
    end

    local text = table.concat(texts, "")

    self:set_prop("label", text)
end

local GtkText = NativeTextElement:extend("LuaX.GtkElement.Text (lgi,3.0)")

function GtkText:set_value(value)
    self.value = value

    self.parent:_reload_text()
end

function GtkText:get_value()
    return self.value
end

---@param value string
---@param parent LuaX.WiboxElement
function Gtk3Element.create_literal(value, parent)
    return GtkText(value, parent)
end

return Gtk3Element
