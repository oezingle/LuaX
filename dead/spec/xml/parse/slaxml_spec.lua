
local pprint = require("lib.pprint")

local slaxml = require("lib.slaxml")

describe("slaxml", function ()
    it("allows shitty property names", function ()
        local xml = [[
            <Element 
                signal::button::press="A function"
            />
        ]]

        local doc = slaxml:dom(xml, { simple = true })
        
        assert.equal("signal::button::press",doc.kids[2].attr[1].name)
    end)
end)