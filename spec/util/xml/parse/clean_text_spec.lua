
local clean_text = require("v3.util.xml.clean_text")

-- 4 spaces here, vs code default.
local indent = "    "

local hello = "Hello world!"

describe("clean_text", function ()
    it("cleans up blocks with no weirdness", function ()
        local text = "Hello world!"

        local clean = clean_text(text, indent, 3)

        assert.equal("Hello world!", clean)
    end)

    it("cleans up blocks with newlines", function ()
        -- lua doesn't start these strings with newlines for some reason
        --[[
        local text = [[
            Hello world!
        ]]

        local text = string.rep(indent, 3) .. hello .. "\n" .. string.rep(indent, 2)

        local clean = clean_text(text, indent, 3)

        assert.equal("Hello world!", clean)
    end)

    -- This is a feature i have to lose :( lua's fault not mine
    --[[
    it("doesn't clean up blocks with tabs", function ()
        local text = "    Hello world!"

        local clean = clean_text(text, indent, 1)

        assert.equal("    Hello world!", clean)
    end)
    ]]

    it("doesn't clean up intentional newlines", function ()
        --[[
        local text = [[

            Hello world!
        ]]

        local text = "\n" .. string.rep(indent, 3) .. hello .. "\n" .. string.rep(indent, 2)

        local clean = clean_text(text, indent, 3)

        assert.equal("\nHello world!", clean)
    end)

    it("doesn't clean up intentional tabs", function ()
        --[[
        local text = [[
                Hello world!
        ]]

        local text = string.rep(indent, 4) .. hello .. "\n" .. string.rep(indent, 2)

        local clean = clean_text(text, indent, 3)

        assert.equal("    Hello world!", clean)
    end)

end)