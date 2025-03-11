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
local HookState=class"HookState"
local no_op=function ()  end
function HookState:init() self.values={}
self.listener=no_op
self.index=1 end
function HookState:reset() self.index=1 end
function HookState:get_index() return self.index end
function HookState:set_index(index) self.index=index end
function HookState:increment() self:set_index(self:get_index() + 1) end
function HookState:get_value(index) return self.values[index or self.index] end
function HookState:set_value(index,value) self:set_value_silent(index,value)
self:modified(index,value) end
function HookState:set_value_silent(index,value) self.values[index]=value end
function HookState:modified(index,value) self.listener(index,value) end
function HookState:set_listener(listener) self.listener=listener end
local hs_global={["current"] = nil}
HookState.global={}
function HookState.global.get(required) local hookstate=hs_global.current
if required then assert(hookstate,"No global hookstate!") end
return hookstate end
function HookState.global.set(hookstate) local last_hookstate=hs_global.current
hs_global.current=hookstate
return last_hookstate end
return HookState