local _ENV=_ENV or _G
local searchpath=package.searchpath
local vanilla_require=require
local function env_aware_require(modpath) local loaded=_ENV.package.loaded[modpath]
if loaded then return loaded end
local c_path=searchpath(modpath,package.cpath)
if c_path then return vanilla_require(modpath) end
local path,err=searchpath(modpath,package.path)
if  not path then error(err) end
local chunk,err=loadfile(path,nil,_ENV)
if  not chunk then error(err) end
if _VERSION:match"%d.%d" == "5.1" then setfenv(chunk,_ENV) end
local mod=chunk(modpath,path)
package.loaded[modpath]=mod
return mod,path end
local function parser_shim() local package,require=package,require
if  not _IS_BUNDLED then _ENV=setmetatable({["package"] = setmetatable({["loaded"] = {["table"] = table,["string"] = string}},{["__index"] = package}),["require"] = env_aware_require},{["__index"] = _G})
package=_ENV.package
require=_ENV.require end
package.loaded["ext.op"]=require"lib_LuaX._dep.lib.lua-ext.op"
package.loaded["ext.table"]=require"lib_LuaX._dep.lib.lua-ext.table"
package.loaded["ext.class"]=require"lib_LuaX._dep.lib.lua-ext.class"
package.loaded["ext.string"]=require"lib_LuaX._dep.lib.lua-ext.string"
package.loaded["ext.tolua"]=require"lib_LuaX._dep.lib.lua-ext.tolua"
package.loaded["ext.assert"]=require"lib_LuaX._dep.lib.lua-ext.assert"
package.loaded["parser.base.ast"]=require"lib_LuaX._dep.lib.lua-parser.base.ast"
package.loaded["parser.lua.ast"]=require"lib_LuaX._dep.lib.lua-parser.lua.ast"
package.loaded["parser.base.datareader"]=require"lib_LuaX._dep.lib.lua-parser.base.datareader"
package.loaded["parser.base.tokenizer"]=require"lib_LuaX._dep.lib.lua-parser.base.tokenizer"
package.loaded["parser.lua.tokenizer"]=require"lib_LuaX._dep.lib.lua-parser.lua.tokenizer"
package.loaded["parser.base.parser"]=require"lib_LuaX._dep.lib.lua-parser.base.parser"
package.loaded["parser.lua.parser"]=require"lib_LuaX._dep.lib.lua-parser.lua.parser"
return require"lib_LuaX._dep.lib.lua-parser.parser" end
return parser_shim()