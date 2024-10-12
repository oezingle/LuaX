
# hooks

Hooks are the system within LuaX enabling its reactivity. When a hook creates a
change, the component automatically re-renders itself. Other hooks detect these
changes, allowing you to dynamically call external dependencies when values
change.

## use_state

The `use_state` hook is the most simple in LuaX, holding a value between
re-renders.

```lua
local LuaX = require("LuaX")
local use_state = LuaX.use_state

local MyCounter = LuaX(function ()
    local clicks, set_clicks = use_state(0)
    
    return [[
        <>
            <button onclick={set_clicks(clicks + 1)}>
                Click me!
            </button>

            <textbox>
                Clicked {clicks} times!
            </textbox>
        </>
    ]]
end)
```

`use_state` takes one argument, a default value. It then returns the value,
along with a setter function. The setter can take a value or a function that
consumes the current value. For example, the `onclick` callback of our button
could look like 
```lua
set_clicks(function (clicks) 
    return clicks + 1 
end)
```

If you wish to set the value of a state variable to a function, simply pass a
function that returns a function.

## use_effect

`use_effect` acts as a counter to `use_state` - every time a dependent value
changes, its callback fires. We'll modify the above example to see it in action.

```lua
local LuaX = require("LuaX")
local use_state = LuaX.use_state
local use_effect = LuaX.use_effect

local MyCounter = LuaX(function ()
    local clicks, set_clicks = use_state(0)
    
    use_effect(function ()
        print(string.format("The user clicked %d times!", clicks))
    end, { clicks })

    return [[
        <>
            <button onclick={set_clicks(clicks + 1)}>
                Click me!
            </button>

            <textbox>
                Clicked {clicks} times!
            </textbox>
        </>
    ]]
end)
```

`use_effect` callbacks can also return unmount hooks - that is, a function that fires when the component re-renders or is removed.

```lua
local value, set_value = use_state(nil)

use_effect(function ()
    local signal_callback = function (signal_value)
        set_value(signal_value)
    end

    connect_signal(signal_callback)

    return function ()
        disconnect_signal(signal_callback)
    end
end)
```