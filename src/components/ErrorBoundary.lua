local use_effect = require("src.hooks.use_effect")
local use_state  = require("src.hooks.use_state")
local RenderInfo = require("src.util.Renderer.RenderInfo")
local DrawGroup  = require("src.util.Renderer.DrawGroup")
local create_element = require("src.create_element")

---@alias LuaX.Component.ErrorBoundary LuaX.Generic.Component<LuaX.PropsWithChildren<{ fallback?: string|function|LuaX.ElementNode }>>

--[[
going from returning multiple children to a single value causes a NativeElement
error.

delete_children_by_key tries to delete an element that doesn't exist. this
doesn't fail directly, but causes the children_by_key table to not update properly.

key 1.2 - ErrorBoundary child

delete_children_by_key 1.2.1.2 is called via component == nil, from initial label being removed due to error.
]]

---@type LuaX.Component.ErrorBoundary
local function ErrorBoundary(props)
    local err, set_err = use_state(nil)
    
    use_effect(function ()
        local info = RenderInfo.get()

        local old_group = info.draw_group
        DrawGroup.ref(old_group)
        local group = DrawGroup.create(function (e)
            set_err(e)
        end, function ()
            DrawGroup.unref(old_group)
        end, function ()
            DrawGroup.ref(old_group)
        end)

        -- evil table injection, but it's mostly ok.
        info.draw_group = group
    end, {})

    if err then
        local fallback = props.fallback
        if type(fallback) == "string" or type(fallback) == "function" then
            return create_element(fallback, { error = err })
        else
            -- Returning a string or function component is totally valid.
            return fallback
        end
    else
        return props.children
    end
end

return ErrorBoundary