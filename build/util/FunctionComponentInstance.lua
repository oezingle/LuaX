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
local class=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b._dep.lib.30log"
local HookState=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.HookState"
local ipairs_with_nil=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.ipairs_with_nil"
local FunctionComponentInstance=class"FunctionComponentInstance"
function FunctionComponentInstance:init(component) self.handlers={}
self.requests_rerender=false
self.hookstate=HookState()
self.hookstate:add_listener(function () self.requests_rerender=true
for _,handler in ipairs(self.handlers) do handler() end end)
self.component=component end
function FunctionComponentInstance:on_change(cb) table.insert(self.handlers,cb) end
function FunctionComponentInstance:render(props) self.requests_rerender=false
self.hookstate:reset()
_G.LuaX._context=props.__luax_internal.context
_G.LuaX._hookstate=self.hookstate
local component=self.component
local element=component(props)
_G.LuaX._context=nil
_G.LuaX._hookstate=nil
return element end
function FunctionComponentInstance:__gc() local hooks=self.hookstate.values
local length=self.hookstate.index
for _,hook in ipairs_with_nil(hooks,length) do if hook and hook.on_remove then hook.on_remove() end end end
return FunctionComponentInstance