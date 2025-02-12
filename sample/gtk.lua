
local LuaX = require("src")
local GtkElement = require("src.util.NativeElement.GtkElement")

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gio = lgi.Gio

-- require("lib.log").level = "trace"

warn("@on")

local App = LuaX(function ()
    local clicks, set_clicks = LuaX.use_state(0)

    -- see docs/Parser.md in regard to the "LuaX." on every element name
    return [[
        <LuaX.Gtk.VBox>
            <LuaX.Gtk.Label>
                You clicked {clicks} times!
            </LuaX.Gtk.Label>

            {clicks > 10 and
                <LuaX.Gtk.Label>
                    More than 10!
                </LuaX.Gtk.Label>
            }

            <LuaX.Gtk.Button
                on_clicked={function ()
                    set_clicks(function (clicks)
                        return clicks + 1
                    end)
                end}
            >
                Click me!
            </LuaX.Gtk.Button>
        </LuaX.Gtk.VBox>
    ]]
end)

local app = Gtk.Application.new("LuaX.GtkExample", Gio.ApplicationFlags.DEFAULT_FLAGS)

function app:on_startup()
    local window = Gtk.ApplicationWindow.new(self)
    window:set_title("LuaX demo")

    local root = GtkElement.get_root(window)
    local elem = LuaX.create_element(App, {})
    local renderer = LuaX.Renderer()
    renderer:render(elem, root)

    self:add_window(window)
end

function app:on_activate()
    self.active_window:show_all()
    self.active_window:present()
end

return app:run({ arg[0], ... })
