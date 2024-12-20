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
---@class LuaX.Context<T> : Log.BaseFunctions, { default: T, Provider: LuaX.Component }
---@field protected default table
---@field Provider LuaX.Component
---@operator call:LuaX.Context
local class=require"lib_LuaX._dep.lib.30log"
---@param default table
local Context=class"Context"
function Context:init(default) 
self.default=default or {}
self.Provider=function (props) return self:GenericProvider(props) end end
function Context:GenericProvider(props) props.__luax_internal.context[self]=props.value or self.default
return props.children end
---@generic T
---@param default T?
---@return LuaX.Context<T>
function Context.create(default) return Context(default) end
---@param caller LuaX.ElementNode?
function Context.inherit(caller) if  not caller then return {} end
---@diagnostic disable-next-line:undefined-field
local inherit=caller.props.__luax_internal.context
return setmetatable({},{["__index"] = inherit}) end
return Context