
local lgi = require("lgi")
local GLib = lgi.GLib

local priority = GLib.PRIORITY_DEFAULT_IDLE

local WorkLoop = require("src.util.WorkLoop")

---@class LuaX.WorkLoop.GLibIdle : LuaX.WorkLoop
local GLibIdleWorkloop = WorkLoop:extend("GLibIdleWorkloop")

function GLibIdleWorkloop:init()
    ---@diagnostic disable-next-line:undefined-field
    self.super:init()
end

function GLibIdleWorkloop:start ()
    GLib.idle_add(priority, function ()
        self:run_once()

        return self.is_running
    end)
end

return GLibIdleWorkloop