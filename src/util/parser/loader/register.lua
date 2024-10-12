local luax_loader = require("src.util.parser.loader.loader")

local has_registered = false

local function luax_loader_register()
    if not has_registered then
        ---@diagnostic disable-next-line:deprecated
        table.insert(package.searchers or package.loaders, luax_loader)
    end

    has_registered = true
end

return luax_loader_register
