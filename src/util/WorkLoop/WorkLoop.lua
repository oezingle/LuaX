local class        = require("lib.30log")
local table_pack   = require("src.util.polyfill.table.pack")
local table_unpack = require("src.util.polyfill.table.unpack")
local DrawGroup    = require("src.util.Renderer.DrawGroup")
local traceback    = require("src.util.debug.traceback")

---@alias LuaX.WorkLoop.Item { [1]: function, number: any }

---@class LuaX.WorkLoop : Log.BaseFunctions
---@field protected list_dequue fun(self: self): LuaX.WorkLoop.Item
---@field protected list_enqueue fun(self: self, cb: function, ...)
---@field protected list_is_empty fun(self: self): boolean
---@field protected list LuaX.WorkLoop.Item[]
---@field protected head integer
---@field protected tail integer
---@field protected run_once fun(self: self)
---
--- Abstract
---@field protected is_running boolean
---@field protected stop fun(self: self)
---@field protected start fun(self: self)
---@field safe_start fun(self: self)
---
--- Abstract optional
---@field add fun(self: self, cb: function, ...: any)
local WorkLoop     = class("WorkLoop")

function WorkLoop:init()
    self.list = {}
    self.head = 0
    self.tail = 0
end

function WorkLoop:list_dequue()
    self.head = self.head + 1

    local ret = self.list[self.head]

    self.list[self.head] = nil

    return ret
end

function WorkLoop:list_enqueue(...)
    local item = table_pack(...)

    self.tail = self.tail + 1
    self.list[self.tail] = item
end

function WorkLoop:list_is_empty()
    return self.tail - self.head == 0
end

function WorkLoop:add(cb, ...)
    self:list_enqueue(cb, ...)
end

function WorkLoop:stop()
    self.is_running = false
end

function WorkLoop:run_once()
    if self:list_is_empty() then
        self:stop()
        return
    end

    local item = self:list_dequue()

    -- TODO tie in calling function somehow? for traceback
    local cb = item[1]
    -- luajit has problems with understanding how long tables are. 10 is an arbitrary choice.
    ---@diagnostic disable-next-line:undefined-global
    local upper = jit and 10 or nil
    local ok, err = xpcall(cb, traceback, table_unpack(item, 2, upper))

    if not ok then
        ok = pcall(DrawGroup.error, nil, err)
    end

    if not ok then
        error("DrawGroup error handler failed.\n" .. err)
    end
end

function WorkLoop:safely_start()
    if self.is_running then
        return
    end

    self.is_running = true

    self:start()
end

return WorkLoop
