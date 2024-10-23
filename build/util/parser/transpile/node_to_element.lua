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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.parser.transpile.")
require(library_root .. "_shim") end
local transpile_create_element=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.transpile.create_element"
local function component_name(components,components_mode,name) local has_component= not  not components[name]
local mode_global=components_mode == "global"
local is_global=has_component == mode_global
if is_global then return string.format("%q",name) else return name end end
local function transpile_node_to_element(node,components,components_mode,create_element) if node.type == "literal" then return string.format("%q",node.value) end
if node.type == "element" then local props=node.props or {}
local kids=node.children
if kids and  # kids >= 1 then local children={}
for i,kid in ipairs(kids) do if type(kid) == "string" then children[i]="{" .. kid .. "}" else children[i]="{" .. transpile_node_to_element(kid,components,components_mode,create_element) .. "}" end end
props.children=children end
local name=node.name
local component=component_name(components,components_mode,name)
return transpile_create_element(create_element,component,props) end
error(string.format("Can't transpile LuaX node of type %s",node.type)) end
return transpile_node_to_element