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
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
local traceback=require"lib_LuaX.util.debug.traceback"
local DrawGroup=require"lib_LuaX.util.Renderer.DrawGroup"
local get_component_name=require"lib_LuaX.util.debug.get_component_name"
local this_file=(...)
local FunctionComponentInstance=class"FunctionComponentInstance"
local ABORT_CURRENT_RENDER={}
function FunctionComponentInstance:init(component) self.friendly_name=get_component_name(component)
self.hookstate=HookState()
self.hookstate:set_listener(function () self.rerender=true
self.change_handler()
if HookState.global.get() == self.hookstate then error(ABORT_CURRENT_RENDER) end end)
self.component=component end
function FunctionComponentInstance:set_on_change(cb) self.change_handler=cb end
function FunctionComponentInstance:render(props) local component=self.component
self.rerender=false
self.hookstate:reset()
local last_hookstate=HookState.global.set(self.hookstate)
local ok,res=xpcall(component,traceback,props)
HookState.global.set(last_hookstate)
if  not ok then local err=res
if err == ABORT_CURRENT_RENDER then return false,nil end
local err_trunc=err:match("(.*)[\n\13].-[\n\13].-[\n\13].-in function '" .. this_file .. ".-'")
if err_trunc then err_trunc=err_trunc:gsub("in upvalue 'chunk'",string.format("in function '%s'",self.friendly_name:match"^%S+"))
err_trunc="While rendering " .. self.friendly_name .. ":\n" .. err_trunc end
DrawGroup.error(nil,err_trunc or err) else local element=res
return  not self.rerender,element end end
function FunctionComponentInstance:cleanup() local hooks=self.hookstate.values
local length=math.max( # self.hookstate.values,self.hookstate.index)
for _,hook in ipairs_with_nil(hooks,length) do if type(hook) == "table" and hook.on_remove then hook.on_remove() end end end
return FunctionComponentInstance