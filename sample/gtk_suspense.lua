-- LuaX does not handle LuaJIT's lack of a searcher for <module>/init.lua, so we must add it to the path
do
    local sep = package.path:match("[/\\]")
    local local_init = ("./?/init.lua"):gsub("/", sep)
    
    if not package.path:match("%.[/\\]?[/\\]init%.lua") then
        package.path = package.path .. ";" .. local_init
    end
end

local LuaX = require("src.init")
local GtkElement = require("src.util.NativeElement.GtkElement")
local use_effect = LuaX.use_effect
local use_state = LuaX.use_state
local use_suspense = LuaX.use_suspense
local Suspense = LuaX.Suspense

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local GLib = lgi.GLib

local ErrorComponent = LuaX(function()
    local suspend, resolve = use_suspense()

    local clicks, set_clicks = use_state(0)

    use_effect(function()
        suspend()

        GLib.timeout_add(0, 1000, function()
            resolve()
            return false
        end)
    end, { clicks })

    return [[
        <LuaX.Gtk.Button
            on_clicked={function ()
                print("click")
        
                set_clicks(function (clicks)
                    return clicks + 1
                end)
            end}
        >
            Hello World!
        </LuaX.Gtk.Button>
    ]]
end)

local App = LuaX(function()
    -- The LuaX parser currently
    local spinner = LuaX([[ <LuaX.Gtk.Spinner LuaX::onload={function (w) w:start() end} /> ]])

    return [[
        <LuaX.Gtk.VBox>
            <Suspense fallback={spinner}>
                <ErrorComponent />
            </Suspense>
        </LuaX.Gtk.VBox>
    ]]
end)

local window = Gtk.Window()
window:set_title("LuaX demo")

local root = GtkElement.get_root(window)
local elem = LuaX.create_element(App, {})
local renderer = LuaX.Renderer()

renderer:render(elem, root)

window:present()
Gtk.main()
