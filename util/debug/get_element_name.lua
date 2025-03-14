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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.debug.")
require(library_root .. "_shim") end
local get_component_name=require"lib_LuaX.util.debug.get_component_name"
local ElementNode=require"lib_LuaX.util.ElementNode"
local NativeElement=require"lib_LuaX.util.NativeElement.NativeElement"
local class=require"lib_LuaX._dep.lib.30log"
local function get_element_name(element) if element == nil then return "nil" end
if type(element) == "function" or type(element) == "string" then return get_component_name(element) end
if type(element) ~= "table" then return string.format("UNKNOWN (type %s)",type(element)) end
if ElementNode.is(element) then return get_component_name(element.type) end
if class.isInstance(element) and (element.class == NativeElement or element.class:subclassOf(NativeElement)) then local element=element
return element:get_name() end
if  # element ~= 0 then return string.format("list(%d)", # element) end
if next(element) == nil then return "list(nil)" end
return "UNKNOWN" end
return get_element_name