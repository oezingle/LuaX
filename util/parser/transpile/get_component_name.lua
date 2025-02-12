local function get_component_name(components,components_mode,name) if name:sub(1,5) == "LuaX." then return string.format("%q",name:sub(6)) end
local search_name=name:match"^(.-)[%.%[]" or name
local has_component=components[search_name] or components[name]
local mode_global=components_mode == "global"
local is_global=has_component == mode_global
if is_global then return string.format("%q",name) else return name end end
return get_component_name