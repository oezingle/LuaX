
local Div = require("src.components.html.Div")
local create_element = require("src.create_element")
local render         = require("src.util.render")

LuaX = {}

local elem = create_element(Div, {
    class="FUCK",
    children = {
        create_element(Div, {
            class="SHIT"
        })
    }
})

local render = render(elem)

print(render)