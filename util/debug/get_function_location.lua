local function get_function_location(fn) if  not debug then return "UNKNOWN (no debug library)" end
if  not debug.getinfo then return "UNKNOWN (no debug.getinfo)" end
local ok,ret=pcall(function () local info=debug.getinfo(fn,"S")
if info.source == "[C]" then return "[C]" end
local location=info.source:sub(2) .. ":" .. info.linedefined
return location end)
if ok then return ret end
return "UNKNOWN (error calling debug.getinfo)" end
return get_function_location