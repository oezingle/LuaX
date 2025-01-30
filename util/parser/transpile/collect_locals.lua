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
---@type LuaX.Parser.V3
local Parser=require"lib_LuaX._dep.lib.lua-parser"
---@generic T
---@param list T[]
---@return table<T, true>
local LuaXParser
local function list_to_map(list) local map={}
for _,item in pairs(list) do map[tostring(item)]=true end
return map end

---@param vars string[]
---@param node Lua-Parser.Node
local function collect_vars(vars,node) for _,expression in ipairs(node) do 
if expression.name then 
table.insert(vars,expression.name.name) end
if expression.vars then for _,var in ipairs(expression.vars) do table.insert(vars,var.name) end end
if expression.exprs then collect_vars(vars,expression.exprs) end end end
---@param text string
---@return table<string, true>
local function collect_locals(text) 


local text=LuaXParser():set_text(text):set_sourceinfo"collect_locals internal parser":set_components({},"local"):transpile()
local node,err=Parser.parse(text)
if  not node then error("Unable to collect locals - are you sure your code is syntactically correct?\n" .. err) end
---@type string[]
local vars={}
collect_vars(vars,node)
return list_to_map(vars) end
return function (parser) LuaXParser=parser
return collect_locals end