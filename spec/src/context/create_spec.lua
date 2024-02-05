local create_context = require("src.context.create")
local Context = require("src.context.Context")

describe("create_context", function()
    it("creates contexts", function ()
        local context = create_context({
            hello = "World"
        })

        ---@diagnostic disable-next-line:undefined-field
        assert.equal(Context, context.class)
    end)
end)
