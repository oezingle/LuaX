local LuaX = require("src")

local use_state      = require("src.hooks.use_state")
local use_memo       = require("src.hooks.use_memo")

---@param number number
local function tohex(number)
    return string.format("%02x", number)
end

local ColorSlider = LuaX(function(props)
    return [[
        <wibox.widget.slider
            maximum={255}
            minimum={0}

            bar_height={3}
            bar_color="#ff0000"

            handle_color="#00ff00"
            handle_width={10}

            value={props.value}

            signal::property::value={function (w)
                -- props.on_change(w.value)
            end}

            signal::button::release={function (w)
                -- print("release", w.value)

                props.on_change(w.value)
            end}
        />
    ]]
end)


local ColorPicker = LuaX(function()
    local color_r, set_color_r = use_state(0)
    local color_g, set_color_g = use_state(0)
    local color_b, set_color_b = use_state(0)
    local color_a, set_color_a = use_state(255)

    local color_hex = use_memo(function()
        return "#" ..
            tohex(color_r) ..
            tohex(color_g) ..
            tohex(color_b) ..
            tohex(color_a)
    end, { color_r, color_g, color_b, color_a })

    -- print(color_hex)

    return [[
        <wibox.layout.flex.horizontal>
            <wibox.container.background bg="#ffffff77">
                <wibox.layout.flex.vertical>
                    <ColorSlider value={color_r} on_change={function (value)
                        set_color_r(value)
                    end} />

                    <ColorSlider value={color_g} on_change={function (value)
                        set_color_g(value)
                    end} />

                    <ColorSlider value={color_b} on_change={function (value)
                        set_color_b(value)
                    end} />

                    <ColorSlider value={color_a} on_change={function (value)
                        set_color_a(value)
                    end} />
                </wibox.layout.flex.vertical>
            </wibox.container.background>

            <wibox.layout.align.vertical>
                <wibox.container.place forced_height={24}>
                    <wibox.widget.textbox>{color_hex}</wibox.widget.textbox>
                </wibox.container.place>
                
                <wibox.container.background bg={color_hex}>
                    <wibox.widget.textbox></wibox.widget.textbox>
                </wibox.container.background>
            </wibox.layout.align.vertical>
        </wibox.layout.flex.horizontal>
    ]]
end)

return ColorPicker