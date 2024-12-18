local Renderer = require("src.util.Renderer")
local ProfiledRenderer = require("src.util.Renderer.Profiled")
local XMLElement = require("src.util.NativeElement.XMLElement")
local create_element = require("src.create_element")

---@param element LuaX.ElementNode | string | LuaX.FunctionComponent
---@param options { profiled?: boolean }?
---@return LuaX.XMLElement root, function render
local function render_set_up(element, options)
    options = options or {}

    local renderer = options.profiled and ProfiledRenderer() or Renderer()

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
