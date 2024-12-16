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
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
---@param children LuaX.ElementNode[] | LuaX.ElementNode | nil
local Children={}
function Children.count(children) if  not children then return 0 elseif children.type then return 1 else local count=0
for _,child in ipairs_with_nil(children) do count=count + Children.count(child) end end end
---@generic T
---@param children LuaX.ElementNode[] | LuaX.ElementNode | nil
---@param cb fun(child: LuaX.ElementNode, index: number): T
---@return T[]
function Children.map(children,cb) if  not children or children.type then children={children} end
local mapped={}
for i,child in ipairs_with_nil(children) do mapped[i]=cb(child,i) end
return mapped end
return Children