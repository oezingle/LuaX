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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.NativeElement.GtkElement.lgi.")
require(library_root .. "_shim") end
local has_lgi,lgi=pcall(require,"lgi")
if  not has_lgi then error"Cannot load lgi, therefore cannot load Gtk 3.0 using lgi" end
local has_Gtk,Gtk=pcall(lgi.require,"Gtk","3.0")
if  not has_Gtk then error"Loaded lgi, but cannot load Gtk 3.0 using lgi" end
local has_GObject,GObject=pcall(lgi.require,"GObject")
if  not has_GObject then error"Loaded lgi and Gtk, but cannot load GObject using lgi. Are you sure Gtk is installed properly?" end
local NativeElement=require"lib_LuaX.util.NativeElement"
local NativeTextElement=require"lib_LuaX.util.NativeElement.NativeTextElement"
local Gtk3Element=NativeElement:extend"LuaX.GtkElement (lgi,3.0)"
function Gtk3Element:init(native,widget_name) native:show()
self.widget=native
self.widget_name=widget_name
self.texts={}
self.signal_functions={}
self.signal_ids={} end
function Gtk3Element:set_prop(prop,value) local widget=self.widget
if prop:match"^LuaX::" then local prop_name=prop:sub(7)
if prop_name == "onload" and  not self.has_had_onload then value(self,widget)
self.has_had_onload=true end elseif prop == "show" then if value == false then widget:hide() else widget:show() end elseif prop:match"^on_" then local existing_handler=self.signal_ids[prop]
if existing_handler then GObject.signal_handler_disconnect(widget,existing_handler) end
self.signal_functions[prop]=value
self.signal_ids[prop]=widget[prop]:connect(value) else widget["set_" .. prop](widget,value) end end
function Gtk3Element:get_prop(prop) local widget=self.widget
if prop:match"^LuaX::" then return  end
if prop == "show" then return widget:get_visible() end
if prop:match"^on_" then return self.signal_functions[prop] end
return widget["get_" .. prop](widget) end
function Gtk3Element:get_trailing_children(index) local children=self.widget:get_children()
local after={}
for i = index, # children do local child=children[i]
table.insert(after,child)
child:ref()
self.widget:remove(child) end
return after end
function Gtk3Element:reinsert_trailing_children(list) for _,child in ipairs(list) do self.widget:add(child)
child:unref() end end
function Gtk3Element:insert_child(index,element,is_text) if is_text then table.insert(self.texts,index,element)
self:_reload_text() else local after=self:get_trailing_children(index)
self.widget:add(element.widget)
self:reinsert_trailing_children(after) end end
function Gtk3Element:delete_child(index,is_text) if is_text then table.remove(self.texts,index) else local after=self:get_trailing_children(index + 1)
local children=self.widget:get_children()
local remove_child=children[index]
self.widget:remove(remove_child)
remove_child:destroy()
self:reinsert_trailing_children(after) end end
function Gtk3Element:get_type() return self.widget_name end
function Gtk3Element.create_element(name) local elem=name:match"Gtk%.(%S+)"
assert(elem,"GtkElement must be specified by Gtk.<Name>")
local native=Gtk[elem]()
assert(native,string.format("No Gtk.%s",elem))
return Gtk3Element(native,name) end
function Gtk3Element.get_root(native) return Gtk3Element(native,"root") end
function Gtk3Element:_reload_text() local texts={}
for _,text_element in ipairs(self.texts) do table.insert(texts,text_element.value) end
local text=table.concat(texts,"")
self:set_prop("label",text) end
local GtkText=NativeTextElement:extend"LuaX.GtkElement.Text (lgi,3.0)"
function GtkText:set_value(value) self.value=value
self.parent:_reload_text() end
function GtkText:get_value() return self.value end
function Gtk3Element.create_literal(value,parent) return GtkText(value,parent) end
return Gtk3Element