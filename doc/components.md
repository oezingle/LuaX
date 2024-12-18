# Developing components

As a user of LuaX, most of your work will be in writing components. Components are written in a HTML-like syntax, enabling you
to work on visual elements with a familiar coding style.

## LuaX in Vanilla Lua

LuaX provides a number of facilities to write LuaX components within a `.lua` file, although you can also use `.luax` files to write LuaX code as if it were a native language feature. That feature will be covered later in this article.

### Decorator syntax

LuaX can wrap functions that return strings, transpiling them automatically at
runtime.

`src/components/MyComponent.lua`
```lua
local LuaX = require("LuaX")
local textbox = require("src.components.textbox")

local MyComponent = LuaX(function (props)
    local name = props.name

    return [[
        <textbox color="white">
            Hello {name}!
        </textbox>
    ]]
end)

return MyComponent
```

### Return syntax *(Not recommended)*

LuaX can also be called when you return from your component function. This is not recommended.

`src/components/MyComponent.lua`
```lua
local LuaX = require("LuaX")
local textbox = require("src.components.textbox")

local function MyComponent (props)
    local name = props.name

    return LuaX([[
        <textbox color="white">
            Hello {name}!
        </textbox>
    ]])
end
```

### LuaX without LuaX syntax

Using LuaX's rendering features without HTML-like syntax is possible too.

`src/components/MyComponent.lua`
```lua
local LuaX = require("LuaX")
local textbox = require("src.components.textbox")

local function MyComponent (props)
    local name = props.name

    return LuaX.create_element(textbox, {
        color = "white",
        children = {
            "Hello " .. name .. "!"
        }
    })
end
```

## `.luax` files

Alongside vanilla Lua, LuaX also supports its own `.luax` format. Language
server support is unfortunately not yet available, but is planned.

`src/components/MyComponent.luax`
```lua
local Textbox = require("src.components.Textbox")

local function MyComponent (props)
    local name = props.name

    return (
        <Textbox color="white">
            Hello {name}!
        </Textbox>
    )
end
```

Vanilla lua programs can load `.luax` files once `LuaX.register()` has been
called. This adds the luax loader into `package.loaders` or `package.searchers`
(depending on Lua version) 