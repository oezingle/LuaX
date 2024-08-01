local WiboxElement   = require("src.util.NativeElement.WiboxElement")
local use_effect     = require("src.hooks.use_effect")
local create_element = require("src.create_element")
local clone_element = require("src.clone_element")
local ClientContext  = require("awesome.ClientContext")

local awful          = require("awful")
local wibox          = require("wibox")

local clientlib      = client


---@param props LuaX.Props.WithInternal<LuaX.PropsWithChildren<{ bg_normal?: string, bg_focus?: string, position?: Awesome.Direction }>>
local ClientTitlebar = function(props)
    local position = props.position or "top"
    local bg_normal = props.bg_normal or "#777777"
    local bg_focus = props.bg_focus or "#eeeeee"

    local renderer = props.__luax_internal.renderer

    ---@param client Awesome.Client
    local titlebar_cb = function(client)
        -- client.has_titlebar = true

        local widget = wibox.widget {
            widget = wibox.layout.stack
        }

        local root = WiboxElement.get_root(widget)

        -- TODO this fucks everything up. ClientContext only provides initial value for some reason.
        local provided = create_element(ClientContext.Provider, {
            children = clone_element(props.children),
            value = client
        })

        renderer:render(provided, root)

        local titlebar = awful.titlebar(client, {
            position = position,

            bg_normal = bg_normal,
            bg_focus = bg_focus
        })

        titlebar.widget = widget
    end

    use_effect(function()
        clientlib.connect_signal("request::titlebars", titlebar_cb)

        return function()
            clientlib.disconnect_signal("request::titlebars", titlebar_cb)
        end
    end)

    return nil
end

return ClientTitlebar
