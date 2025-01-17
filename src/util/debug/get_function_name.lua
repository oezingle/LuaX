--- Try to get the local definition of a function. 
--- fails softly. assumes lua chunk is unminified.
---@param location string
local function get_function_name(location)
    local filename = location:match("^(.-):")
    local linenumber = location:match(":(.-)$")

    if not filename or not linenumber then
        return location
    end

    linenumber = tonumber(linenumber)
    local file = io.open(filename, "r")

    if not linenumber or not file then
        return location
    end

    -- seek to that line
    -- I'd use file:seek() but we don't know char count, just line.
    -- This is probably the cheapest way to achieve this
    for _ = 1, linenumber - 1 do
        file:read("l")
    end

    local line = file:read("l")

    local defined_keyword = line:match("function%s*([^%(%s]+)%s*%(")
    if defined_keyword then
        return defined_keyword
    end

    local defined_equal = line:match("([^%s=]+)%s*=%s*function")
    if defined_equal then
        return defined_equal
    end

    local defined_decorator = line:match("([^%s=]+)%s*=%s*[^(]*%(%s*function")
    if defined_decorator then
        return defined_decorator
    end

    local defined_method = line:match("function%s*([^:]+:[^%s(]+)%s*")
    if defined_method then
        return defined_method
    end

    return location
end

local function_name_cache = {}

---@param location string
local function get_function_name_cached(location)
    local cached = function_name_cache[location]

    if cached then
        return cached
    end

    local function_name = get_function_name(location)

    function_name_cache[location] = function_name

    return function_name
end

return get_function_name_cached