

local slaxml = require("lib.slaxml")
local pprint = require("lib.pprint")
local clean_node = require("v3.util.xml.clean_node")

describe("clean_node", function ()
    it("cleans up nicely", function ()
        local xml = [[
            <Element>
                I am text 1!

                <Child>
                    I am text 2!
                </Child>

                <Child>I am text 3!</Child>
            </Element>
        ]]

        local doc = slaxml:dom(xml, { simple = true })
        
        local doc_clean = clean_node(doc, 2)

        -- pprint(doc_clean)
    end)
end)