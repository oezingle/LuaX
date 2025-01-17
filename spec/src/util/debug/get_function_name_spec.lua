local get_function_location = require("src.util.debug.get_function_location")
local get_function_name = require("src.util.debug.get_function_name")


describe("get_function_name", function()
    it("works with locals defined using local function", function()
        local function SomeFunction()
        end

        local location = get_function_location(SomeFunction)

        assert.equal("SomeFunction", get_function_name(location))
    end)

    it("works with locaals defined using =", function()
        local SomeFunction = function()
        end

        local location = get_function_location(SomeFunction)

        assert.equal("SomeFunction", get_function_name(location))
    end)

    it("works with class members defined using function keyword", function()
        local Class = {}

        function Class:SomeFunction()
        end

        local location = get_function_location(Class.SomeFunction)

        assert.equal("Class:SomeFunction", get_function_name(location))
    end)

    it("works with table members defined function keyword", function()
        local Class = {}

        function Class.SomeFunction ()
        end

        local location = get_function_location(Class.SomeFunction)

        assert.equal("Class.SomeFunction", get_function_name(location))
    end)


    it("works with table members defined using =", function()
        local Class = {}

        Class.SomeFunction = function()
        end

        local location = get_function_location(Class.SomeFunction)

        assert.equal("Class.SomeFunction", get_function_name(location))
    end)
end)
