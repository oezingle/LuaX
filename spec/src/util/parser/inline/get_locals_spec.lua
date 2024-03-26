local get_locals = require("src.util.parser.inline.get_locals")

describe("get_locals", function()
    it("reads local variables", function()
        local message = "Hello World!"

        local locals = get_locals(2)

        assert.equal(message, locals.message)
    end)

    it("reads variables that are within scope but not defined there", function()
        local message = "Hello World!"

        do
            local locals = get_locals(2)

            assert.equal(message, locals.message)
        end
    end)

    it("reads changes in variables", function ()
        local message = "Hello World!"

        local function do_assertion()
            local locals = get_locals(3)

            assert.equal(message, locals.message)
        end

        do_assertion()

        message = "Goodbye world!"

        do_assertion()
    end)
end)
