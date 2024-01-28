local WorkLoop = require("src.util.WorkLoop")

---@class LuaX.DefaultWorkLoop : LuaX.WorkLoop
local DefaultWorkLoop = WorkLoop:extend("DefaultWorkLoop")

---@param opts { supress_warning?: boolean }
function DefaultWorkLoop:init(opts)
    opts = opts or {}

    if not opts.supress_warning then
        warn(
            "LuaX Renderer is using a default work loop! " ..
            "This is not recommended as it will freeze " ..
            "the main thread until rendering is done."
        )
    end

    ---@diagnostic disable-next-line:undefined-field
    self.super:init()
end

function DefaultWorkLoop:add(cb)
    self:list_enqueue(cb)
end

function DefaultWorkLoop:start()
    -- start guard
    if self.is_running then
        return
    end

    self.is_running = true

    while self.is_running do
        self:run_once()
    end
end

function DefaultWorkLoop:run_once()
    if self:list_is_empty() then
        self.is_running = false

        return
    end

    local cb = self:list_dequue()

    cb()
end

return DefaultWorkLoop
