
# NativeElement 

[`src/util/NativeElement/NativeElement.lua`](../src/util/NativeElement/NativeElement.lua)

In order to keep LuaX interface agnostic, UI libraries must be integrated by developing a class that extends the abstract class `NativeElement`. 
To connect your interface library of choice, you only need to implement a few functions:

`(Pseudocode)`
```lua
local MyNativeElement = NativeElement:extend("MyNativeElement")

--- Set a property by name. get_prop is optional (see below)
function MyNativeElement:set_prop(prop_name: string, value: any)

--- Get this element's native (UI library) representation.
function MyNativeElement:get_native (): any

--- Insert a child element by index. is_text may be useful if your UI library handles text differently to other elements
function MyNativeElement:insert_child(index: number, element: MyNativeElement, is_text: boolean)
--- Delete a child element by index. see above for information on is_text
function MyNativeElement:delete_child(index: number, is_text: boolean)

--- class function to create a new element given an element type name
function MyNativeElement.create_element(type: string): MyNativeElement

--- class function to create a new element given its native representation. 
--- Note that nil is a valid argument to this function due to Suspenses
function MyNativeElement.get_root(native: any): MyNativeElement
```

On top of these mandatory methods, it's recommended that NativeElement 
subclasses implement the following:

```lua
--- Get a friendly name for the element. Otherwise, the string passed to create_element will be used for debug logs.
function MyNativeElement:get_name(): string

--- Get an element's property by its name. NativeElement will fall back to a virtual list of properties otherwise, which uses excessive memory.
function MyNativeElement:get_prop(prop: string): any

--- Run any custom removal logic before the element is deleted
function MyNativeElement:cleanup()

-- a list of LuaX component names, as strings, that this class implements
MyNativeElement.components = {}
```

There's one special optional static function, `create_literal`, which lets you
implement special logic if your interface library doesn't handle text in the 
same way as other elements.

```lua
function MyNativeElement.create_literal (value: string, parent: MyNativeElement): LuaX.NativeElement
```

## Special properties

## Recommendations

`NativeElement` contains minimal facilities for interface manipulation intentionally, providing primarily helpers to convert LuaX's keys to individual index values, and automatic creation and removal of NativeElement objects. This means that your UI element class can be implemented in many different ways, though following best practices will make development easier.

### `:init()` should consume UI objects as native elements

Generally, this it's recommended `MyNativeElement:init()` takes a native 
representation of that component as its argument. This would mean
`MyNativeElement.create_element` and `MyNativeElement.get_root` can be very 
simple functions, eg:

```lua
function MyNativeElement:init(native)
    self.native = native
end

function MyNativeElement.create_element(type)
    -- Here, interface_library represents the black box of whatever interface library your project uses.
    local elem = interface_library.create(type)
    
    return MyNativeElement(elem)
end

function MyNativeElement.get_root(native)
    return MyNativeElement(native)
end
```

### implement `:get_prop()`

Retrieving a prop is done using a virtual props table by default. This is wasteful and slow.

## `create_literal` and `NativeTextElement`

Because many libraries handle text in a manner very different to LuaX's syntax, 
which is based on HTML, we saw fit to create a helper class for text elements.
See [NativeTextElement](NativeTextElement.md) for more.

## Examples
- [`WiboxElement.lua`](../src/util/NativeElement/WiboxElement.lua): Native elements for [AwesomeWM](https://awesomewm.org). Uses `create_literal` and `NativeTextElement`

## `VirtualElement`

`VirtualElement` is a special class implements a less-than-minimal set of NativeElement methods. It provides object storage for function components, by inserting hook states and any other necessary information into an un-rendered portion of a NativeElement's child table. Your UI element class does not need to consider VirtualElements.