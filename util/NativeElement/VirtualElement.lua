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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.NativeElement.")
require(library_root .. "_shim") end

local class=require"lib_LuaX._dep.lib.30log"
local FunctionComponentInstance=require"lib_LuaX.util.FunctionComponentInstance"
---@class LuaX.NativeElement.Virtual : Log.BaseFunctions
---@field component LuaX.ComponentInstance
local table_equals=require"lib_LuaX.util.table_equals"
local VirtualElement=class"LuaX.VirtualElement"
function VirtualElement:init(component) if type(component) == "function" then self.instance=FunctionComponentInstance(component)
self.type=component else self.instance=component end end
function VirtualElement:get_type() return self.type end
function VirtualElement:on_change(callback) self.instance:on_change(callback) end
function VirtualElement:insert_child() error"A VirtualElement should never interact with children" end
VirtualElement.delete_child=VirtualElement.insert_child
function VirtualElement.create_element(type) return VirtualElement(type) end
function VirtualElement.get_root() error"VirtualElements exist to host non-native components, and therefore cannot be used as root elements" end
function VirtualElement:set_props(props) if table_equals(props,self.props) then 
return  end

self.props=props end
---@return boolean did_render, LuaX.ElementNode | LuaX.ElementNode[] | nil result
function VirtualElement:render() local element=self.instance:render(self.props)
if  not self.instance.requests_rerender then return true,element end
return false,nil end
function VirtualElement:cleanup() self.instance:cleanup() end
return VirtualElement