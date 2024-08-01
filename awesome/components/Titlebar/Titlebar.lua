
local LuaX = require("src")
local TitlebarButton = require("awesome.components.Titlebar.TitlebarButton")
local use_client     = require("awesome.hooks.use_client")

local Titlebar = LuaX(function (props)
    local client = use_client()

    local function quit_client ()
        client:kill()
    end

    -- print("client is", client)

    return [[
        <wibox.layout.align.horizontal>
            <TitlebarButton color="#ff00ff" onclick={quit_client} />

            <wibox.widget.textbox>
                {client.name}
            </wibox.widget.textbox>
        </wibox.layout.align.horizontal>
    ]]
end)

return Titlebar