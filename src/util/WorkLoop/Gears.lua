
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

function GearsWorkLoop:run_once()
    if self:list_is_empty() then
        self.is_running = false

        self.timer:stop()

        return
    end

    local cb = self:list_dequue()

    cb()
end

function GearsWorkLoop:start()
    if self.is_running then
        return
    end

    self.is_running = true

    self.timer:start()
end

return GearsWorkLoop