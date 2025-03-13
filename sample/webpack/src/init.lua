
local null = require("js").null

local vanilla_error = error
error = function(msg, level)
    msg = debug.traceback(msg)

    vanilla_error(msg, level)
end

local LuaX = require("LuaX")
local WebElement = LuaX.WebElement

local use_state = LuaX.use_state

local document = require("js").global.document

local root_div = document:querySelector("#content")
assert(root_div ~= null, "No div to mount")
local root = WebElement.get_root(root_div)
local App = LuaX(function(props)
    local clicks, set_clicks = use_state(0)

    local onclick = function(e)
        set_clicks(function(c)
            return c + 1
        end)
    end

    return [[
        <>
            <h1>
                This site is built with LuaX and Fengari!
            </h1>

            <p>
                You've clicked {clicks} times
            </p>

            <button onclick={onclick}>
                Click me!
            </button>
        </>
    ]]
end)

local app = LuaX.create_element(App, {})
local renderer = LuaX.Renderer()

renderer:render(app, root)
