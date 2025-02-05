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
local Context=class"Context"
function Context:init(default) self.default=default
self.Provider=function (props) return self:GenericProvider(props) end end
function Context:GenericProvider(props) props.__luax_internal.context[self]=props.value
return props.children end
function Context.create(default) return Context(default) end
function Context.inherit(caller) if  not caller then return {} end
local inherit=caller.props.__luax_internal.context
local new={}
for k,v in pairs(inherit) do new[k]=v end
return new end
return Context