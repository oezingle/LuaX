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
local node_to_element=require"lib_LuaX.util.parser.transpile.node_to_element"
local collect_global_components=require"lib_LuaX.util.parser.transpile.collect_global_components"
local TokenStack=require"lib_LuaX.util.parser.parse.TokenStack"
local escape=require"lib_LuaX.util.polyfill.string.escape"
local require_path
do if table.pack(...)[1] == (arg or {})[1] then print"LuaXParser must be imported"
os.exit(1) end
require_path=(...) end
local LuaXParser=class"LuaXParser (V3)"
local collect_locals=require"lib_LuaX.util.parser.transpile.collect_locals"(LuaXParser)
local function luax_export(export_name) local luax_root=require_path:gsub("%.util%.parser%.LuaXParser$","")
return string.format("require(%q)[%q]",luax_root,export_name) end
LuaXParser.vars={["FRAGMENT"] = {["name"] = "_LuaX_Fragment",["value"] = luax_export"Fragment",["required"] = false},["IS_COMPILED"] = {["name"] = "_LuaX_is_compiled",["value"] = "true",["required"] = false},["CREATE_ELEMENT"] = {["name"] = "_LuaX_create_element",["value"] = luax_export"create_element",["required"] = false}}
function LuaXParser:init(text) if text then self:set_text(text) end
self:set_sourceinfo()
self:set_cursor(1)
self:set_components({},"local") end
function LuaXParser:set_text(text) if self == LuaXParser then error"LuaXParser must be instanciated" end
self.text=text
return self end
function LuaXParser:set_sourceinfo(source) self.src=source or "Unknown"
return self end
do function LuaXParser:set_components(components,mode) if  # components > 0 then local components_new={}
for _,component in ipairs(components) do components_new[component]=true end
components=components_new end
if mode == "local" then components[self.vars.FRAGMENT.name]=true end
self.components={["names"] = components,["mode"] = mode}
return self end
function LuaXParser:auto_set_components() assert(self.text,"Parser input text must be set before components names are queried")
local globals=collect_global_components()
if globals then return self:set_components(globals,"global") end
local locals=collect_locals(self.text)
locals[self.vars.FRAGMENT.name]=true
return self:set_components(locals,"local") end end
function LuaXParser:error(msg) local fmt="LuaX Parser - In %s at %d:%d: %s\n\n%s"
local pos=self:get_cursor()
local context_line=self.text:sub(pos - 20,pos) .. "(HERE)" .. self.text:sub(pos,pos + 20)
local chars_away=self:get_cursor()
local n_line=0
local n_col=0
for line in self.text:gmatch".-[\n\13]" do local sub=chars_away -  # line
if sub < 0 then n_col=chars_away
break end
n_line=n_line + 1 end
return string.format(fmt,self.src,n_line,n_col,tostring(msg),context_line) end
function LuaXParser:get_next_token() local matches={}
for _,token in ipairs(tokens) do local range_start,range_end,captured=self:text_find(token.pattern)
if range_start and range_end then table.insert(matches,{["token"] = token,["captured"] = captured,["range_start"] = range_start,["range_end"] = range_end}) end end
table.sort(matches,function (match_a,match_b) return match_a.range_end < match_b.range_end end)
local match=matches[1]
if match then return match.token,match.captured,match.range_start,match.range_end end
return nil end
function LuaXParser:get_indent() local default_slice=self.text:sub(1,self:get_cursor())
local default_indent=default_slice:match"[\n\13](%s*).-$" or ""
local indent=self:text_match">[\n\13](%s*)%S" or ""
return indent:gsub("^" .. default_indent,"") end
do function LuaXParser:move_to_next_token() local _,_,token_pos=self:get_next_token()
if  not token_pos then error(self:error"Unable to determine next token") end
self:set_cursor(token_pos) end
function LuaXParser:move_to_pattern_end(pattern) local find=table.pack(self:text_find(pattern))
table.remove(find,1)
local pattern_end=table.remove(find,1)
if  not pattern_end then return false end
self:set_cursor(pattern_end + 1)
local first_capture=table.remove(find,1)
return first_capture or true,table.unpack(find) end
function LuaXParser:set_cursor(char) self.char=char
return self end
function LuaXParser:get_cursor() return self.char end
function LuaXParser:move_cursor(chars) self:set_cursor(self:get_cursor() + chars) end
function LuaXParser:is_at_end() return self:get_cursor() ==  # self.text end
function LuaXParser:get_text() return self.text end
function LuaXParser:has_transpiled() return self.vars.IS_COMPILED.required end end
do function LuaXParser:text_find(pattern) return self.text:find(pattern,self:get_cursor()) end
function LuaXParser:text_match(pattern) return self.text:match(pattern,self:get_cursor()) end
function LuaXParser:text_replace_range(range_start,range_end,replacer) self.text=self.text:sub(1,range_start - 1) .. replacer .. self.text:sub(range_end + 1) end
function LuaXParser:text_replace_range_c(range_end,replacer) self:text_replace_range(self:get_cursor(),range_end,replacer) end
function LuaXParser:text_replace_range_move(range_start,range_end,replacer) self:text_replace_range(range_start,range_end,replacer)
self:set_cursor(range_start +  # replacer) end
function LuaXParser:text_replace_range_move_c(range_end,replacer) self:text_replace_range_move(self:get_cursor(),range_end,replacer) end end
do function LuaXParser:set_handle_variables(on_set_variable) self.on_set_variable=on_set_variable
self:set_required_variables()
return self end
function LuaXParser:set_required_variables() for _,var in pairs(self.vars) do if var.required then self:set_variable(var.name,var.value) end end end
function LuaXParser:set_variable(name,value) if self.on_set_variable then self.on_set_variable(name,value,self) else local src
if debug and debug.getinfo then local i=0
repeat i=i + 1
local info=debug.getinfo(i,"Sl")
src=string.format("%s:%d",info.short_src,info.currentline) until  not src:match"LuaXParser%.lua" end
warn((src and string.format("In %s: ",src) or "") .. string.format("LuaXParser: Variable %s not set: no on_set_variable",name)) end end
function LuaXParser:handle_variables_prepend_text() local already_set={}
return self:set_handle_variables(function (name,value,parser) local fmt="local %s = %s\n"
local insert=string.format(fmt,name,value)
if already_set[name] then if already_set[name] == value then return  else error"Attempt to modify variable that is already set" end end
already_set[name]=value
parser.text=insert .. parser.text
if self.current_block_start then self.current_block_start=self.current_block_start +  # insert end
parser:move_cursor( # insert) end) end
function LuaXParser:handle_variables_as_table(variables) return self:set_handle_variables(function (name,value) local parse_value,err=load("return " .. value,"LuaX variable value")
if  not parse_value then error(err) end
variables[name]=parse_value() end) end end
do function LuaXParser:parse_literal() local tokenstack=TokenStack(self.text):set_pos(self:get_cursor()):set_requires_literal(true)
local slices={}
while true do local pos=tokenstack:get_pos()
tokenstack:run_once()
tokenstack:run_until_empty()
if tokenstack:get_pos() > pos + 1 then table.insert(slices,{["is_luablock"] = true,["chars"] = {self.text:sub(pos + 1,tokenstack:get_pos() - 2)},["start"] = pos + 1}) else local current=self.text:sub(pos,pos)
if current == "<" then break elseif current == "-" and self.text:sub(pos):match"%-%-+>" then break elseif current == "{" then  else local last_slice=slices[ # slices]
if  not last_slice or last_slice.is_luablock == true then table.insert(slices,{["is_luablock"] = false,["chars"] = {},["start"] = pos})
last_slice=slices[ # slices] end
table.insert(last_slice.chars,current) end end end
self:set_cursor(tokenstack:get_pos() - 1)
local nodes={}
for i,slice in ipairs(slices) do local value=table.concat(slice.chars,""):gsub("\n" .. self.indent,"\n"):gsub("^" .. self.indent,"")
if i == 1 then value=value:gsub("^%s-[\n\13]","") end
if i ==  # slices then value=value:gsub("[\n\13]%s-$","") end
if  not value:match"^%s*$" then if slice.is_luablock then local on_set_variable=self.on_set_variable and function (name,value) return self.on_set_variable(name,value,self) end
value=LuaXParser():set_text(value):set_sourceinfo(self.src .. " subparser"):set_handle_variables(on_set_variable):set_components(self.components.names,self.components.mode):transpile() elseif value:match"^%s*%-%-" then value={["type"] = "comment",["value"] = value} else value=value.format("%q",value) end
table.insert(nodes,value) end end
return nodes end
function LuaXParser:parse_text() local nodes={}
while  not (self:text_match"^%s*</" or self:text_match"^%s*%-%-+>" or self:is_at_end()) do if self:text_match"^%s*<" then local node=self:parse_tag()
table.insert(nodes,node) else local new_nodes=self:parse_literal()
for _,node in ipairs(new_nodes) do table.insert(nodes,node) end end end
return nodes end
function LuaXParser:parse_props() local props={}
while  not self:text_match"^%s*>" and  not self:text_match"^%s*/%s*>" do self:move_to_pattern_end"^%s*%-%-%[%[.-%]%]"
self:move_to_pattern_end"^%s*%-%-.-[\n\13]"
self:move_to_pattern_end"^%s*"
local prop=self:text_match"^[^/>%s]+"
if prop then if prop:match"^.-=" then local prop_name=self:move_to_pattern_end"^(.-)%s*=%s*"
assert(prop_name,self:error"Prop pattern unable to match")
local tokenstack=TokenStack(self.text):set_pos(self:get_cursor()):run_once():run_until_empty()
local prop_value=self.text:sub(self:get_cursor(),tokenstack:get_pos() - 1):gsub("^[\"'](.*)[\"']$","%1")
self:set_cursor(tokenstack:get_pos())
props[prop_name]=prop_value else props[prop]=true
self:move_cursor( # prop) end end end
return props end
function LuaXParser:parse_tag() self.indent=self:get_indent()
self:move_to_pattern_end"^%s*"
local tag_name
local is_fragment=self:move_to_pattern_end"^<%s*>"
if is_fragment then tag_name=self.vars.FRAGMENT.name
self.vars.FRAGMENT.required=true else tag_name=self:move_to_pattern_end"^<%s*([^%s/>]+)"
assert(tag_name,self:error"Cannot find tag name")
assert(type(tag_name) == "string","Tag pattern does not capture") end
local is_comment=tag_name:match"^!%-%-+"
local is_propsless=is_fragment or is_comment
local props=is_propsless and {} or self:parse_props()
local no_children=self:move_to_pattern_end"^%s*/%s*>"
if  not (is_propsless or no_children) then assert(self:move_to_pattern_end"^%s*>",self:error"Cannot find end of props") end
local children=no_children and {} or self:parse_text()
if is_fragment then assert(self:move_to_pattern_end"^%s*<%s*/%s*>",self:error"Cannot find fragment end") elseif is_comment then assert(self:move_to_pattern_end"^%s*%-%-+>",self:error"Cannot find comment end") else local patt="^%s*<%s*/%s*" .. escape(tag_name) .. "%s*>"
assert(no_children or self:move_to_pattern_end(patt),self:error"Cannot find ending tag") end
if is_comment then return {["type"] = "comment"} end
return {["type"] = "element",["name"] = tag_name,["props"] = props,["children"] = children} end end
do function LuaXParser:transpile_tag() self.vars.CREATE_ELEMENT.required=true
self.vars.IS_COMPILED.required=true
self.current_block_start=self:get_cursor()
local node=self:parse_tag()
local transpiled=node_to_element(node,self.components.names,self.components.mode,self.vars.CREATE_ELEMENT.name)
self:text_replace_range_move(self.current_block_start,self:get_cursor(),transpiled)
self.current_block_start=nil
self:set_required_variables()
return self.text end
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
return self.text end end
do function LuaXParser.from_inline_string(str,src,variables) local parser=LuaXParser():set_text(str):set_sourceinfo(src or "Unknown inline string")
if variables then parser:handle_variables_as_table(variables):auto_set_components() end
return parser end
function LuaXParser.from_file_content(str,src) return LuaXParser():set_text(str):set_sourceinfo(src or "Unknown file string"):handle_variables_prepend_text():auto_set_components() end
function LuaXParser.from_file_path(path) local f=io.open(path)
if  not f then error(string.format("Unable to open file %q",path)) end
local content=f:read"a"
return LuaXParser.from_file_content(content,path) end end
return LuaXParser