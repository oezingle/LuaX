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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.parser.")
require(library_root .. "_shim") end
---@nospec too simple to need a test. just a list
local keywords=require"lib_LuaX.util.parser.keywords"
---@class LuaX.Parser.V2.Token
---@field pattern string
---@field replacer string
---@field end_pattern string
---@field end_replacer string
---@param token any
---@return LuaX.Parser.V2.Token
local escape=require"lib_LuaX.util.polyfill.string.escape"
local function ensure_token(token) token.replacer=token.replacer or ""
token.end_pattern=token.end_pattern or ""
token.end_replacer=token.end_replacer or ""
return token end

local function bake_tokens() ---@type any[]

local tokens={{["pattern"] = "return%s*%[%[(%s*)<",["replacer"] = "return ",["end_pattern"] = "%s*%]%]",["end_replacer"] = ""},{["pattern"] = "LuaX%s*%(%[%[(%s*)<",["replacer"] = "",["end_pattern"] = "%s*%]%]%s*%)",["end_replacer"] = ""}}
for _,keyword in ipairs(keywords) do table.insert(tokens,{["pattern"] = keyword .. "%s*<",["replacer"] = keyword .. " "}) end

for token,match in pairs{["{"] = "}",["["] = "]",["("] = ")",[","] = "",["="] = ""} do 
table.insert(tokens,{["pattern"] = escape(token) .. "%s*<",["replacer"] = token,["end_pattern"] = match and ("%s*" .. escape(match)),["end_replacer"] = match}) end
---@type LuaX.Parser.V2.Token[]
local ret={}
for _,token in ipairs(tokens) do table.insert(ret,ensure_token(token)) end
return ret end
return bake_tokens()