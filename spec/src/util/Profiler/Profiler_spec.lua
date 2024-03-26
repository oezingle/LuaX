
-- TODO FIXME what the fuck is this. it isn't a test

local Profiler = require("src.util.Profiler.Profiler")
local ElementNode = require("src.util.ElementNode")

local profiler = Profiler()

profiler:start()

local static_render = require("spec.helpers.static_render")
local create_element = require("src.create_element")
local Fragment = require("src.components.Fragment")

local function main ()
    local element = create_element(Fragment, {
        children = {
            create_element(ElementNode.LITERAL_NODE, {
                value = "Hello World!"
            })
        }
    })

    local component = static_render(element)
end

main()

--require("find_test_coverage")

profiler:stop()

-- profiler:dump("callgrind.out.profiler.txt", "KCacheGrind")

-- kcachegrind callgrind.out.profiler.txt

-- os.execute("kcachegrind callgrind.out.profiler.txt")