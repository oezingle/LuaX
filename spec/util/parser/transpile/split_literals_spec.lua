local split_literals = require "src.util.parser.transpile.split_literals"

describe("split_literals", function ()
    it("splits string literals", function ()
        local str = [["My message is {message}!"]]

        local split = split_literals(str)

        local message = "be excellent to each other"

        local get_str, err = load("return " .. split, "transpiled split_literals", "t", {
            message = message,
            tostring = tostring
        })

        if not get_str then
            error(err)
        end

        assert.equal("My message is be excellent to each other!", get_str())
    end)

    it("splits numerical literals", function ()
        local str = [["{number} is double digits"]]

        local split = split_literals(str)

        local number = 10

        local get_str, err = load("return " .. split, "transpiled split_literals", "t", {
            number = number,
            tostring = tostring
        })

        if not get_str then
            error(err)
        end

        assert.equal("10 is double digits", get_str())
    end)

    it("splits multiple litearls", function ()
        local str = [["{name} has {number} {fruit}s"]]

        local split = split_literals(str)

        local get_str, err = load("return " .. split, "transpiled split_literals", "t", {
            name = "Dave",
            number = 3,
            fruit = "apple",
            tostring = tostring
        })

        if not get_str then
            error(err)
        end

        assert.equal("Dave has 3 apples", get_str())
    end)
end)