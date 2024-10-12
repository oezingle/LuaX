
local log = require("lib.log.log")

if false then
    ---@alias Logger.LogFunction fun(...: any)
    
    ---@class Log
    ---@field trace Logger.LogFunction
    ---@field debug Logger.LogFunction
    ---@field info Logger.LogFunction
    ---@field warn Logger.LogFunction
    ---@field error Logger.LogFunction
    ---@field fatal Logger.LogFunction
    ---
    ---@field usecolor boolean
    ---@field logfile string?
    ---@field level "trace" | "debug" | "info" | "warn" | "error" | "fatal"
    log = {}
end

log.level = "warn"

return log