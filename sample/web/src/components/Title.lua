
---@type LuaX.Runtime
local LuaX = require("LuaX")
local use_effect = LuaX.use_effect
local use_memo = LuaX.use_memo
local Children = LuaX.Children

local document = require("js").global.document

local Title = function (props)
    local title = use_memo(function()
        return table.concat(Children.map(props.children, function(child)
            return tostring(child.props.value)
        end))
    end, { props.children })

    use_effect(function ()
        local old = document.title
        document.title = title

        return function ()
            document.title = old
        end
    end, { title })end

return Title