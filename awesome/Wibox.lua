-- TODO finish this code and see what happens

local use_memo = require("src.hooks.use_memo")
local use_effect = require("src.hooks.use_effect")
local wibox = require("wibox")

local WiboxElement = require("src.util.NativeElement.WiboxElement")

--[[
local NativeElement = require("src.util.NativeElement.NativeElement")

---@class WiboxElement.WiboxRoot : LuaX.NativeElement
local WiboxRoot = NativeElement:extend("WiboxRoot", {
    components = { "Wibox" }
})

function WiboxRoot:init(wibox)
    self.wibox = wibox

    self.children = 0
end

function WiboxRoot:insert_child(child)
    self.children = self.children + 1

    if self.children > 1 then
        error("Wibox may only have a single child")
    end

    self.wibox.widget = child
end

function WiboxRoot:delete_child()
    self.children = self.children - 1

    self.wibox.widget = nil
end

function WiboxRoot:get_class()
    return WiboxElement
end
]]

---@param props LuaX.Props.WithInternal<LuaX.PropsWithChildren<{ width: number, height: number, x: number, y: number, bg: any }>>
local function Wibox(props)
    -- TODO FIXME wibox doesn't clean itself up.
    -- TODO creates stack overflow (but only sometimes??)
    local w = use_memo(function()
        print("Creating wibox")
        
        return wibox({
            visible = true
        })
    end, {})

    use_effect(function()
        w.width = props.width
        w.height = props.height

        w.x = props.x
        w.y = props.y
    end, { props.width, props.height, props.x, props.y })

    use_effect(function ()
        w.bg = props.bg
    end, { props.bg })

    use_effect(function()
        local renderer = props.__luax_internal.renderer

        local root_widget = wibox.widget {
            layout = wibox.layout.stack
        }
        w.widget = root_widget

        ---@type LuaX.NativeElement
        local root = WiboxElement.get_root(root_widget)

        renderer:render(props.children, root)
    end, { props.children })

    return nil
end

return Wibox
