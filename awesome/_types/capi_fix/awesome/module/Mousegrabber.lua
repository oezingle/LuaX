---@meta

---@alias Awesome.Mousegrabber.Callback fun(coords: Awesome.MouseCoordsWithButtons): boolean

---@class Awesome.Mousegrabber
---@field run fun(func: Awesome.Mousegrabber.Callback, cursor: Awesome.Util.XCursor) Grab the mouse pointer and list motions, calling callback function at each motion. The callback function must return a boolean value: true to continue grabbing, false to stop. The function is called with one argument: a table containing modifiers pointer coordinates. [Link](https://awesomewm.org/doc/api/libraries/mousegrabber.html#run)
---@field stop fun() Stop grabbing the mouse pointer. [Link](https://awesomewm.org/doc/api/libraries/mousegrabber.html#stop)
---@field isrunning fun(): boolean Check if mousegrabber is running. [Link](https://awesomewm.org/doc/api/libraries/mousegrabber.html#isrunning)