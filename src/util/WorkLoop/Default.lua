local WorkLoop = require("src.util.WorkLoop")
local warn = require("src.util.polyfill.warn")

---@class LuaX.WorkLoop.Default : LuaX.WorkLoop
local DefaultWorkLoop = WorkLoop:extend("DefaultWorkLoop")

---@param opts { supress_warning?: boolean }
function DefaultWorkLoop:init(opts)
    opts = opts or {}

    if not opts.supress_warning then
        warn(
            "LuaX Renderer is using a default (synchronous) work loop! " ..
            "This is not recommended as it will freeze " ..
            "the main thread until rendering is done."
        )
    end

    ---@diagnostic disable-next-line:undefined-field
    self.super:init()
end

function DefaultWorkLoop:start()
    while self.is_running do
        self:run_once()
    end
end

return DefaultWorkLoop
