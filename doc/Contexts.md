
# Contexts 

Another feature LuaX borrows from React is passing data deeply with Contexts.
There are many cases you would want to provide information to child components.
However, this becomes a much harder task given any sort of complexity - let's
say we want to pass props to a component further down, as in the example below:

```lua
local LuaX = require("LuaX")
local RibbonButton = require("RibbonButton")

local MyRibbonSection = LuaX(function (props)
    return [[
        <>
            <RibbonButton onclick={props.onclick} >Account</RibbonButton>
            <RibbonButton onclick={props.onclick} >Sign Out</RibbonButton>
        </>
    ]]
end)

local MyRibbonLabel = LuaX(function (props)
    local function onclick ()

    end

    return [[
        <>
            <RibbonButton onclick={onclick} >Search</RibbonButton>

            -- this gets cumbersome quickly!
            <MyRibbonSection onclick={onclick} />
        </>
    ]]
end)
```

This complexity can become extremely annoying, especially if you must pass properties through a generic component! Contexts remedy this.

```lua
local LuaX = require("LuaX")
local Context = LuaX.Context
local use_context = LuaX.use_context
local RibbonButton = require("RibbonButton")

--- In this case, we're defining a context that provides a function
---@type LuaX.Context<function>
local RibbonContext = Context.create(function () end)

-- we redefine the RibbonButton, but this time we consume the RibbonContext to avoid passing onclick around.
local MyRibbonButton = LuaX(function (props)
    local onclick = use_context(RibbonContext)

    return [[
        <RibbonButton onclick={props.onclick}>{props.children}</RibbonButton>
    ]]
end)

local MyRibbonSection = LuaX(function (props)
    return [[
        <>
            <MyRibbonButton>Account</MyRibbonButton>
            <MyRibbonButton>Sign Out</MyRibbonButton>
        </>
    ]]
end)

local MyRibbonLabel = LuaX(function (props)
    local function onclick () print("click!") end

    return [[
        <RibbonContext.Provider value={onclick}>
            <MyRibbonButton>Search</MyRibbonButton>

            -- this gets cumbersome quickly!
            <MyRibbonSection/>
        </RibbonContext.Provider>
    ]]
end)
```

Contexts are extremely powerful, and surely the average application of them is beyond the scope of a simple example. 

## Caveats

Note that LuaX's Context implementation does not provide `Context.Consumer`. Users are urged to define a simple function component instead.