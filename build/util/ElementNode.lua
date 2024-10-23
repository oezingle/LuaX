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
local ipairs_with_nil=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.ipairs_with_nil"
local get_function_location=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.Renderer.helper.get_function_location"
local ElementNode={["LITERAL_NODE"] = "LUAX_LITERAL_NODE"}
function ElementNode.clean_children(children) if  not children or type(children) == "string" or children.element_node == ElementNode then children={children} end
local children=children
for i,_ in ipairs_with_nil(children) do local child=children[i]
local child_type=type(child)
if  not child then child=nil elseif child_type ~= "table" then if child_type == "function" then warn(string.format("passed a chld function (defined at %s) as a literal. Are you sure you didn't mean to call create_element()?",get_function_location(child))) end
child=ElementNode.create(ElementNode.LITERAL_NODE,{["value"] = tostring(child)}) end
children[i]=child end
return children end
function ElementNode.inherit_props(node,inherit_props) setmetatable(node.props,{["__index"] = inherit_props})
return node end
function ElementNode.create(component,props) props.children=ElementNode.clean_children(props.children)
local node={["type"] = component,["props"] = props,["element_node"] = ElementNode}
return node end
return ElementNode