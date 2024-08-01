---@meta

---@alias Awesome.Button.Signal "press" | "property::button" | "property::modifiers" | "release"

---@class Awesome.CButton
---@field button Awesome.MouseButton the button connected to the button

---@alias Awesome.Button Awesome.CButton | Awesome.InstanceSignalable<Awesome.Button.Signal> 

---@class Awesome.CButtonModule
---@field instances fun(): integer Get the number of instances. This includes removed buttons
---@field set_index_miss_handler fun(cb: function) Set a __index metamethod for all button instances. 
---@field set_newindex_miss_handler fun(cb: function) Set a __newindex metamethod for all button instances. 

---@alias Awesome.ButtonModule Awesome.CButtonModule | Awesome.ClassSignalable<Awesome.Button.Signal>