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
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
---@alias LuaX.HookState.Listener fun(index: number, value: any)
---@class LuaX.HookState : Log.BaseFunctions
---@field index number
---@field values any[]
---@field listeners LuaX.HookState.Listener
---@operator call:LuaX.HookState
local stringify_table=require"lib_LuaX.util.parser.transpile.stringify_table"
local HookState=class"HookState"
local no_op=function ()  end
function HookState:init() self.values={}
self.listener=no_op
self.index=1 end
function HookState:reset() self.index=1 end
function HookState:get_index() return self.index end
---@param index number
function HookState:set_index(index) self.index=index end
function HookState:increment() self:set_index(self:get_index() + 1) end
---@param index number?
function HookState:get_value(index) return self.values[index or self.index] end
---@param index number
---@param value any
function HookState:set_value(index,value) self:set_value_silent(index,value)
self:modified(index,value) end
---@param index number
---@param value any
function HookState:set_value_silent(index,value) self.values[index]=value end
---@param index number
---@param value any
function HookState:modified(index,value) self.listener(index,value) end
---@param listener LuaX.HookState.Listener
function HookState:set_listener(listener) self.listener=listener end
function HookState:__tostring() local hooks={}
local size=math.max(self.index, # self.values)
for _,hook in ipairs_with_nil(self.values,size) do local hook_str=nil
if type(hook) == "table" then hook_str=stringify_table(hook) else hook_str=tostring(hook) end
table.insert(hooks,"\9" .. tostring(hook_str)) end
return string.format("HookState {\n%s\n}",table.concat(hooks,"\n")) end
---@overload fun(value: nil): LuaX.HookState
---@overload fun(value: LuaX.HookState): nil
function HookState.global(value) if value then _G.LuaX._hookstate=value else 
local hookstate=_G.LuaX._hookstate
assert(hookstate,"No global hookstate!")
return hookstate end end
return HookState