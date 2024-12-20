---@nospec

local function nocolor_warn(...)
    print("WARNING:", ...)
end

local colors = {
    --RED = "\27[31m",
    YELLOW = "\27[33m",
    RESET = '\27[0m',
}
local function color_warn(...)
    io.stdout:write(colors.YELLOW)

    io.stdout:write(table.concat(table.pack(...), "\t"))

    io.stdout:write(colors.RESET, "\n")
end

local function ensure_warn()
    -- some lua environments provide warn()
    if warn then
        return
    end

    local term = os.getenv("TERM") or ""

    if term:match("xterm") then
        warn = color_warn
    else
        warn = nocolor_warn
    end
end

return ensure_warn