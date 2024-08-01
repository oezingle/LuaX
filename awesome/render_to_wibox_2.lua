local WiboxElement   = require("src.util.NativeElement.WiboxElement")
local Renderer       = require("src.util.Renderer")
local GearsWorkLoop  = require("src.util.WorkLoop.Gears")
local create_element = require("src.create_element")
local Profiler       = require("src.util.Profiler")

require("src.util.replace_warn")

---@diagnostic disable-next-line:lowercase-global
awesome = awesome or {}

local LuaX = require("src")

LuaX.register()

-- local Wibox = require("awesome.Wibox")
local Button = require("awesome.Button")

local wibox = require("wibox")
wibox.widget.slider = require("awesome.mod.slider")

-- local ColorPicker = require("awesome.ColorPicker")
local Titlebar = require("awesome.components.Titlebar.Titlebar")
local ClientTitlebar = require("awesome.components.global.ClientTitlebar")

local App = LuaX(function()
    return [[
        <>
            <ClientTitlebar>
                <Titlebar />
            </ClientTitlebar>
        </>
    ]]
end)

local USE_PROFILER = false

local function render_to_wibox(container)
    ---@type LuaX.Profiler
    local profiler
    if USE_PROFILER then
        profiler = Profiler({
            ignore = {
                "^/usr/share/lua/5%.3/lgi",
                "^/usr/share/awesome/lib"
            }
        }) --[[ @as LuaX.Profiler ]]
    end

    -- local renderer = Renderer(GearsWorkLoop)
    local renderer = Renderer()

    local element = create_element(App, {})

    local root = WiboxElement.get_root(container)

    if USE_PROFILER then
        profiler:start()
    end

    renderer:render(element, root)

    awesome.connect_signal("exit", function()
        if USE_PROFILER then
            profiler:dump("profiler/callgrind.out.awesome-ColorPicker", "KCacheGrind")
        end
    end)
end

return render_to_wibox
