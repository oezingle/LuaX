
local table_pack = table.pack or function (...)
    local t = {...}

    -- luajit (lua 5.1?) is sometimes bad at ascertaining the length of a packed table.
    local len = select("#", ...)
    t['n'] = len

    return t
end

return table_pack