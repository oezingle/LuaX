
local WorkLoop = require("src.util.WorkLoop.WorkLoop")
local js = require("js")
local setInterval = js.global.setInterval
local clearInterval = js.global.clearInterval

local WebWorkLoop = WorkLoop:extend("WebWorkLoop")

function WebWorkLoop:start ()
    self.interval = setInterval(function ()
        self:run_once()
    end, -1)
end

function WebWorkLoop:stop()
    clearInterval(self.interval)
    self.interval = nil

    self.is_running = false
end

return WebWorkLoop