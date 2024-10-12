
# Setting up your LuaX environment

LuaX's library is agnostic in terms of what interface library or functionality is provided to it. This means that it can work effectively with nearly any UI library, provided a compatible NativeElement implementation. see [NativeElement](./NativeElement.md) for information on developing your own implementations.

```lua
local SomeElement = require("LuaX.util.NativeElement.SomeElement")
local LuaX = require("LuaX")
local Renderer = LuaX.Renderer
local create_element = LuaX.create_element

local App = require("App")

local function main ()
    -- Uses a default (blocking) workloop by default
    local renderer = Renderer()

    local element = create_element(App, {})

    local container = native_element_library.get_element("root")

    local root = SomeElement.get_root(container)

    renderer:render(element, root)
end

main()
```