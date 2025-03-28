local has_lgi, lgi = pcall(require, "lgi")
if not has_lgi then
    error("Cannot load lgi, therefore cannot load Gtk 3.0 using lgi")
end

local has_Gtk, Gtk = pcall(lgi.require, "Gtk", "3.0")
if not has_Gtk then
    error("Loaded lgi, but cannot load Gtk 3.0 using lgi")
end

local has_GObject, GObject = pcall(lgi.require, "GObject")
if not has_GObject then
    error("Loaded lgi and Gtk, but cannot load GObject using lgi. Are you sure Gtk is installed properly?")
end

local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")

---@class LuaX.GtkElement.LGI_V3 : LuaX.GtkElement
local Gtk3Element = NativeElement:extend("LuaX.GtkElement (lgi,3.0)")

--[[
Gtk3Element.components = {
    "Gtk.Box",
    "Gtk.VBox",
    "Gtk.HBox",
    "Gtk.Label"
}
]]

-- TODO spinners should :start on init()?
function Gtk3Element:init(native, widget_name)
    -- show elements by default
    if native then
        native:show()
    end

    self.widget = native

    self.widget_name = widget_name

    self.texts = {}

    self.signal_functions = {}
    self.signal_ids = {}
end

function Gtk3Element:set_prop(prop, value)
    local widget = self.widget

    if prop == "show" then
        if value == false then
            widget:hide()
        else
            widget:show()
        end
    elseif prop:match("^on_") then
        local existing_handler = self.signal_ids[prop]
        if existing_handler then
            -- LGI doesn't implement signal disconnection.
            GObject.signal_handler_disconnect(widget, existing_handler)
        end

        self.signal_functions[prop] = value
        if value then
            self.signal_ids[prop] = widget[prop]:connect(value)
        else
            self.signal_ids[prop] = nil
        end
    else
        widget["set_" .. prop](widget, value)
    end
end

function Gtk3Element:get_prop(prop)
    local widget = self.widget

    if prop == "show" then
        return widget:get_visible()
    end

    if prop:match("^on_") then
        return self.signal_functions[prop]
    end

    return widget["get_" .. prop](widget)
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
function Gtk3Element:insert_child(index, element, is_text)
    if is_text then
        table.insert(self.texts, index, element)

        self:_reload_text()
    else
        local after = self:get_trailing_children(index)

        self.widget:add(element.widget)

        self:reinsert_trailing_children(after)
    end
end

function Gtk3Element:delete_child(index, is_text)
    if is_text then
        table.remove(self.texts, index)
    else
        local after = self:get_trailing_children(index + 1)

        local children = self.widget:get_children()
        local remove_child = children[index]

        self.widget:remove(remove_child)

        self:reinsert_trailing_children(after)
    end
end

function Gtk3Element:cleanup ()
    self.widget:destroy()
end

function Gtk3Element:get_native()
    return self.widget
end

---@param name string
function Gtk3Element.create_element(name)
    ---@type string|nil
    local elem = name:match("Gtk%.(%S+)")

    assert(elem, string.format("GtkElement must be specified by Gtk.<Name> (Could not resolve %q)", name))

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
