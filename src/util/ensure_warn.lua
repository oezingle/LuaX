---@nospec

local table_pack   = require("src.util.polyfill.table.pack")

-- Some flavours of lua don't provide warn()

local warn_enabled = false

---@param ... string
---@return boolean
local function test_control_flag(...)
    local arg1 = ({ ... })[1]

    if arg1 == "@on" then
        warn_enabled = true

        -- we don't want to print "@on"
        return false
    elseif arg1 == "@off" then
        warn_enabled = false
    end

    return warn_enabled
end

local function nocolor_warn(...)
    if test_control_flag(...) then
        print("Lua warning:", ...)
    end
end

local colors = {
    --RED = "\27[31m",
    YELLOW = "\27[33m",
    RESET = '\27[0m',
}
local function color_warn(...)
    if test_control_flag(...) then
        io.stdout:write(colors.YELLOW)

        io.stdout:write(table.concat(table_pack(...), "\t"))

        io.stdout:write(colors.RESET, "\n")
    end
end

local os_getenv = (os or {}).getenv

local function ensure_warn()
    -- some lua environments provide warn()
    if warn then
        return
    end

    local term = os_getenv and os_getenv("TERM") or ""

    if term:match("xterm") then
        warn = color_warn
    else
        warn = nocolor_warn
    end
end

return ensure_warn
