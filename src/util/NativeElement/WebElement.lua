local NativeElement = require("src.util.NativeElement")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")

local js = require("js")
local document = assert(js.global.document, "Could not load document - is this file running in a browser?")
local null = js.null

---@class LuaX.WebElement : LuaX.NativeElement
local WebElement = NativeElement:extend("LuaX.WebElement")

function WebElement:init(node)
    self.node = node

    self.events_registered = {}
    self.event_listeners = {}
end

---@protected
function WebElement:get_trailing_children(index)
    local children = self.node.childNodes

    local after = {}
    for i = index, #children do
        local child = children[i]
        table.insert(after, child)

        -- TODO is this the best way to do this??
        child:remove()
    end

    return after
end

function WebElement:reinsert_trailing_children(list)
    for _, child in ipairs(list) do
        self.node:append(child)
    end
end

function WebElement:insert_child(index, element)
    local trailing = self:get_trailing_children(index)

    self.node:append(element.node)

    self:reinsert_trailing_children(trailing)
end

function WebElement:delete_child(index)
    local child = self.node.childNodes[index]

    child:remove()
end

function WebElement:set_prop(prop, value)
    if prop:sub(1, 2) == "on" and type(value) == "function" then
        local event = prop:sub(3)

        if not self.events_registered[event] then
            local listeners = self.event_listeners

            -- removeEventListener doesn't work (because fengari-interop
            -- re-marshalls the handler) so I have to create a throwaway handler
            self.node:addEventListener (event, function (e)
                local listener = listeners[event]
                if listener then
                    listener(e)
                end
            end)

            self.events_registered[event] = true
        end

        self.event_listeners[event] = value
    else
        self.node:setAttribute(prop, value)
    end
end

function WebElement:get_prop(prop)
    -- TODO getAttribute doesn't work??

    return self.node.attributes[prop]
end

function WebElement.get_root(native)
    assert(native ~= null, "WebElement root may not be null")

    return WebElement(native)
end

function WebElement:get_native()
    return self.node
end

function WebElement.create_element(name)
    local node = document:createElement(name)

    return WebElement(node)
end

---@class LuaX.WebText : LuaX.NativeTextElement
local WebText = NativeTextElement:extend("WebText")

function WebText:init(node)
    self.node = node
end

function WebText:set_value(value)
    self.node.data = value
end

function WebText:get_value()
    return self.node.data
end

function WebElement.create_literal(value)
    local node = document:createTextNode(value)

    return WebText(node)
end

return WebElement
