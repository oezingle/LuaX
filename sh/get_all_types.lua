
local list = require("src.cmd.fs.list").ls
local join = require("src.util.polyfill.path.join")
local is_dir = require("src.cmd.fs.is_dir")

---@param path string
---@return string
local function read (path)
    local f, err = io.open(path, "r")

    if not f then
        error(err)
    end

    return f:read("a")
end

local pass_annotation_types = {
    ["class"] = true,
    ["field"] = true,
    ["operator"] = true,
    ["alias"] = true
}

---@param path string
---@param annotations string[]
local function scrape_annotations (path, annotations)
    local content = read(path)

    local PATTERN_ANNOTATION = "%-%-%-@[^\n\r]+"
    local PATTERN_ANNOTATION_TYPE ="%-%-%-@(%S+)"

    local i = 0
    while true do
        local a_start, a_end = content:find(PATTERN_ANNOTATION, i)

        if not (a_start and a_end) then
            break
        end

        local annotation = content:sub(a_start ,a_end)

        local annotation_type = annotation:match(PATTERN_ANNOTATION_TYPE)

        if pass_annotation_types[annotation_type] then
            table.insert(annotations, annotation)
        -- TODO this is a hack - edge cases: nested generics, dangling generics.
        -- Yes these are code style issues but my code style sucks.
        elseif annotation_type == "generic" then
            -- assert next line is passed or generic
            local next_line = content:match(PATTERN_ANNOTATION, a_end)

            if next_line and pass_annotation_types[next_line:match(PATTERN_ANNOTATION_TYPE)] then
                table.insert(annotations, annotation)
            end
        end

        i = a_end
    end
end

---@param dir string
---@param annotations string[]?
local function recurse (dir, annotations)
    annotations = annotations or {}

    for _, file in ipairs(list(dir)) do
        local path = join(dir, file)

        if is_dir(path) then
            recurse(path, annotations)
        else
            scrape_annotations(path, annotations)
        end
    end

    return annotations
end

local function main ()
    local annotations = recurse("src")

    local f, err = io.open("LuaX_types.lua.txt", "w")
    
    if not f then
        error(err)
    end

    for _, annotation in ipairs(annotations) do
        f:write(annotation, "\n")
    end

    f:flush()
    f:close()
end

main()