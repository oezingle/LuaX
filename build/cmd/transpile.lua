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
local join=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.polyfill.path.join"
local ls=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.fs.list".ls
local mkdir=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.fs.mkdir".mkdir
local is_dir=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.fs.is_dir"
local cp=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.fs.cp"
local is_lua_file=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.fs.is_lua_file"
local parse_file=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.parse_file"
local basename=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.polyfill.path.basename"
local function transpile(options) local inpath=options.inpath
local outpath=options.outpath
local should_recurse=(type(options.recursive) == "boolean" and options.recursive) or (type(options.recursive) == "number" and options.recursive >= 1)
if is_lua_file(inpath) then local parsed=parse_file(inpath)
for _,remap in ipairs(options.remap) do parsed=parsed:gsub("require%(%s*([\"'])" .. remap.from,"require(%1" .. remap.to) end
if outpath:match"luax$" then outpath=outpath:gsub("luax$","lua") end
local outfile=io.open(outpath,"w")
if  not outfile then error(string.format("Unable to transpile %q: cannot open %q",inpath,outpath)) end
outfile:write(parsed)
outfile:flush()
outfile:close() elseif is_dir(inpath) and should_recurse then local outdir=basename(outpath)
mkdir(outdir)
for _,file in ipairs(ls(inpath)) do local new_inpath=join(inpath,file)
local new_outpath=join(outpath,file)
local new_options={["inpath"] = new_inpath,["outpath"] = new_outpath,["recursive"] = type(options.recursive) == "number" and options.recursive - 1 or options.recursive,["remap"] = options.remap}
transpile(new_options) end else cp(inpath,outpath) end end
return transpile