
local luax_loader = require("src.util.parser.loader.loader")

local function luax_loader_register()
    ---@diagnostic disable-next-line:deprecated
    table.insert(package.searchers or package.loaders, luax_loader)
end

return luax_loader_register