
local WorkLoop = require("src.util.WorkLoop")
local gears = require("gears")

---@class LuaX.WorkLoop.Gears : LuaX.WorkLoop
local GearsWorkLoop = WorkLoop:extend("GearsWorkLoop")

function GearsWorkLoop:init()
    ---@diagnostic disable-next-line:undefined-field
    self.super:init()

    self.timer = gears.timer {
        timeout = 0.01,
        single_shot = false,
        callback = function ()
            self:run_once()
        end
    }
end

function GearsWorkLoop:stop()
    self.timer:stop()
end

function GearsWorkLoop:start()
    self.timer:start()
end

return GearsWorkLoop