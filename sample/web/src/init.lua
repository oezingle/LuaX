local js = require("js")
local document = js.global.document
local null = js.null

local LuaX = require("LuaX")
local WebElement = LuaX.WebElement
local WebWorkLoop = LuaX.WebWorkLoop
local use_state = LuaX.use_state

-- Import polyfills
warn = require("polyfill.warn")
error = require("polyfill.error")

local Title = require("components.Title")

local function main()
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

        local js_backend = js.wasm and "Wasmoon" or "Fengari"

        return [[
            <>
                <Title>
                    LuaX & {js_backend}
                </Title>

                <h1>
                    This site is built with LuaX and {js_backend}!
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
    local renderer = LuaX.Renderer(WebWorkLoop)

    renderer:render(app, root)
end

main()
