local ClientContext       = require("awesome.ClientContext")
local use_context         = require("src.hooks.use_context")
local use_instance_signal = require("awesome.hooks.use_instance_signal")

--- Custom hook wahoo
---@generic P
---@param client Awesome.Client
---@param properties P[]
local function use_client_properties(client, properties)
    -- return use_instance_signal(client, "property::name", function (client)
    --     return client[]
    -- end)

    local ret = {}
    for _, property in ipairs(properties) do
        local signal_name = string.format("property::%s", property)

        -- TODO also get a setter here
        ret[property] = use_instance_signal(client, signal_name, function(client)
            return client[property]
        end)
    end

    return ret
end

local debug = debug
local function get_caller()
    if not debug then
        return "unknown"
    end

    local info = debug.getinfo(3, "nS")

    return string.format("%s (%s:%d)", info.name, info.short_src, info.linedefined)
end

local printed = {}
local function print_once(message)
    if not printed[message] then
        printed[message] = true

        print(message)
    end
end

-- TODO determine which of these do not change if any.
local default_signal_properties = {
    "name",                 -- string The client title.
    "skip_taskbar",         -- boolean True if the client does not want to be in taskbar.
    "type",                 -- "desktop" | "dock" | "splash" | "dialog" | "menu" | "toolbar" | "utility" | "dropdown_menu" | "popup_menu" | "notification" | "combo" | "dnd" | "normal" The window type.
    "class",                -- string The client class. To get a client class from the command line, use the command xprop WM_CLASS. The class will be the second string.
    "instance",             -- string The client instance. To get a client instance from the command line, use the command xprop WM_CLASS. The instance will be the first string.
    "icon_name",            -- string The client name when iconified.
    "icon",                 -- Awesome.Gears.Surface The client icon as a surface.
    "icon_sizes",           -- { [0]: number, [1]: number }[] The available sizes of client icons. This is a table where each entry contains the width and height of an icon.
    "screen",               -- Screen Client screen.
    "hidden",               -- boolean Define if the client must be hidden, i.e. never mapped, invisible in taskbar.
    "minimized",            -- boolean Define it the client must be iconify, i.e. only visible in taskbar.
    "size_hints_honor",     -- boolean Honor size hints, e.g. respect size ratio. This is enabled by default. To disable it by default, see awful.rules.
    "border_width",         -- integer The client border width
    "border_color",         -- Awesome.Color The client border color
    "urgent",               -- boolean The client's urgent state
    "opacity",              -- number The client opacity. 0.0 - 1.0
    "ontop",                -- boolean If the client is on top of every other window
    "above",                -- boolean If the client is above normal windows
    "below",                -- boolean If the client is below normal windows
    "fullscreen",           -- boolean If the client is fullscreen
    "maximized",            -- boolean If the client is maximized
    "maximized_horizontal", -- boolean If the client is maximized horizontally
    "maximized_vertical",   -- boolean If the client is maximized vertically
    "transient_for",        -- Awesome.Client|nil The client the window is transient for
    "group_window",         -- Awesome.Client|nil Window identification unique to a group of windows
    "leader_window",        -- Awesome.Client|nil Identification unique to windows spawned by the same command
    "size_hints",           -- { user_position: integer, user_size: integer, program_position: integer, program_size: integer, max_width: integer, max_height: integer, min_width: integer, min_height: integer, width_inc: integer, height_inc: integer } A table with size hints of the client.
    "motif_wm_hints",       -- nil|{ functions: { all: boolean?, resize: boolean?, move: boolean?, minimize: boolean?, maxmimize: boolean? }?, decorations: { all: boolean?, border: boolean?, resizeh: boolean?, title: boolean?, menu: boolean?, minimize: boolean?, maximize: boolean? }?, input_mode: string?, status: { tearoff_window: boolean? }? } The motif WM hints of the client. This is nil if the client has no motif hints. Otherwise, this is a table that contains the present properties. Note that awesome provides these properties as-is and does not interpret them for you. For example, if the function table only has “resize” set to true, this means that the window requests to be only resizable, but asks for the other functions not to be able. If however both “resize” and “all” are set, this means that all but the resize function should be enabled
    "sticky",               -- boolean Set the client sticky, ie available on all tags
    "modal",                -- boolean Indicate if the client is modal
    "focusable",            -- boolean True if the client can receive the input focus
    "valid",                -- boolean If the client that this object refers to is still managed by awesome. To avoid errors use `local is_valid = pcall(function() return c.valid end) and c.valid`
    "first_tag",            -- Awesome.Tag The first tag of the client. Optimized form of `c:tags()[1]`
    "marked",               -- boolean If the client is marked or not
    "is_fixed",             -- boolean If the client has a fixed size or not.
    "immobilized",          -- boolean Is the client immobilized?
    "floating",             -- boolean If the client is floating
    "x",                    -- integer The x coordinate
    "y",                    -- integer The y coordinate
    "width",                -- integer The client width
    "height",               -- integer The client height
    "dockable",             -- boolean If the client is dockable.  A dockable client is an application confined to the edge of the screen. The space it occupies is substracted from the `screen.workarea`. Clients with a type of “utility”, “toolbar” or “dock” are dockable by default.
    "requests_no_titlebar", -- boolean If the client requests not to be decorated with a titlebar
}

local properties_passed = {
    ["window"] = true,
    ["pid"] = true,
    ["role"] = true,
    ["machine"] = true,
    ["shape_bounding"] = true,
    ["shape_clip"] = true,
    ["shape_input"] = true,
    ["client_shape_bounding"] = true,
    ["client_shape_clip"] = true,
    ["startup_id"] = true,
    ["shape"] = true,
}

---@param properties string[]?
local function use_client(properties)
    local client = use_context(ClientContext)

    if not properties then
        print_once(
            "use_client: please specify a list of client properties to " ..
            "export. The default list includes every property and will " ..
            "impact performance - called by " .. get_caller()
        )
    end

    local signaled_properties = use_client_properties(client, properties or default_signal_properties)

    return setmetatable(signaled_properties, {
        __index = function(_, key)
            local value = client[key]

            if properties_passed[key] then
                return value
            elseif type(value) == "function" then
                return function(_, ...)
                    value(client, ...)
                end
            else
                print_once(string.format(
                    "use_client: property %q is not exported. To retrieve " ..
                    "this property, add it to the use_client property list " ..
                    "- called by %s", key, get_caller()
                ))
            end
        end
    })
end

return use_client
