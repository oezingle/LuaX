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
local LuaXParser=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.LuaXParser"
local _VERSION="0.3.0"
if table.pack(...)[1] ~= (arg or {})[1] then local export={["Renderer"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.Renderer",["Fragment"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.components.Fragment",["create_element"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.create_element",["clone_element"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.clone_element",["use_state"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.hooks.use_state",["use_effect"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.hooks.use_effect",["use_memo"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.hooks.use_memo",["use_ref"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.hooks.use_ref",["register"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.loader.register",["Parser"] = LuaXParser,["transpile"] = {["from_path"] = function (path) return LuaXParser.from_file_path(path):transpile() end,["from_string"] = function (content,source) return LuaXParser.from_file_content(content,source) end,["inline"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.inline"},["__from_cli"] = require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.cmd",["_VERSION"] = _VERSION}
setmetatable(export,{["__call"] = function (table,tag) return table.transpile.inline(tag) end})
if  not LuaX then LuaX=export end
return export else local cmd=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.cmd.cmd"
cmd() end