
-- LuaX does not handle LuaJIT's lack of a searcher for <module>/init.lua, so we must add it to the path
do
    local sep = package.path:match("[/\\]")
    local local_init = ("./?/init.lua"):gsub("/", sep)
    
    if not package.path:match("%.[/\\]?[/\\]init%.lua") then
        package.path = package.path .. ";" .. local_init
    end
end

---@type LuaX
local LuaX = require("src")
local GtkElement = LuaX.GtkElement
local ErrorBoundary = LuaX.ErrorBoundary
local Suspense = LuaX.Suspense
local use_context = LuaX.use_context
local use_suspense = LuaX.use_suspense
local GLibIdleWorkloop = require("src.util.WorkLoop.GLibIdle")

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gio = lgi.Gio
local GLib = lgi.GLib

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






local map = function(list, cb)
    local ret = {}
    for i, item in ipairs(list) do
        ret[i] = cb(item)
    end
    return ret
end

local MessageContext = LuaX.Context("Hello World!")

local Display = LuaX(function()
    local message = use_context(MessageContext)

    return [[
        <LuaX.Gtk.Label>
            {message}
        </LuaX.Gtk.Label>
    ]]
end)

local ContextPage = LuaX(function()
    local messages = {
        { value = "Message 1!" },
        { value = "Message 2!" },
        -- Passing a nil value to MessageContext.Provider results in the default value being returned by use_context
        { value = nil }
    }

    return [[
        <LuaX.Gtk.VBox>
            {map(messages, function (message)
                return (
                    <MessageContext.Provider value={message.value} >
                        <>
                            <Display />
                        </>
                    </MessageContext.Provider>
                )
            end)}
        </LuaX.Gtk.VBox>
    ]]
end)










local ErrorComponent = LuaX(function()
    return [[
        <LuaX.Gtk.Button on_clicked={function ()
            error("Throw up!")
        end}>
            I'm going to throw up!
        </LuaX.Gtk.Button>
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

local ErrorPage = LuaX(function()
    return [[
        <LuaX.Gtk.VBox>
            <ErrorBoundary fallback={ErrorMessage}>
                <ErrorComponent />
            </ErrorBoundary>
        </LuaX.Gtk.VBox>
    ]]
end)










local SuspenseComponent = LuaX(function()
    -- Because Lua doesn't have a default Promises implementation, use_suspense
    -- returns two functions - suspend() defers rendering, and resolve() does
    -- the opposite.
    local suspend, resolve = use_suspense()

    local clicks, set_clicks = use_state(0)

    -- We use GLib.timeout_add to create a 1 second delay every time the click
    -- count changes.
    use_effect(function()
        print("Suspend")
        suspend()

        GLib.timeout_add(0, 1000, function()
            print("Resolve")
            resolve()
            return false
        end)
    end, { clicks })

    return [[
        <LuaX.Gtk.Button
            on_clicked={function ()        
                set_clicks(function (clicks)
                    return clicks + 1
                end)
            end}
        >
            Hello World!
        </LuaX.Gtk.Button>
    ]]
end)

local SuspensePage = LuaX(function()
    return [[
        <LuaX.Gtk.VBox>
            <Suspense fallback={<LuaX.Gtk.Spinner LuaX::onload={function (w) w:start() end} />}>
                <SuspenseComponent />
            </Suspense>
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
                "Contexts",
                "Error boundary",
                "Suspense"
            }}
        >
            -- page 1: use_state clicking example
            <LuaX.Gtk.VBox>
                <LuaX.Gtk.Label>
                    You clicked {clicks} times!
                </LuaX.Gtk.Label>

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

            -- page 2: contexts
            <ContextPage />

            -- page 3: error boundary
            <ErrorPage />

            -- page 4: suspense
            <SuspensePage />
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
