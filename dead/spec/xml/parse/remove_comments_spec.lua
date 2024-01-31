local remove_comments = require("src.util.xml.parse.remove_comments")

describe("remove_comments", function()
    it("removes single line comments", function()
        local code = [[
            
            --- Print a message or hello world
            ---@param message string?
            local function display (message)
                -- this is a function
                print(message or "Hello world!")
            end
        ]]

        local processed = remove_comments(code)
        local expected = [[local function display (message)
                print(message or "Hello world!")
            end]]

        assert.equal(expected, processed)
    end)

    it("removes multiple line comments", function ()
        local code = "--[[ I'm a comment! ]]"

        local processed = remove_comments(code)
        local expected = ""

        assert.equal(expected, processed)
    end)

    it("removes comments without affecting code", function ()
        local code = "local message = 'Hello world' -- I'm a comment!"
        
        local processed = remove_comments(code)
        local expected = "local message = 'Hello world'"

        assert.equal(expected, processed)
    end)

    it("removes comments from the end of the code", function ()
        local code = "\n -- I'm a comment!"

        local processed = remove_comments(code)
        local expected = ""

        assert.equal(expected, processed)
    end)
end)
