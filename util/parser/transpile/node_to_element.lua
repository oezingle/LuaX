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




---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param name string
local transpile_create_element=require"lib_LuaX.util.parser.transpile.create_element"
local function component_name(components,components_mode,name) 


local search_name=name:match"^(.-)[%.%[]" or name
local has_component= not  not (components[search_name] or components[name])
local mode_global=components_mode == "global"
local is_global=has_component == mode_global
if is_global then return string.format("%q",name) else return name end end

---@param node LuaX.Language.Node
---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param create_element string
---@return string
local function transpile_node_to_element(node,components,components_mode,create_element) if node.type == "comment" then return "" end
if node.type == "literal" then return string.format("%q",node.value) end
if node.type == "element" then ---@type table<string, string|table>
local props=node.props or {}
local children=node.children
if children and  # children >= 1 then local str_children={}
for i,kid in ipairs(children) do if type(kid) == "string" then str_children[i]="{" .. kid .. "}" else str_children[i]="{" .. transpile_node_to_element(kid,components,components_mode,create_element) .. "}" end end
props.children=str_children end
local name=node.name
local component=component_name(components,components_mode,name)
return transpile_create_element(create_element,component,props) end
error(string.format("Can't transpile LuaX node of type %s",node.type)) end
return transpile_node_to_element