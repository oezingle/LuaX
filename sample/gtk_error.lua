-- LuaX does not handle LuaJIT's lack of a searcher for <module>/init.lua, so we must add it to the path
do
    local sep = package.path:match("[/\\]")
    local local_init = ("./?/init.lua"):gsub("/", sep)
    
    if not package.path:match("%.[/\\]?[/\\]init%.lua") then
        package.path = package.path .. ";" .. local_init
    end
end

local LuaX = require("src")
local GtkElement = require("src.util.NativeElement.GtkElement")
local ErrorBoundary = LuaX.ErrorBoundary

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

-- This component throws an error
local ErrorComponent = LuaX(function()
    error("Throw up!")

    return [[
        <LuaX.Gtk.Label>
            I'm going to throw up!
        </LuaX.Gtk.Label>
    ]]
end)

-- If you wish to consume the error with your fallback component, passing the
-- component (as opposed to an instance of it) to ErrorBoundary will create the
-- element, passing the error in props
local ErrorMessage = LuaX(function (props)
    local err = props.error
    
    return [[
        <LuaX.Gtk.Label>
            An error occurred {err and " - " .. err or ""}
        </LuaX.Gtk.Label>
    ]]
end)

local App = LuaX(function()
    return [[
        <LuaX.Gtk.VBox>
            <ErrorBoundary fallback={ErrorMessage}>
                <ErrorComponent />
            </ErrorBoundary>
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
