do local folder_of_this_file
local module_arg={...}
if module_arg[1] ~= (arg or {})[1] then folder_of_this_file=module_arg[1] .. "."
local is_implicit_init=module_arg[2]:match(module_arg[1] .. "[/\\]init%.lua")
if  not is_implicit_init then folder_of_this_file=folder_of_this_file:match"(.+%.)[^.]+" or "" end else folder_of_this_file=arg[0]:gsub("[^%./\\]+%..+$","")
do local sep=package.path:sub(1,1)
local pwd=sep == "/" and os.getenv"PWD" or io.popen("cd","r"):read"a"
for _ in folder_of_this_file:gmatch"%.%." do pwd=pwd:gsub("[/\\][^/\\]+[/\\]?$","") end
pwd=pwd .. sep
package.path=package.path .. string.format(";%s?.lua;%s?%sinit.lua",pwd,pwd,sep) end
folder_of_this_file=folder_of_this_file:gsub("[/\\]","."):gsub("^%.+","") end
local library_root=folder_of_this_file:sub(1, - 1 -  # "")
require(library_root .. "_shim") end
local class=require"lib_LuaX._dep.lib.30log"
local use_effect=require"lib_LuaX.hooks.use_effect"
local use_memo=require"lib_LuaX.hooks.use_memo"
local use_state=require"lib_LuaX.hooks.use_state"
local Context=require"lib_LuaX.Context"
local use_context=require"lib_LuaX.hooks.use_context"
local create_element=require"lib_LuaX.create_element"

local map=require"lib_LuaX.util.polyfill.list.map"
---@class LuaX.Portal : Log.BaseFunctions

---@field Inlet LuaX.Component<LuaX.PropsWithChildren>
---@field Outlet LuaX.Component

---@field Context LuaX.Context<LuaX.Portal>

---@field name string | "LuaX.Portal"
---@field protected children { uid: number, child: LuaX.ElementNode[] }[]

---@field protected GenericProvider LuaX.Component<LuaX.PropsWithChildren>
---@field protected GenericInlet LuaX.Component<LuaX.PropsWithChildren>
---@field protected GenericOutlet LuaX.Component
warn"Portals are an experimental feature and are subject to change until the next minor release"
---@alias LuaX.Portal.UID number


---@return LuaX.Portal.UID
local Portal=class"LuaX.Portal"
function Portal:unique() return math.random(0xFFFF) end




local rtfm="    Portal is a class that must be instanciated before use:\n        local MyPortal = Portal()\n\n        return (\n            <>\n                <MyPortal.Outlet />\n\n                <MyPortal.Inlet>\n                    Hello World!\n                </MyPortal.Inlet>\n            </>\n        )\n\n    consider reading doc/Portals.md\n"
Portal.Inlet=function () error(rtfm) end
Portal.Outlet=Portal.Inlet
function Portal:init(name) self.name=name
self.children={}
self.observers=setmetatable({},{["__mode"] = "k"})
self.Outlet=function () return self:GenericOutlet() end
self.Inlet=function (props) return self:GenericInlet(props) end
self.Provider=function (props) return self:GenericProvider(props) end end
---@param cb function
function Portal:observe(cb) self.observers[cb]=true end
---@param cb function
function Portal:unobserve(cb) self.observers[cb]=nil end
function Portal:update() for cb in pairs(self.observers) do cb() end end
---@param uid LuaX.Portal.UID
---@param child LuaX.ElementNode | LuaX.ElementNode[]
function Portal:add_child(uid,child) for _,existing in ipairs(self.children) do 
if existing.uid == uid then existing.child=child
self:update()
return  end end

table.insert(self.children,{["uid"] = uid,["child"] = child})
self:update() end
---@param uid LuaX.Portal.UID
---@return boolean
function Portal:remove_child(uid) for i,existing in ipairs(self.children) do if existing.uid == uid then table.remove(self.children,i)
self:update()
return true end end
return false end
---@param props LuaX.PropsWithChildren<{}>
function Portal:GenericInlet(props) local children=props.children
local uid=use_memo(function () return self:unique() end,{})
use_effect(function () self:add_child(uid,children)
return function () self:remove_child(uid) end end,{children})
return nil end
function Portal:GenericOutlet() local re,set_re=use_state(0)
local rerender=function () set_re(re + 1) end
use_effect(function () self:observe(rerender)
return function () self:unobserve(rerender) end end)
return map(self.children,function (data) return data.child end) end
---@type LuaX.Context<LuaX.Portal>
Portal.Context=Context()
function Portal:GenericProvider(props) local table=use_context(Portal.Context) or {}
local name=self.name
local new_table={[name] = self}
for k,v in pairs(table) do new_table[k]=v end
return create_element(Portal.Context.Provider,{["children"] = props.children,["value"] = new_table}) end
---@param name string?
function Portal.create(name) return Portal(name) end
return Portal