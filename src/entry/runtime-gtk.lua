
---@class LuaX.Runtime.Web : LuaX.Runtime
local runtime = require("src.entry.runtime")

local GtkElement = require("src.util.NativeElement.GtkElement")
runtime.GtkElement = GtkElement
runtime.TargetElement = GtkElement

local GLibIdleWorkLoop = require("src.util.WorkLoop.GLibIdle")
runtime.GLibIdleWorkLoop = GLibIdleWorkLoop
runtime.TargetWorkLoop = GLibIdleWorkLoop

return runtime