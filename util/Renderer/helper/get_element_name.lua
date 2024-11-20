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
local get_function_location=require"lib_LuaX.util.Renderer.helper.get_function_location"
local get_function_name=require"lib_LuaX.util.Renderer.helper.get_function_name"
local ElementNode=require"lib_LuaX.util.ElementNode"
local NativeElement=require"lib_LuaX.util.NativeElement.NativeElement"
local class=require"lib_LuaX._dep.lib.30log"

local inline_transpile_decorator=require"lib_LuaX.util.parser.inline.decorator"
---@param component LuaX.Component
local inline_transpiled_location=get_function_location(inline_transpile_decorator(function (props)  end))
local function get_component_name(component) local t=type(component)
if t == "function" then local location=get_function_location(component)
local name=get_function_name(location)
if location == inline_transpiled_location then return "Inline LuaX" elseif name ~= location then return string.format("%s (%s)",name,location) else 
return "Function defined at " .. location end elseif component == ElementNode.LITERAL_NODE then return "Literal node" elseif t == "string" then return component else return string.format("UNKNOWN (%s %s)",t,tostring(component)) end end
---@param element LuaX.ElementNode | LuaX.NativeElement | LuaX.Component | nil
---@return string
local function get_element_name(element) if element == nil then return "nil" end
if type(element) == "function" or type(element) == "string" then return get_component_name(element) end
if type(element) ~= "table" then return string.format("UNKNOWN (type %s)",type(element)) end
if element.element_node == ElementNode then return get_component_name(element.type) end
---@diagnostic disable-next-line:undefined-field
if class.isInstance(element) and (element.class == NativeElement or element.class:subclassOf(NativeElement)) then 
local element=element
if element.get_type then return element:get_type() end
return "UNKNOWN (extends NativeElement)" end
return "UNKNOWN" end
return get_element_name