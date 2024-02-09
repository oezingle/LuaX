local WiboxElement   = require("src.util.NativeElement.WiboxElement")
local Renderer       = require("src.util.Renderer")
local GearsWorkLoop  = require("src.util.WorkLoop.Gears")
local use_state      = require("src.hooks.use_state")
local create_element = require("src.create_element")
local Fragment       = require("src.components.Fragment")

require("src.util.replace_warn")

local LuaX = require("src")

LuaX.register()

local Button = require("awesome.Button")

local function App()
    local render, set_render = use_state(false)

    local IS_COMPLEX = true
        
    return create_element("wibox.layout.flex.horizontal", {
        children = {
            create_element(Fragment, {
                children = {
                    create_element("wibox.widget.textbox", {
                        text = render and "Rendering children (click)" or "Not rendering children (click)",

                        ["signal::button::press"] = function()
                            set_render(function(render)
                                return not render
                            end)
                        end
                    }),
                    IS_COMPLEX and render and create_element("wibox.widget.textbox", {
                        text = "I'm attached to the button in a Fragment!"
                    }),
                }
            }),
            IS_COMPLEX and render and create_element(Fragment, {
                children = {
                    create_element("wibox.widget.textbox", {
                        text = "I'm the first child!"
                    }),
                    create_element("wibox.widget.textbox", {
                        text = "I'm the second child!"
                    })
                }
            }),
            create_element(Button, {
                onclick = function(widget, lx, ly, button, e, f)
                    print("Clicked " .. (button == 1 and "Left" or "Right"))
                end,
                children = render and create_element(Fragment, {
                    children = {
                        "Or don't."
                    }
                }) or create_element("LITERAL_NODE", { value = "Click me" })
            })
        }
    })
end

local function render_to_wibox(container)
    local renderer = Renderer(GearsWorkLoop)

    local element = create_element(App, {})

    local root = WiboxElement.get_root(container)

    renderer:render(element, root)
end

--[[
local callgrind = require("lib.lua-callgrind")

return function ()
    callgrind(render_to_wibox, "awesome-callgrind.txt")
end
]]

return render_to_wibox