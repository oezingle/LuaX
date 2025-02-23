
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
local GLibIdleWorkloop = require("src.util.WorkLoop.GLibIdle")

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gio = lgi.Gio
local Gdk = lgi.Gdk -- looks unused, but our "Semi-legal events" page makes use of Gdk.EventMask

-- require("lib.log").level = "trace"

warn("@on")

local use_state = LuaX.use_state
local use_effect = LuaX.use_effect

local min = math.min

-- see docs/Parser.md in regard to the "LuaX." on every Gtk element name

-- Gtk.Notebook has a complicated API, which we'll abstract away using a component
local EasyNotebook = LuaX(function(props)
    local labels = props.labels or {}

    local notebook, set_notebook = use_state(nil)
    local page_count, set_page_count = use_state(0)

    use_effect(function()
        if not notebook then
            return
        end

        if page_count == 0 then
            return
        end

        if page_count ~= #labels then
            warn(string.format("EasyNotebook expected %d labels, found %d", page_count, #labels))
        end

        local iterations = min(page_count, #labels)
        for i = 1, iterations do
            local child = notebook:get_nth_page(i - 1)

            notebook:set_tab_label_text(child, labels[i])
        end
    end, { notebook, labels, page_count })

    return [[
        <LuaX.Gtk.Notebook
            -- The LuaX library handles this special property
            LuaX::onload={function (w) set_notebook(w) end}

            on_page_added={function (w)
                set_page_count(w:get_n_pages())
            end}
            on_page_removed={function (w)
                set_page_count(w:get_n_pages())
            end}
        >
            {props.children}
        </LuaX.Gtk.Notebook>
    ]]
end)

local ToggleVisibility = LuaX(function()
    local show, set_show = use_state(true)

    return [[
        <LuaX.Gtk.VBox>
            <LuaX.Gtk.Label show={show}>
                Toggle my visibility!
            </LuaX.Gtk.Label>

            <LuaX.Gtk.Button
                on_clicked={function ()
                    set_show(function (show)
                        return not show
                    end)
                end}
            >
                Click here
            </LuaX.Gtk.Button>
        </LuaX.Gtk.VBox>
    ]]
end)

local App = LuaX(function()
    local clicks, set_clicks = use_state(0)

    -- Demos will maintain their states because they're all being rendered
    -- simultaneously into the EasyNotebook.
    return [[
        <EasyNotebook
            labels={{
                "Click counter",
                "Semi-legal events",
                "Toggle element visibility"
            }}
        >
            -- page 1: use_state clicking example
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

            -- page 2: hacking mouse events!
            <LuaX.Gtk.VBox>
                <LuaX.Gtk.Label>
                    I am normal.
                </LuaX.Gtk.Label>

                <LuaX.Gtk.Label
                    has_window
                    events={Gdk.EventMask.ALL_EVENTS_MASK}
                    on_button_press_event={function ()
                        print("press")
                    end}
                    on_button_release_event={function ()
                        print("release")
                    end}
                    on_enter_notify_event={function ()
                        print("mouse enter")
                    end}
                    on_leave_notify_event={function ()
                        print("mouse leave")
                    end}
                >
                    I consume click events & hover events (though I shouldn't!)
                </LuaX.Gtk.Label>
            </LuaX.Gtk.VBox>

            <ToggleVisibility />
        </EasyNotebook>
    ]]
end)

local app = Gtk.Application.new("LuaX.GtkExample", Gio.ApplicationFlags.DEFAULT_FLAGS)

function app:on_startup()
    local window = Gtk.ApplicationWindow.new(self)
    window:set_title("LuaX demo")

    local root = GtkElement.get_root(window)
    local elem = LuaX.create_element(App, {})

    -- GLibIdleWorkloop provides slightly smoother animations compared to the
    -- default blocking WorkLoop, but only functions under a GLib MainLoop
    local renderer = LuaX.Renderer(GLibIdleWorkloop)
    renderer:render(elem, root)

    self:add_window(window)
end

function app:on_activate()
    self.active_window:show()
    self.active_window:present()
end

return app:run({ arg[0], ... })
