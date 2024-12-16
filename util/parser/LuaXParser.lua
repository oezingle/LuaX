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
local class=require"lib_LuaX._dep.lib.30log"
local tokens=require"lib_LuaX.util.parser.tokens"
local get_default_indent=require"lib_LuaX.util.parser.parse.get_default_indent"
local node_to_element=require"lib_LuaX.util.parser.transpile.node_to_element"
local collect_global_components=require"lib_LuaX.util.parser.transpile.collect_global_components"
local TokenStack=require"lib_LuaX.util.parser.TokenStack"
local escape=require"lib_LuaX.util.polyfill.string.escape"

local get_indent=require"lib_LuaX.util.parser.parse.get_indent"
local require_path
do if table.pack(...)[1] == (arg or {})[1] then print"LuaXParser must be imported"
os.exit(1) end
require_path=(...) end
---@class LuaX.Language.Node.Literal
---@field type "literal"
---@field value string
---@class LuaX.Language.Node.Element
---@field type "element"
---@field name string
---@field props LuaX.Props
---@field children LuaX.Language.Node[]
---@alias LuaX.Language.Node LuaX.Language.Node.Literal | LuaX.Language.Node.Element
---@class LuaX.Parser.V3 : Log.BaseFunctions
---@field protected text string
---@field protected char integer

---@field protected indent string
---@field protected default_indent string


---@field components { names: table<string, true>, mode: "global"|"local" } a table of component names

---@operator call:LuaX.Parser.V3
local LuaXParser=class"LuaXParser (V3)"
---@param export_name string
---@return string
local collect_locals=require"lib_LuaX.util.parser.transpile.collect_locals"(LuaXParser)
local function luax_export(export_name) 
local luax_root=require_path:gsub("%.util%.parser%.LuaXParser$","")
return string.format("require(%q)[%q]",luax_root,export_name) end
---@protected
LuaXParser.vars={["FRAGMENT"] = {["name"] = "_LuaX_Fragment",["value"] = luax_export"Fragment",["required"] = false},["IS_COMPILED"] = {["name"] = "_LuaX_is_compiled",["value"] = "true",["required"] = true},["CREATE_ELEMENT"] = {["name"] = "_LuaX_create_element",["value"] = luax_export"create_element",["required"] = true}}
function LuaXParser:init(text) if text then self:set_text(text) end
self:set_sourceinfo()
self:set_cursor(1)
self:set_components({},"local") end
---@param text string
---@return self
function LuaXParser:set_text(text) if self == LuaXParser then error"LuaXParser must be instanciated" end
self.text=text
return self end
---@param source string?
---@return self
function LuaXParser:set_sourceinfo(source) self.src=source or "Unknown"
return self end

do ---@param components string[]|table<string, true>
---@param mode "global" | "local"
---@return self
function LuaXParser:set_components(components,mode) if  # components > 0 then local components_new={}
for _,component in ipairs(components) do components_new[component]=true end
components=components_new end
if mode == "local" then components[self.vars.FRAGMENT.name]=true end
self.components={["names"] = components,["mode"] = mode}
return self end
function LuaXParser:auto_set_components() assert(self.text,"Parser text must be set before components names are queried")
local globals=collect_global_components()
if globals then return self:set_components(globals,"global") end
local locals=collect_locals(self.text)
locals[self.vars.FRAGMENT.name]=true
return self:set_components(locals,"local") end end



---@protected
---@param msg string
---@return string
function LuaXParser:error(msg) local fmt="LuaX Parser - In %s at %d:%d: %s"
local chars_away=self:get_cursor()
local n_line=0
local n_col=0
for line in self.text:gmatch".-[\n\13]" do local sub=chars_away -  # line
if sub < 0 then n_col=chars_away
break end
n_line=n_line + 1 end

return string.format(fmt,self.src,n_line,n_col,tostring(msg)) end


---@protected
---@return LuaX.Parser.V2.Token token, string? captured, integer range_start, integer range_end
---@overload fun(self: self): nil
function LuaXParser:get_next_token() local matches={}
for _,token in ipairs(tokens) do local range_start,range_end,captured=self:text_find(token.pattern)
if range_start and range_end then 
table.insert(matches,{["token"] = token,["captured"] = captured,["range_start"] = range_start,["range_end"] = range_end}) end end

table.sort(matches,function (match_a,match_b) return match_a.range_end < match_b.range_end end)
local match=matches[1]
if match then return match.token,match.captured,match.range_start,match.range_end end
return nil end

do ---@protected
function LuaXParser:move_to_next_token() local _,_,token_pos=self:get_next_token()
if  not token_pos then error(self:error"Unable to determine next token") end
self:set_cursor(token_pos) end
---@param pattern string
---@return string|boolean
function LuaXParser:move_to_pattern_end(pattern) 
local find=table.pack(self:text_find(pattern))

table.remove(find,1)
local pattern_end=table.remove(find,1)
if  not pattern_end then return false end
self:set_cursor(pattern_end + 1)

local first_capture=table.remove(find,1)
return first_capture or true,table.unpack(find) end
---@param char number
---@return self
function LuaXParser:set_cursor(char) self.char=char
return self end
---@return number
function LuaXParser:get_cursor() return self.char end

---@param chars number
function LuaXParser:move_cursor(chars) self:set_cursor(self:get_cursor() + chars) end end

function LuaXParser:is_at_end() return self:get_cursor() ==  # self.text end

do 
---@protected
---@param pattern string
function LuaXParser:text_find(pattern) return self.text:find(pattern,self:get_cursor()) end

---@protected
---@param pattern string
function LuaXParser:text_match(pattern) return self.text:match(pattern,self:get_cursor()) end


---@protected
---@param range_start integer
---@param range_end integer
---@param replacer string
function LuaXParser:text_replace_range(range_start,range_end,replacer) self.text=self.text:sub(1,range_start - 1) .. replacer .. self.text:sub(range_end + 1) end

---@protected
---@param range_end integer
---@param replacer string
function LuaXParser:text_replace_range_c(range_end,replacer) self:text_replace_range(self:get_cursor(),range_end,replacer) end

---@protected
---@param range_start integer
---@param range_end integer
---@param replacer string
function LuaXParser:text_replace_range_move(range_start,range_end,replacer) self:text_replace_range(range_start,range_end,replacer)
self:set_cursor(range_start +  # replacer) end

---@protected
---@param range_end integer
---@param replacer string
function LuaXParser:text_replace_range_move_c(range_end,replacer) self:text_replace_range_move(self:get_cursor(),range_end,replacer) end end


do 
---@param on_set_variable fun(name: string, value: string, parser: LuaX.Parser.V3)
---@return self
function LuaXParser:set_handle_variables(on_set_variable) self.on_set_variable=on_set_variable
self:set_required_variables()
return self end

---@protected
function LuaXParser:set_required_variables() for _,var in pairs(self.vars) do if var.required then self:set_variable(var.name,var.value) end end end
---@protected
---@param name string
---@param value string
function LuaXParser:set_variable(name,value) if self.on_set_variable then self.on_set_variable(name,value,self) else warn(string.format("LuaXParser: Variable %s not set: no on_set_variable",name)) end end
function LuaXParser:handle_variables_prepend_text() local already_set={}
return self:set_handle_variables(function (name,value,parser) local fmt="local %s = %s\n"
local insert=string.format(fmt,name,value)
if already_set[name] then if already_set[name] == value then return  else error"Attempt to set variable that is already set" end end
---@diagnostic disable-next-line:invisible
already_set[name]=value
parser.text=insert .. parser.text
parser:move_cursor( # insert) end) end
---@param variables table
function LuaXParser:handle_variables_as_table(variables) return self:set_handle_variables(function (name,value) local parse_value,err=load("return " .. value,"LuaX variable value")
if  not parse_value then error(err) end
variables[name]=parse_value() end) end end

function LuaXParser:get_default_indent() local slice=self.text:sub(1,self:get_cursor())
return slice:match"[\n\13](%s*).-$" or "" end
function LuaXParser:get_indent() local indent=self:text_match">[\n\13](%s*)%S" or ""
return indent:gsub("^" .. self.default_indent,"") end

do 
---@protected
---@param depth integer
---@return LuaX.Language.Node[]
function LuaXParser:parse_literal(depth) ---@type { is_luablock: boolean, chars: string[], start: integer }[]
local tokenstack=TokenStack(self.text):set_pos(self:get_cursor()):set_requires_literal(true)

local slices={}
while true do local pos=tokenstack:get_pos()
tokenstack:run_once()

tokenstack:run_until_empty()
if tokenstack:get_pos() > pos + 1 then table.insert(slices,{["is_luablock"] = true,["chars"] = {self.text:sub(pos + 1,tokenstack:get_pos() - 2)},["start"] = pos + 1}) else local current=self.text:sub(pos,pos)
if current == "<" then break elseif current == "{" then  else 
local last_slice=slices[ # slices]
if  not last_slice or last_slice.is_luablock == true then table.insert(slices,{["is_luablock"] = false,["chars"] = {},["start"] = pos})
last_slice=slices[ # slices] end
table.insert(last_slice.chars,current) end end end
self:set_cursor(tokenstack:get_pos() - 1)
local indent_pattern=self.default_indent .. self.indent:rep(depth)
local nodes={}
for i,slice in ipairs(slices) do 
local value=table.concat(slice.chars,""):gsub("\n" .. indent_pattern,"\n"):gsub("^" .. indent_pattern,"")
if i == 1 then value=value:gsub("^%s-[\n\13]","") end
if i ==  # slices then value=value:gsub("[\n\13]%s-$","") end

if  not value:match"^%s*$" then if slice.is_luablock then 
value=LuaXParser():set_text(value):set_sourceinfo(self.src .. " subparser"):set_components(self.components.names,self.components.mode):transpile() else value=value.format("%q",value) end
table.insert(nodes,value) end end


return nodes end

---@protected
---@param depth integer
---@return LuaX.Language.Node[]
function LuaXParser:parse_text(depth) 

local nodes={}
while  not (self:text_match"^%s*</" or self:is_at_end()) do if self:text_match"^%s*<" then local node=self:parse_tag(depth)
table.insert(nodes,node) else local new_nodes=self:parse_literal(depth)
for _,node in ipairs(new_nodes) do table.insert(nodes,node) end end end
return nodes end

---@protected
function LuaXParser:parse_props() local props={}
while  not self:text_match"^%s*>" and  not self:text_match"^%s*/%s*>" do 
self:move_to_pattern_end"^%s*%-%-%[%[.-%]%]"

self:move_to_pattern_end"^%s*%-%-.-[\n\13]"


self:move_to_pattern_end"^%s*"

local prop=self:text_match"^[^/>%s]+"
if prop then if prop:match"^.-=" then local prop_name=self:move_to_pattern_end"^(.-)%s*=%s*"
assert(prop_name,self:error"Prop pattern unable to match")

local tokenstack=TokenStack(self.text):set_pos(self:get_cursor()):run_once():run_until_empty()

local prop_value=self.text:sub(self:get_cursor(),tokenstack:get_pos() - 1):gsub("^[\"'](.*)[\"']$","%1")
self:set_cursor(tokenstack:get_pos())
props[prop_name]=prop_value else 
props[prop]=true
self:move_cursor( # prop) end end end
return props end

---@protected
---@param depth integer
---@return LuaX.Language.Node
function LuaXParser:parse_tag(depth) self.default_indent=self:get_default_indent()
self.indent=self:get_indent()
self:move_to_pattern_end"^%s*"
local tag_name
local is_fragment=self:move_to_pattern_end"^<%s*>"
if is_fragment then tag_name=self.vars.FRAGMENT.name
self.vars.FRAGMENT.required=true else tag_name=self:move_to_pattern_end"^<%s*([^%s/>]+)"
assert(tag_name,self:error"Cannot find tag name")
assert(type(tag_name) == "string","Tag pattern does not capture") end
local props=is_fragment and {} or self:parse_props()
local no_children=self:move_to_pattern_end"^%s*/%s*>"
if  not (is_fragment or no_children) then assert(self:move_to_pattern_end"^%s*>",self:error"Cannot find end of props") end
local children=no_children and {} or self:parse_text(depth + 1)
if is_fragment then assert(self:move_to_pattern_end"^%s*<%s*/%s*>",self:error"Cannot find fragment end") else local patt="^%s*<%s*/%s*" .. escape(tag_name) .. "%s*>"
assert(no_children or self:move_to_pattern_end(patt),self:error"Cannot find ending tag") end
return {["type"] = "element",["name"] = tag_name,["props"] = props,["children"] = children} end end


function LuaXParser:transpile_tag() 
local cursor_start=self:get_cursor()
local node=self:parse_tag(0)

local transpiled=node_to_element(node,self.components.names,self.components.mode,self.vars.CREATE_ELEMENT.name)
self:text_replace_range_move(cursor_start,self:get_cursor(),transpiled)
self:set_required_variables()
return self.text end

---@protected
---@return boolean continue
function LuaXParser:transpile_once() local token,captured,_,luax_start=self:get_next_token()
if  not token or  not luax_start then return false end

captured=captured or ""

self:move_to_next_token()
self:text_replace_range_move_c(luax_start - 1,token.replacer .. captured)
self:transpile_tag()
local _,luax_end=self:text_find(token.end_pattern)
if  not luax_end then error(self:error"Unable to locate end of block") end
self:text_replace_range_move_c(luax_end,token.end_replacer)
return true end

function LuaXParser:transpile() if  not self.components then warn"Automatically setting parser components"
self:auto_set_components() end
while self:transpile_once() do  end
return self.text end
---@param str string
---@param src string?
---@param variables table?
function LuaXParser.from_inline_string(str,src,variables) variables=variables or {}
return LuaXParser():set_text(str):set_sourceinfo(src or "Unknown inline string"):handle_variables_as_table(variables):auto_set_components() end
---@param str string
---@param src string?
function LuaXParser.from_file_content(str,src) return LuaXParser():set_text(str):set_sourceinfo(src or "Unknown file string"):handle_variables_prepend_text():auto_set_components() end

---@param path string
function LuaXParser.from_file_path(path) local f=io.open(path)
if  not f then error(string.format("Unable to open file %q",path)) end
local content=f:read"a"
return LuaXParser.from_file_content(content,path) end
return LuaXParser