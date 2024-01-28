
local XMLElement = require("src.util.NativeElement.XMLElement")
local LuaX = require("src.init")()

local create_element = LuaX.create_element
local use_effect = LuaX.use_effect
local render = LuaX.render

local has_unmounted = false

-- TODO this test broken

local function component ()
    use_effect(function ()
        return function ()
            -- yeah this doesn't work lmao
            has_unmounted = true
        end
    end, {})

    return nil
end

local function main ()
    local element = create_element(component, {})
    
    local root = XMLElement.get_root({
        type = "root",
        children = {}
    })
    
    render(element, root)

    return tostring(root)
end

print(main())
print(has_unmounted)