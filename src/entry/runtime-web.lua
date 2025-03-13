
---@class LuaX.Runtime.Web : LuaX.Runtime
local runtime = require("src.entry.runtime")

runtime.WebElement = require("src.util.NativeElement.WebElement")

return runtime