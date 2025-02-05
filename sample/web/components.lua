---@type LuaX
local LuaX = require("LuaX")
local Children = LuaX.Children
local use_memo = LuaX.use_memo
local use_effect = LuaX.use_effect

local components = {}

local js = require("js")
local document = js.global.document

components.ApplicationTitle = LuaX(function(props)
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
    end, { title })
end)

return components
