
--- Modified from src/util/polyfill/string/split.lua, as string_split() wraps
--- multiple occurrences of sep into one split. This is generally good, as we
--- get no empty strings, but remove_default_indent may not remove lines from
--- LuaX tags. 
--- 
---@param inputstr string
---@param sep string?
local function string_split_with_empties(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]*)") do
            table.insert(t, str)
    end
    return t
end

--- This might be like O(n^3) but doesn't matter because it's done in transpilation!
---@param doc string
---@return string
local function remove_default_indent(doc)
    local starts_with_newline = "^\n"

    while doc:match(starts_with_newline) do
        doc = doc:gsub(starts_with_newline, "")
    end

    -- match start of string, whitespace, and then XML < tag or text
    local default_indent = doc:match("^(%s*)%S") or ""

    local lines = string_split_with_empties(doc, "\n")

    for i, line in ipairs(lines) do
        lines[i] = line:gsub("^" .. default_indent, "")
    end

    return table.concat(lines, "\n")
end

return remove_default_indent
