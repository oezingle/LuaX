
# NativeElement 

[`src/util/NativeElement/NativeElement.lua`](../src/util/NativeElement/NativeElement.lua)

In order to keep LuaX interface agnostic, we extend the abstract class `NativeElement`. 
To connect your interface library of choice, you only need to implement a few functions:

```lua
local MyNativeElement = NativeElement:extend("MyNativeElement")

function MyNativeElement:set_prop(prop_name: string, value: any)

function MyNativeElement:insert_child(index: number, element: MyNativeElement, is_text: boolean)
function MyNativeElement:delete_child(index: number, is_text: boolean)

--- static class function
function MyNativeElement.create_element(type: string): MyNativeElement

--- static class function
function MyNativeElement.get_root(native: any): MyNativeElement
```

On top of these mandatory methods, it's recommended that NativeElement 
subclasses implement the following:

<!-- 
--- Optional Methods (recommended)
---@field get_type  nil | fun(self: self): string
---@field create_literal nil | fun(value: string, parent: LuaX.NativeElement): LuaX.NativeElement TODO special rules here?
---
---@field get_prop fun(self: self, prop: string): any
---
---@field components string[]? class static property - components implemented by this class.
-->

```lua
function MyNativeElement:get_type(): string

function MyNativeElement:get_prop(prop: string): any

MyNativeElement.components = {
    -- a list of component types, as strings, that this class implements.
}
```

There's one special optional static function, `create_literal`, which lets you
implement special logic if your interface library doesn't handle text in the 
same way as components.

```lua
function MyNativeElement.create_literal (value: string, parent: MyNativeElement): LuaX.NativeElement
```

## Recommendations

### `:init()` should consume interface objects

Generally, this it's recommended `MyNativeElement:init()` takes a native 
representation of that component as its argument. This would mean
`MyNativeElement.create_element` and `MyNativeElement.get_root` can be very 
simple functions, eg:

```lua
function MyNativeElement:init(native)
    self.native = native
end

function MyNativeElement.create_element(type)
    -- Here, interface_library represents the black box of whatever interface
    -- library your project uses.
    local elem = interface_library.create(type)
    
    return MyNativeElement(elem)
end

function MyNativeElement.get_root(native)
    return MyNativeElement(native)
end
```

### implement `:get_prop()`

Retrieving a prop is done, by default, using a virtual props table. This is wasteful and slow.

## `create_literal` and `NativeTextElement`

Because many libraries handle text in a manner very different to LuaX's syntax, 
which is based on HTML, we saw fit to create a helper class for text elements.
See [NativeTextElement](NativeTextElement.md) for more.

## Examples
- [`WiboxElement.lua`](../src/util/NativeElement/WiboxElement.lua): Native elements for [AwesomeWM](https://awesomewm.org). Uses `create_literal` and `NativeTextElement`