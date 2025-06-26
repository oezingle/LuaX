
local console_warn = require("js").global.console.warn

return function (...)
    local args = table.pack(...)

    local strings = {}
    for i, arg in ipairs(args) do
        strings[i] = tostring(arg)
    end

    console_warn(table.concat(strings, "\t"))
end