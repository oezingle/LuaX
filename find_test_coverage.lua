
require("src.util.replace_warn")

local function get_src_files()
    local stdout, err = io.popen("find src -name \"*.lua\"", "r")

    if not stdout then
        error(err)
    end

    return function()
        return stdout:read()
    end
end

local tests = 0
local passed = 0

for filename in get_src_files() do
    tests = tests + 1

    local expected_spec = filename
        :gsub("^src", "spec")
        :gsub("%.lua", "_spec.lua")

    local file = io.open(expected_spec, "r")

    if not file then
        warn(string.format(
            " - No test coverage for %s",
            filename
        ))
    else
        passed = passed + 1
    end
end

local percentage = math.floor((passed / tests) * 100)

print(string.format(
    "%d/%d files have tests (%d%%)",
    passed, tests, percentage
))