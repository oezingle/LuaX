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
local class=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b._dep.lib.30log"
local is_cancelled=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.parse.is_cancelled"
local function get_tokens() local tokens={"{","}","[","]","(",")","'","\""}
local out={}
for _,token in ipairs(tokens) do out[token]=true end
return out end
local TokenStack=class"TokenStack"
function TokenStack:init(text) self:set_pos(1)
self.stack=""
self.text=text
self.tokens=get_tokens()
self:set_requires_literal(false) end
function TokenStack:set_requires_literal(requires_literal) self.requires_literal=requires_literal
return self end
function TokenStack:set_pos(pos) self.pos=pos
return self end
function TokenStack:get_pos() return self.pos end
function TokenStack:is_cancelled() return is_cancelled(self.text,self.pos) end
function TokenStack:is_token() if self:is_cancelled() then return false end
local char=self.text:sub(self.pos,self.pos)
return self.tokens[char] or false end
function TokenStack.get_opposite(char) return ({["<"] = ">",[">"] = "<",["{"] = "}",["}"] = "{",["["] = "]",["]"] = "[",["("] = ")",[")"] = "(",["\""] = "\"",["'"] = "'"})[char] end
function TokenStack:is_empty() return  # self.stack == 0 end
function TokenStack:run_once() local char=self.text:sub(self.pos,self.pos)
if self:is_token() then local last_token=self.stack:sub( - 1)
if self.get_opposite(char) == last_token then self.stack=self.stack:sub(1, - 2) else if  not self.stack:match"[\"']$" and  not self.stack:match"%[%[$" then if  not self.requires_literal or self.stack:match"^{" or char == "{" then self.stack=self.stack .. char end end end end
self:safety_check()
self.pos=self.pos + 1
return self end
function TokenStack:get_current() return self.text:sub(self.pos,self.pos) end
function TokenStack:safety_check() if self.pos >  # self.text + 1 then error"TokenStack out of text bounds" end end
function TokenStack:run_until_empty() while  not self:is_empty() do self:run_once()
self:safety_check() end
return self end
return TokenStack