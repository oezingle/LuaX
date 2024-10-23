local function get_function_location(fn) if  not debug then return "UNKNOWN (no debug library)" end
if  not debug.getinfo then return "UNKNOWN (no debug.getinfo)" end
local success,res=pcall(function () local info=debug.getinfo(fn,"S")
local location=info.short_src .. ":" .. info.linedefined
return location end)
if success then return string.format("%s",res) end
return "UNKNOWN (error calling debug.getinfo)" end
return get_function_location