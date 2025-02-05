local use_ref                = require("src.hooks.use_ref")
local with_virtual_hookstate = require("spec.helpers.with_virtual_hookstate")

describe("use_ref", function()
    it("takes implicit nil as a default", function()
        with_virtual_hookstate(function()
            local ref = use_ref()

            assert.equal(nil, ref.current)
        end)
    end)

    it("takes non-nil as a default", function()
        with_virtual_hookstate(function()
            local ref = use_ref("Hello world!")

            assert.equal("Hello world!", ref.current)
        end)
    end)

    it("doesn't call a re-render on change", function()
        with_virtual_hookstate(function()
            local ref = use_ref("Hello world!")

            ref.current = "Goodbye world!"
        end, function()
            error("ref called re-render")
        end)
    end)
end)
