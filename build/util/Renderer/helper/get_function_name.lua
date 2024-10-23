local function get_function_name(location) local filename=location:match"^(.-):"
local linenumber=location:match":(.-)$"
if  not filename or  not linenumber then return location end
linenumber=tonumber(linenumber)
local file=io.open(filename,"r")
if  not linenumber or  not file then return location end
for _ = 1,linenumber - 1 do file:read"l" end
local line=file:read"l"
local defined_keyword=line:match"function ([^%(%s]+)%s*%("
if defined_keyword then return defined_keyword end
local defined_equal=line:match"([^%s=]+)%s*=%s*function"
if defined_equal then return defined_equal end
return location end
local function_name_cache={}
local function get_function_name_cached(location) local cached=function_name_cache[location]
if cached then return cached end
local function_name=get_function_name(location)
function_name_cache[location]=function_name
return function_name end
return get_function_name_cached