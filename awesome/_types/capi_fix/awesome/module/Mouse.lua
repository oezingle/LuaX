---@meta

---@alias Awesome.MouseButton 1|2|3|4|5

---@alias Awesome.MouseCoordsWithButtons { buttons: { MouseButton: boolean }, x: integer, y: integer}

---@class Awesome.Mouse
---@field screen Screen The screen under the cursor. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#screen)
---@field current_client Awesome.Client|nil Get the client currently under the mouse cursor. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#current_client)
---@field current_wibox Awesome.Wibox Get the wibox currently under the mouse cursor. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#current_wibox)
---@field current_widgets Awesome.Wibox.Widget[]|nil Get the widgets currently under the mouse cursor. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#current_widgets)
---@field current_widget Awesome.Wibox.Widget|nil Get the topmost widget currently under the mouse cursor. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#current_widget)
---@field current_widget_geometry GeometryWithWidget|nil Get the current widget geometry. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#current_widget_geometry)
---@field current_widget_geometries GeometryWithWidget[]|nil Get the current widget geometries. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#current_widget_geometries)
---@field is_left_mouse_button_pressed boolean True if the left mouse button is pressed. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#is_left_mouse_button_pressed)
---@field is_right_mouse_button_pressed boolean True if the right mouse button is pressed. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#is_right_mouse_button_pressed)
---@field is_middle_mouse_button_pressed boolean True if the middle mouse button is pressed. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#is_middle_mouse_button_pressed)
---@field coords (fun(): Awesome.MouseCoordsWithButtons)|fun(coords: Awesome.Coordinates, silent: boolean?) Get or set the mouse coords. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#coords)
---@field object_under_pointer fun(): Awesome.Client|nil Get the client or any object which is under the pointer. [Link](https://awesomewm.org/doc/api/libraries/mouse.html#coords)