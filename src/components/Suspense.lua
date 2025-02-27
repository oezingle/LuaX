local DrawGroup         = require("src.util.Renderer.DrawGroup")
local RenderInfo        = require("src.util.Renderer.RenderInfo")
local NativeTextElement = require("src.util.NativeElement.NativeTextElement")
local VirtualElement    = require("src.util.NativeElement.VirtualElement")
local traceback         = require("src.util.debug.traceback")
local use_effect        = require("src.hooks.use_effect")
local use_state         = require("src.hooks.use_state")
local use_memo          = require("src.hooks.use_memo")
local create_element    = require("src.create_element")


local no_op = function() end

---@alias LuaX.Component.Suspense LuaX.Generic.Component<LuaX.PropsWithChildren<{ fallback?: LuaX.ElementNode|string|function }>>

---@type LuaX.Component.Suspense
local function Suspense(props)
    local complete, set_complete = use_state(false)

    --- Clone RenderInfo so that we don't modify current RenderInfo
    ---@type LuaX.RenderInfo.Info
    local info = use_memo(function()
        local info = RenderInfo.clone(RenderInfo.current)

        -- Create new DrawGroup
        local group = DrawGroup.create(info.draw_group.on_error, function()
            set_complete(true)
        end, function()
            set_complete(false)
        end)
        info.draw_group = group

        return info
    end, {})

    local key = info.key
    local container = info.container
    local renderer = info.renderer

    local clone = use_memo(function()
        -- TODO I hate this pattern. How can we createa a generic container?
        -- I can't pass container:get_native() because that could have side
        -- effects (init is non-atomic, eg GtkElement visibility could change.)
        local ok, ret = xpcall(container:get_class().get_root, traceback)

        if not ok then
            error(
                "Looks like this NativeElement implementation doesn't support nil root elements. This is required for Suspense to work. " ..
                tostring(ret))
        end

        local instance = ret

        -- overload clone's insert_child and delete_child methods - we call this on container when ready.
        instance.insert_child = no_op
        instance.delete_child = no_op

        return instance
    end, { container })

    use_effect(function()
        ---@diagnostic disable-next-line:invisible
        renderer.workloop:add(renderer.render_keyed_child, renderer, props.children, clone, key, info)

        renderer.workloop:safely_start()
    end, { renderer, props.children, clone, key, info })

    -- Manage children in container
    use_effect(function()
        -- clear existing children in this key's slot.

        -- Calling container:delete_children_by_key() or returning
        -- props.fallback without this block would mean that cleanup
        -- functions are called, and we don't want that.
        ---@diagnostic disable-next-line:invisible
        local children = container:flatten_children(key)

        ---@diagnostic disable-next-line:invisible
        local delete_index = container:count_children_by_key(key)

        for i = #children, 1, -1 do
            local child = children[i].element

            if child.class ~= VirtualElement then
                local is_text = NativeTextElement:classOf(child.class) or false

                container:delete_child(delete_index, is_text)

                delete_index = delete_index - 1
            end
        end

        ---@diagnostic disable-next-line:invisible
        container:set_child_by_key(key, nil)

        -- check if we insert prerendered children
        if complete then
            -- Insert all rendered children into the real container from the clone

            ---@diagnostic disable-next-line:invisible
            local children = clone:flatten_children(key)

            for _, child in ipairs(children) do
                container:insert_child_by_key(child.key, child.element)
            end
        end
    end, { complete, container, clone, key })

    -- returning props.children here seems weird - see use_effect above
    if complete then
        return props.children
    else
        local fallback = props.fallback
        if type(fallback) == "string" or type(fallback) == "function" then
            return create_element(fallback, {})
        else
            -- Returning a string or function component is totally valid.
            return fallback
        end
    end
end

return Suspense
