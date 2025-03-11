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
local NativeElement=require"lib_LuaX.util.NativeElement"
local warn_once=require"lib_LuaX.util.warn_once"
local function get_global_components() local globals={}
local subclasses_of_native_element=NativeElement:subclasses()
if  # subclasses_of_native_element == 0 then warn_once("LuaX Parser: NativeElement has not been extended yet - defaulting to local variable lookup" .. "\n" .. "to use global mode, import your NativeElement implementation before any LuaX files")
return nil end
for i,NativeElementImplementation in ipairs(subclasses_of_native_element) do local implementation_name=tostring(NativeElementImplementation)
implementation_name=implementation_name:match"class '([^']+)'" or implementation_name
if  not NativeElementImplementation.components then warn_once(string.format("LuaX Parser: NativeElement subclass %s does not have a component registry list - defaulting to local variable lookup",implementation_name))
return nil end
for _,component_name in ipairs(NativeElementImplementation.components) do if globals[component_name] then warn_once(string.format("LuaX Parser: Multiple NativeElement implementations implement an element called %q.",component_name)) end
globals[component_name]=i end end
return globals end
local last_globals=nil
local last_subclass_count=nil
local function get_global_components_cached() local subclass_count= # NativeElement:subclasses()
if subclass_count ~= last_subclass_count or  not last_globals then last_globals=get_global_components() end
return last_globals end
return get_global_components_cached