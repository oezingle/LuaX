
# Setting up your LuaX environment

LuaX's library is agnostic in terms of what interface library or functionality is provided to it. This means that it can work effectively with nearly any UI library, provided a compatible NativeElement implementation. see [NativeElement](./NativeElement.md) for information on developing your own implementations.

```lua
local SomeElement = require("LuaX.util.NativeElement.SomeElement")
local LuaX = require("LuaX")
local Renderer = LuaX.Renderer
local create_element = LuaX.create_element

-- App is a function component
local App = require("App")

local function main ()
    -- Uses a default (blocking) workloop by default
    local renderer = Renderer()

    local element = create_element(App, {})

    local container = native_element_library.get_element("root")

    -- LuaX requires a class that extends NativeElement in order to interface with your UI library
    local root = SomeElement.get_root(container)

    renderer:render(element, root)
end

main()
```

LuaX will now render components using that library! You can use elements from
the UI library, but you can also write reusable functions that implement logic
tied to these elements. See [Components](./components.md)

## WorkLoops

LuaX uses a lightweight WorkLoop class to store rendering tasks. Because Lua
doesn't feature an event loop, the default WorkLoop is blocking. The WorkLoop
base class ([src/util/WorkLoop/WorkLoop.lua](../src/util/WorkLoop/WorkLoop.lua))
is easily extensible for non-blocking event loops.
[GLibIdleWorkLoop](../src/util/WorkLoop/GLibIdle.lua) is a good example,
providing support for Gtk/GLib's `GLib.MainLoop`. 

In order to render content in the proper hierarchical manner, WorkLoops
internally use Queues. However, neither a user of LuaX nor a WorkLoop
implementation developer must worry about these details. the WorkLoop base class
provides `WorkLoop:run_once()`, which will call and consume the next item in the
list. A WorkLoop implementation must only implement `:start()`, and in some cases
`:stop()`. Again, see GLibIdleWorkLoop for an example.