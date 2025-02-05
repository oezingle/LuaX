
describe("load()", function ()
    it("needs to be rerun when env changes", function ()
        local message = "<empty>"
        
        local get_message, err = load("return message", nil, nil, {
            message = message
        })

        if not get_message then
            error(err)
        end

        assert.equal(message, get_message())

        message = "Hello World!"

        assert.are_not_equal(message, get_message())
    end)

    it("takes longer in text mode", function ()
        local start = os.clock()

        for i = 0, 100 do
            local get_get_message, err = load("return function () return \"Hello World!\" end", "string code", "t")

            if not get_get_message then 
                error(err)
            end 
        end

        local finish_text = os.clock()

        local bytecode = string.dump(function () return "Hello World!" end)

        for i = 0, 100 do
            local get_message, err = load(bytecode, "string code", "b")

            if not get_message then 
                error(err)
            end 
        end

        local finish_byte = os.clock()

        local text_time = finish_text - start
        local byte_time = finish_byte - finish_text

        assert.truthy(text_time > byte_time)
    end)
end)