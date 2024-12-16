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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.")
require(library_root .. "_shim") end
local class=require"lib_LuaX._dep.lib.30log"
local HookState=require"lib_LuaX.util.HookState"
---@alias LuaX.ComponentInstance.ChangeHandler fun(element: LuaX.ElementNode | nil)
---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field handlers LuaX.ComponentInstance.ChangeHandler[]


---@field requests_rerender boolean

---@field render fun(self: self, props: LuaX.Props): (LuaX.ElementNode | nil)
---@field on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)

---@operator call:LuaX.ComponentInstance
---@class LuaX.FunctionComponentInstance : LuaX.ComponentInstance
---@field hookstate LuaX.HookState
---@field handlers LuaX.ComponentInstance.ChangeHandler[]
---@field init fun(self: self, renderer: LuaX.FunctionComponent)


---@field on_change fun(self: self, cb: LuaX.ComponentInstance.ChangeHandler)
---@operator call: LuaX.FunctionComponentInstance
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
local FunctionComponentInstance=class"FunctionComponentInstance"
function FunctionComponentInstance:init(component) self.handlers={}
self.requests_rerender=false
self.props={}
self.hookstate=HookState()
self.hookstate:add_listener(function () self.requests_rerender=true
for _,handler in ipairs(self.handlers) do handler() end end)
self.component=component end
function FunctionComponentInstance:on_change(cb) table.insert(self.handlers,cb) end
function FunctionComponentInstance:render(props) self.requests_rerender=false

self.hookstate:reset()
local last_context=_G.LuaX._context
_G.LuaX._context=props.__luax_internal.context
local last_hookstate=_G.LuaX._hookstate
_G.LuaX._hookstate=self.hookstate
local component=self.component
local element=component(props)
_G.LuaX._context=last_context
_G.LuaX._hookstate=last_hookstate
return element end
function FunctionComponentInstance:cleanup() local hooks=self.hookstate.values
local length=self.hookstate.index
for _,hook in ipairs_with_nil(hooks,length) do 
if hook and type(hook) == "table" and hook.on_remove then hook.on_remove() end end end
function FunctionComponentInstance:__gc() self:cleanup() end
return FunctionComponentInstance