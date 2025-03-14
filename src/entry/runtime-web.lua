
---@class LuaX.Runtime.Web : LuaX.Runtime
local runtime = require("src.entry.runtime")

runtime.WebElement = require("src.util.NativeElement.WebElement")

runtime.WebWorkLoop = require("src.util.WorkLoop.Web")

return runtime