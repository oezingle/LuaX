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
local ipairs_with_nil=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.ipairs_with_nil"
local HookState=class"HookState"
function HookState:init() self.values={}
self.listeners={}
self.index=1 end
function HookState:reset() self.index=1 end
function HookState:get_index() return self.index end
function HookState:set_index(index) self.index=index end
function HookState:get_value(index) return self.values[index or self.index] end
function HookState:set_value(index,value) self:set_value_silent(index,value)
self:modified(index,value) end
function HookState:set_value_silent(index,value) self.values[index]=value end
function HookState:modified(index,value) for _,listener in pairs(self.listeners) do listener(index,value) end end
function HookState:add_listener(listener) table.insert(self.listeners,listener) end
function HookState:__tostring() local hooks={}
for _,hook in ipairs_with_nil(self.values,self.index) do local hook_str=nil
if type(hook) == "table" then local hook_values={}
for key,hook_value in ipairs(hook) do local fmt=string.format("%s=%s",key,tostring(hook_value))
table.insert(hook_values,fmt) end
hook_str="{ " .. table.concat(hook_values,", ") .. " }" else hook_str=tostring(hook) end
table.insert(hooks,"\9" .. tostring(hook_str)) end
return string.format("HookState {\n%s\n}",table.concat(hooks,"\n")) end
return HookState