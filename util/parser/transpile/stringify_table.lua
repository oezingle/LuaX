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


---@param input any
---@return string
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"






---@param input table
---@return string
local stringify=function (input) error"should have been replaced!" end
local function stringify_table(input) 
local elements={}
for k,v in pairs(input) do if type(k) ~= "number" then local key=stringify(k)
local value=stringify(v)
local format=string.format("[%s]=%s",key,value)
table.insert(elements,format) end end
for _,v in ipairs_with_nil(input) do local value=stringify(v)
table.insert(elements,value) end
return string.format("{ %s }",table.concat(elements,", ")) end
stringify=function (input) local t=type(input)
if t == "nil" or t == "number" or t == "boolean" then return tostring(input) end
if t == "string" then if input:match"^{.*}$" then 
return input:sub(2, - 2) else return string.format("%q",input) end end
if t == "table" then return stringify_table(input) end

if t == "function" then 

local dump=string.dump(input)
return string.format("load(%q)",dump) end
error(string.format("Cannot stringify %s",t)) end
return stringify_table