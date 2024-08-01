
local LuaX = require("src")
local use_state = require("src").use_state

local gshape = require("gears.shape")
local gcolor = require("gears.color")

local BUTTON_SIZE = 16

local BORDER_SIZE=2

-- TODO these should both just be grey. maybe #777777 and #cccccc?
local BORDER_COLOR_NO_HOVER="#000000"
local BORDER_COLOR_HOVER="#ffffff"

local lama = require("awesome.components.Titlebar.lama")

local function darken (color)
    return lama.lighten(color, -15)
end

---@param props { color: string, onclick: function }
local TitlebarButton = LuaX(function (props)
    local is_hovered, set_hovered = use_state(false)

    return [[
        <wibox.container.background 
            bg={is_hovered and darken(props.color) or props.color} 

            forced_width={BUTTON_SIZE}
            forced_height={BUTTON_SIZE} 

            shape={gshape.circle}
            shape_border_width={BORDER_SIZE}
            shape_border_color={is_hovered and BORDER_COLOR_HOVER or BORDER_COLOR_NO_HOVER}

            signal::mouse::enter={function ()
                set_hovered(true)
            end}
            signal::mouse::leave={function ()
                set_hovered(false)
            end}

            signal::button::press={props.onclick}
        >
            <wibox.widget.textbox />
        </wibox.container.background>
    ]]
end)

return TitlebarButton