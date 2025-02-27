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
local GLibIdleWorkloop = require("src.util.WorkLoop.GLibIdle")

local use_context = LuaX.use_context

local MessageContext = LuaX.Context("Hello World!")

local map = function(list, cb)
    local ret = {}
    for i, item in ipairs(list) do
        ret[i] = cb(item)
    end
    return ret
end

local Display = LuaX(function()
    local message = use_context(MessageContext)

    return [[
        <Gtk.Label>
            {message}
        </Gtk.Label>
    ]]
end)

local App = LuaX(function()
    local messages = {
        { value = "Message 1!" },
        { value = "Message 2!" },
        -- Passing a nil value to MessageContext.Provider results in the default value being returned by use_context
        { value = nil }
    }

    return [[
        <Gtk.VBox>
            {map(messages, function (message)
                return (
                    <MessageContext.Provider value={message.value} >
                        <>
                            <Display />
                        </>
                    </MessageContext.Provider>
                )
            end)}
        </Gtk.VBox>
    ]]
end)

local lgi = require("lgi")
local lGtk = lgi.require("Gtk", "3.0")

local window = lGtk.Window()

local root = GtkElement.get_root(window)
local renderer = LuaX.Renderer(GLibIdleWorkloop)

local app = LuaX.create_element(App, {})
renderer:render(app, root)

window:present()
window:show_all()

lGtk.main()
