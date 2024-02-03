local WiboxElement   = require("src.util.NativeElement.WiboxElement")
local Renderer       = require("src.util.Renderer.Profiled")
local GearsWorkLoop  = require("src.util.WorkLoop.Gears")
-- local use_effect = require("src.hooks.use_effect")
local use_state      = require("src.hooks.use_state")
local create_element = require("src.create_element")
local Fragment       = require("src.components.Fragment")

require("src.util.replace_warn")

--[[
local function toggle_button(props)
    local on, set_on = use_state(false)

    return create_element("wibox.widget.textbox", {
        text = on and "I'm enabled" or "I'm disabled",

        ["signal::button::press"] = function()
            set_on(function(on)
                print("toggling button to", not on)

                return not on
            end)
        end
    })
end
]]

local function App ()
    local render, set_render = use_state(false)

    return create_element("wibox.layout.flex.horizontal", {
        children = {
            create_element(Fragment, {
                children = {
                    create_element("wibox.widget.textbox", {
                        text = render and "Rendering children (click)" or "Not rendering children (click)",
        
                        ["signal::button::press"] = function ()
                            set_render(function (render) 
                                return not render
                            end)
                        end
                    }),
                    render and create_element("wibox.widget.textbox", {
                        text = "I'm attached to the button in a Fragment!"
                    }),
                }
            }),
            render and create_element(Fragment, {
                children = {
                    create_element("wibox.widget.textbox", {
                        text = "I'm the first child!"
                    }),
                    create_element("wibox.widget.textbox", {
                        text = "I'm the second child!"
                    })
                }
            })
        }
    })
end

local function render_to_wibox(container)
    local renderer = Renderer(GearsWorkLoop)

    --[[
    local element = create_element("wibox.layout.flex.horizontal", {
        children = {
            -- "HELLO I AM TEXT NODE!!",
            create_element(toggle_button, {}),

        },
    })
    ]]

    local element = create_element(App, {})

    local root = WiboxElement.get_root(container)

    renderer:render(element, root)
end

return render_to_wibox
