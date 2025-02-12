local NativeElement      = require("src.util.NativeElement")
local warn_once          = require("src.util.warn_once")

local function get_global_components()
    -- Check if we can safely use global mode for component names
    local globals = {}

    ---@type LuaX.NativeElement[]
    local subclasses_of_native_element = NativeElement:subclasses()

    if #subclasses_of_native_element == 0 then
        warn_once(
            "LuaX Parser: NativeElement has not been extended yet - defaulting to local variable lookup" .. '\n' ..
            "to use global mode, import your NativeElement implementation before any LuaX files"
        )

        return nil
    end

    for i, NativeElementImplementation in ipairs(subclasses_of_native_element) do
        -- saves some memory to do this here, as every string from this class in globals will be the same
        local implementation_name = tostring(NativeElementImplementation)

        -- try to strip 30log's info - we only need class name
        implementation_name = implementation_name:match("class '([^']+)'") or implementation_name

        if not NativeElementImplementation.components then
            warn_once(string.format(
                "LuaX Parser: NativeElement subclass %s does not have a component registry list - defaulting to local variable lookup",
                implementation_name
            ))

            return nil
        end

        for _, component_name in ipairs(NativeElementImplementation.components) do
            if globals[component_name] then
                warn_once(string.format(
                    "LuaX Parser: Multiple NativeElement implementations implement an element called %q.",
                    component_name
                ))
            end

            -- so that we can look up which implementation uses this
            globals[component_name] = i
        end
    end

    return globals
end

local last_globals = nil
local last_subclass_count = nil
local function get_global_components_cached ()
    local subclass_count = #NativeElement:subclasses()
    
    if subclass_count ~= last_subclass_count or not last_globals then
        last_globals = get_global_components()
    end

    return last_globals
end

return get_global_components_cached