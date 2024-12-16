
# NativeTextElement

`NativeTextElement` is a dumbed-down version of [NativeElement](NativeElement.md), designed to handle exclusively text literals. Most UI frameworks view text literals differently than other elements, so text-specific custom logic can be encapsulated within a class that extends `NativeTextElement`.

`(Pseudocode)`
```lua
local MyNativeElement = NativeElement:extend("MyNativeElement")

function MyNativeElement:set_value(value: string)
function MyNativeElement:get_value(): string
```

## Example

```lua
local MyNativeElement = NativeElement:extend("MyNativeElement")

function MyNativeElement:insert_child (index, elem, is_text)
    if is_text then
        table.insert(self.text_children, index, elem)
    else
        ...
    end 
end

function MyNativeElement:delete_child (index, is_text)
    if is_text then
        table.remove(self.text_children, index)
    else
        ...
    end 
end

...

local MyText = NativeTextElement:extend("MyText")

function MyText:set_value ()
    self.value = value

    -- this isn't the prettiest solution but that's alright
    self.parent:_reload_text()
end

function MyText:get_value ()
    return self.value
end

function MyNativeElement:_reload_text ()
    local slices = {}

    for _, text_elem in ipairs(self.texts) do
        table.insert(slices, text_elem:get_value())
    end

    self:set_prop("text", table.concat(slices,""))
end

-- create_literal allows MyText instances to automatically be created by MyNativeElement
function MyNativeElement.create_literal (value, parent)
    --- By default, NativeTextElement:init(value, parent) calls self:set_value(value) and sets self.parent to parent.
    return MyText(value, parent)
end
```