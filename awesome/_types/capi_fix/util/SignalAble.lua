---@meta

-- TODO come back to this when lua-language-server fixes the generic class inheritance issue
-- https://github.com/LuaLS/lua-language-server/issues/1861
---@class Awesome.ClassSignalable<T>: { connect_signal: fun(signal: string | T, callback: function), emit_signal: fun(signal: string | T, ...: any), disconnect_signal: fun (signal: string | T, callback: function) } https://awesomewm.org/doc/api/classes/signals.html

-- TODO automate creating links to the documentation

---@class Awesome.InstanceSignalable<T>: { connect_signal: fun(self: table, signal: string | T, callback: function), emit_signal: fun(self: table, signal: string | T, ...: any), disconnect_signal: fun (self: table, signal: string | T, callback: function) } https://awesomewm.org/doc/api/classes/signals.html
---@alias Awesome.Signalable<T> Awesome.InstanceSignalable<T> | Awesome.ClassSignalable<T>