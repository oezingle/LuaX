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
local library_root=folder_of_this_file:sub(1, - 1 -  # "cmd.")
require(library_root .. "_shim") end
local argparse=require"lib_LuaX._dep.lib.argparse"
local basename=require"lib_LuaX.util.polyfill.path.basename"
local to_luapath=require"lib_LuaX.cmd.to_luapath"
local transpile=require"lib_LuaX.cmd.transpile"
local function cmd() local parser=argparse"LuaX"
parser:option("-r --recursive","Recursively check, either to any depth (implicit/\"auto\") or a specified number"):args"?"
parser:option("--remap","Match imports for $1, replacing with $2"):args(2):count"*"
parser:flag("-a --auto-remap","Attempt to automatically remap imports given input & output")
parser:argument("input","Input file/folder path")
parser:argument("output","Output file/folder path")
local args=parser:parse()
if args.recursive then if  # args.recursive == 0 or args.recursive[1] == "auto" then args.recursive=true else local depth=tonumber(args.recursive[1])
if  not depth then print(string.format("--recursive: expected number, got %q",args.recursive[1]))
os.exit(1) end
args.recursive=depth end else args.recursive=false end
local remap={}
for _,pair in ipairs(args.remap) do table.insert(remap,{["from"] = pair[1],["to"] = pair[2]}) end
if args.auto_remap then table.insert(remap,{["from"] = to_luapath(basename(args.input)),["to"] = to_luapath(basename(args.output))}) end
local transpile_options={["inpath"] = args.input,["outpath"] = args.output,["recursive"] = args.recursive,["remap"] = remap}
transpile(transpile_options) end
return cmd