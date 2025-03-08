
local Children = require("src.Children")
local create_element = require("src.create_element")

describe("Children", function ()
    it("Flattens nil", function ()
        local children = nil

        local flat = Children.flatten(children)

        assert.equal(0, #flat)
        assert.Nil(next(flat))
    end)

    it("Flattens a single child", function ()
        local children = create_element("div", {})

        local flat = Children.flatten(children)

        assert.equal(1, #flat)
    end)

    it("Flattens multiple children", function ()
        local children = {
            create_element("div", {}),
            create_element("div", {})
        }

        local flat = Children.flatten(children)

        assert.equal(2, #flat)
    end)
end)