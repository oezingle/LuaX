local Renderer = require("src.util.Renderer")
local XMLElement = require("spec.helpers.XMLElement")
local create_element = require("src.create_element")

---@param element LuaX.ElementNode | string | LuaX.FunctionComponent
---@return LuaX.XMLElement root, function render
local function render_set_up(element)
    local renderer = Renderer()

    if type(element) == "string" or type(element) == "function" then
        element = create_element(element, {})
    end

    local root = XMLElement.get_root()

    local function render()
        renderer:render(element, root)
    end

    return root, render
end

return render_set_up
