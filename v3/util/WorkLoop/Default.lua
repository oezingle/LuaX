local WorkLoop = require("v3.util.WorkLoop.init")

---@class LuaX.DefaultWorkLoop : LuaX.WorkLoop
local DefaultWorkLoop = WorkLoop:extend("DefaultWorkLoop")

function DefaultWorkLoop:init()
    warn(
        "LuaX Renderer is using a default work loop! " ..
        "This is not recommended as it will freeze " ..
        "the main thread until rendering is done."
    )
    
    ---@diagnostic disable-next-line:undefined-field
    self.super:init()
end

function DefaultWorkLoop:add(cb)
    self:list_enqueue(cb)

    -- removed - recursively calls itself 
    --if not self.is_running then
    --    self:start()
    --end
end

function DefaultWorkLoop:start()
    -- start guard
    if self.is_running then
        return
    end

    if self:list_is_empty() then
        self.is_running = false

        return
    end

    self.is_running = true

    local cb = self:list_dequue()

    while cb do
        cb()

        cb = self:list_dequue()
    end

    self.is_running = false
end

return DefaultWorkLoop
