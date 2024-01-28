
local parse_xml = require("v3.util.xml.parse")
local pprint = require("lib.pprint")

describe("slaxml", function ()
    it("allows shitty property names", function ()
        local xml = [[
            <Element 
                signal::button::press="A function"
            />
        ]]

        local doc = parse_xml(xml)
        
        assert.equal("signal::button::press",doc.kids[2].attr[1].name)

        -- pprint(doc)
    end)
end)