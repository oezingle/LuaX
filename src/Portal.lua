local class = require("lib.30log")
local use_effect = require("src.hooks.use_effect")
local use_memo   = require("src.hooks.use_memo")
local use_state  = require("src.hooks.use_state")
local Context    = require("src.Context")
local use_context= require("src.hooks.use_context")
local create_element = require("src.create_element")

local map = require("src.util.polyfill.list.map")

-- I'm ignoring major.minor.patch for Portals for now.
warn("Portals are an experimental feature and are subject to change until the next minor release")

---@class LuaX.Portal : Log.BaseFunctions
---
---@field Inlet LuaX.Component<LuaX.PropsWithChildren>
---@field Outlet LuaX.Component
---
---@field Context LuaX.Context<LuaX.Portal>
---
---@field name string | "LuaX.Portal"
---@field protected children { uid: number, child: LuaX.ElementNode[] }[]
---
---@field protected GenericProvider LuaX.Component<LuaX.PropsWithChildren>
---@field protected GenericInlet LuaX.Component<LuaX.PropsWithChildren>
---@field protected GenericOutlet LuaX.Component
local Portal = class("LuaX.Portal")

---@alias LuaX.Portal.UID number

-- Probably fine for our usages
-- TODO run the stats on this.
---@return LuaX.Portal.UID
function Portal:unique ()
    return math.random(0xFFFF)
end

-- TODO backwards compatible react-like Portal.create overload? Portal.create(ElementNode, NativeElement, key?)

-- TODO test exotic configurations:
-- - portal to non-root NativeElement, same renderer
-- - portal to non-root NativeElement on different renderer

local rtfm = [[
    Portal is a class that must be instanciated before use:
        local MyPortal = Portal()

        return (
            <>
                <MyPortal.Outlet />

                <MyPortal.Inlet>
                    Hello World!
                </MyPortal.Inlet>
            </>
        )

    consider reading doc/Portals.md
]]
Portal.Inlet = function () error(rtfm) end
Portal.Outlet = Portal.Inlet

function Portal:init(name)
    self.name = name
    
    self.children = {}
    
    self.observers = setmetatable({}, { __mode ="k" })

    self.Outlet = function ()
        return self:GenericOutlet()
    end
    self.Inlet = function (props)
        return self:GenericInlet(props)
    end
    self.Provider = function (props)
        return self:GenericProvider(props)
    end
end

---@param cb function
function Portal:observe (cb)
    self.observers[cb] = true
end

---@param cb function
function Portal:unobserve (cb)
    self.observers[cb] = nil
end

function Portal:update ()
    for cb in pairs(self.observers) do
        cb()
    end
end

---@param uid LuaX.Portal.UID
---@param child LuaX.ElementNode | LuaX.ElementNode[]
function Portal:add_child (uid, child)
    for _, existing in ipairs(self.children) do
        -- check if this existing child entry has the given UID
        if existing.uid == uid then
            existing.child = child
            self:update()
            
            return
        end
    end

    -- if we haven't returned yet, insert a new child
    table.insert(self.children, { uid = uid, child = child })
    self:update()
end

---@param uid LuaX.Portal.UID
---@return boolean
function Portal:remove_child (uid)
    for i, existing in ipairs(self.children) do
        if existing.uid == uid then
            table.remove(self.children, i)
            self:update()

            return true
        end
    end

    return false
end

---@param props LuaX.PropsWithChildren<{}>
function Portal:GenericInlet (props)
    local children = props.children

    local uid = use_memo(function ()
        return self:unique()
    end, {})

    use_effect(function ()
        self:add_child(uid, children)

        return function ()
            self:remove_child(uid)
        end
    end, { children })

    return nil
end

function Portal:GenericOutlet()
    local re, set_re = use_state(0)
    local rerender = function ()
        set_re(re + 1)
    end

    use_effect(function ()
        self:observe(rerender)

        return function ()
            self:unobserve(rerender)
        end
    end)

    return map(self.children, function (data)        
        return data.child
    end)
end

---@type LuaX.Context<LuaX.Portal>
Portal.Context = Context()

function Portal:GenericProvider (props)
    local table = use_context(Portal.Context) or {}

    local name = self.name

    use_effect(function ()
        table[name] = self

        return function ()
            table[name] = nil
        end
    end, { self })

    return create_element(Portal.Context.Provider, { children = props.children, value = table })
end


---@param name string?
function Portal.create (name)
    return Portal(name)
end

return Portal
