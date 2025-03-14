
---@class LuaX.Runtime.Web : LuaX.Runtime.Targeted
local runtime = require("src.entry.runtime")

local WebElement = require("src.util.NativeElement.WebElement")
runtime.WebElement = WebElement
runtime.TargetElement = WebElement

local WebWorkLoop = require("src.util.WorkLoop.Web")
runtime.WebWorkLoop = WebWorkLoop
runtime.TargetWorkLoop = WebWorkLoop

return runtime