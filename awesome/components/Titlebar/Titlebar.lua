
local LuaX = require("src")
local TitlebarButton = require("awesome.components.Titlebar.TitlebarButton")
local use_client     = require("awesome.hooks.use_client")

local Titlebar = LuaX(function (props)
    local client = use_client({
        "name",
    })

    local function quit_client ()
        client:kill()
    end

    return [[
        <wibox.layout.align.horizontal>
            <TitlebarButton color="#ff00ff" onclick={quit_client} />

            <wibox.container.background fg="#000000">
                <wibox.widget.textbox>
                    {"  "}{client.name}
                </wibox.widget.textbox>
            </wibox.container.background>
        </wibox.layout.align.horizontal>
    ]]
end)

return Titlebar