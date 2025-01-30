


---@param components table<string, true> hash map for speed
---@param components_mode "local" | "global"
---@param name string
local function get_component_name(components,components_mode,name) 


local search_name=name:match"^(.-)[%.%[]" or name
local has_component= not  not (components[search_name] or components[name])
local mode_global=components_mode == "global"
local is_global=has_component == mode_global
if is_global then return string.format("%q",name) else return name end end
return get_component_name