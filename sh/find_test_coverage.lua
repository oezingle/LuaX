local sep = require("src.util.polyfill.path.sep")

local function get_src_files()
    local stdout, err = io.popen("find src -name \"*.lua\"", "r")

    if not stdout then
        error(err)
    end

    return stdout:lines()
end

---@param filename string
---@return boolean
local function ignore_file(filename)
    local file = io.open(filename)

    if not file then
        print(string.format("Expected src file %s inaccessable", filename))

        return false
    end

    -- Loop until non-comment line
    repeat
        local line = file:read('l')

        if not line then
            return false
        end

        -- Annotations are supposed to be 3 lines, but there's no trouble with looking for just 2
        if line:match("%-%-@nospec") or line:match("%-%-@meta") then
            return true
        end
    until not (line:match("^%s*$") or line:match("^%-%-"))

    return false
end

local tests = 0
local passed = 0

for filename in get_src_files() do
    if not ignore_file(filename) then
        tests = tests + 1

        local spec_name = "spec" .. sep .. filename:gsub("%.lua", "_spec.lua")

        local spec_file = io.open(spec_name, "r")

        if not spec_file then
            print(string.format(
                " - No test coverage for %s",
                filename
            ))
        else
            passed = passed + 1
        end
    end
end

local percentage = math.floor((passed / tests) * 100)

print(string.format(
    "%d/%d files have tests (%d%%)",
    passed, tests, percentage
))
