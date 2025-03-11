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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.Renderer.helper.")
require(library_root .. "_shim") end
local ElementNode=require"lib_LuaX.util.ElementNode"
local function create_native_element(element,container) local NativeElementImplementation=container:get_class()
local element_type=element.type
if type(element_type) ~= "string" then error"NativeElement cannot render non-pure component" end
if ElementNode.is_literal(element) and NativeElementImplementation.create_literal then local value=element.props.value
return NativeElementImplementation.create_literal(value,container) else local elem=NativeElementImplementation.create_element(element_type)
elem:set_render_name(element_type)
local onload=element.props["LuaX::onload"]
if onload then assert(type(onload) == "function","LuaX::onload value must be a function")
onload(elem:get_native(),elem) end
return elem end end
return create_native_element