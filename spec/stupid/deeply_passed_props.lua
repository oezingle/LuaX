
local LuaX = require("src.init")()
local XMLElement = require("src.util.NativeElement.XMLElement")

local renderer = require("src.util.Renderer.Profiled")()

local create_element = LuaX.create_element
-- local render = LuaX.render

local use_state = LuaX.use_state
local use_effect = LuaX.use_effect


local function inner_function_component (props)
    return create_element("innest", {
        children = props.message
    })
end

local function state_component()
    local message, set_message = use_state()
    
    use_effect(function ()
        set_message("Hello World!")
    end, {})

    return create_element("div", {
        children = {
            create_element("inner", {
                children = {
                    create_element(inner_function_component, {
                        message = message
                    })
                }
            })
        }
    })
end


local element = create_element(state_component, {})


local root = XMLElement.get_root({
    type = "root",
    children = {}
})

renderer:render(element, root)

print(root)

print(renderer.calls, "calls to render()")