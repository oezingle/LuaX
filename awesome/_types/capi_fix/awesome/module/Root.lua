---@meta

---@alias Awesome.Root.Fake.KeyInput fun(event_type: "key_press"|"key_release", char: string|"Super_L"|"Control_L"|"Shift_L"|"Alt_L"|"Super_R"|"Control_R"|"Shift_R"|"Alt_R")
---@alias Awesome.Root.Fake.MouseInput fun(event_type: "button_press"|"button_release", detail: Awesome.MouseButton)
---@alias Awesome.Root.Fake.MotionInput fun(event_type: "motion_notify", relative: boolean, x: integer, y: integer)

---@class Awesome.Root
---@field fake_input Awesome.Root.Fake.KeyInput|Awesome.Root.Fake.MouseInput|Awesome.Root.Fake.MotionInput Send fake keyboard or mouse events. [Link](https://awesomewm.org/doc/api/libraries/root.html#fake_input)
---@field keys Awesome.Util.GetterOrSetter<Awesome.Key[]> Get or set global key bindings. These bindings will be available when you press keys on the root window. [Link](https://awesomewm.org/doc/api/libraries/root.html#keys)
---@field buttons Awesome.Util.GetterOrSetter<Awesome.Button[]> Get or set global mouse bindings. This binding will be available when you click on the root window. [Link](https://awesomewm.org/doc/api/libraries/root.html#buttons)
---@field cursor fun(cursor_name: Awesome.Util.XCursor) Set the root cursor. [Link](https://awesomewm.org/doc/api/libraries/root.html#cursor)
---@field drawins fun(): unknown[] Get the drawins attached to a screen. [Link](https://awesomewm.org/doc/api/libraries/root.html#drawins)
---@field wallpaper fun(pattern: Awesome.Gears.Surface) Get the wallpaper as a cairo surface or set it as a cairo pattern. [Link](https://awesomewm.org/doc/api/libraries/root.html#wallpaper)
---@field size fun(): integer, integer Get the size of the root window. [Link](https://awesomewm.org/doc/api/libraries/root.html#size)
---@field size_mm fun(): integer, integer Get the physical size of the root window, in millimeter. [Link](https://awesomewm.org/doc/api/libraries/root.html#size_mm)
---@field tags fun(): Awesome.Tag[] Get the attached tags. [Link](https://awesomewm.org/doc/api/libraries/root.html#tags)
