
local inline_transpile = require("src.util.parser.inline.inline_transpile")

-- local pprint = require("lib.pprint")

describe("inline_transpile", function ()
    -- TODO FIXME collects locals fine but doesn't insert. boo!
    it("works nicely first time", function ()
        local a = "Hello World"
        
        local node = inline_transpile([[
            <>
                Local variable "a": {a}
            </>
        ]])

        assert.equal("Hello World", node.props.children[2].props.value)
    end)

    it("caches load results", function ()
        local code = [[
            <>
                Hello World!
            </>
        ]]
    
        local function closure_that_represents_a_component ()
            local node = inline_transpile(code)
    
            return node
        end
    
        local node1 = closure_that_represents_a_component()
        local node2 = closure_that_represents_a_component()
    
        assert.equal(node1, node2)
    end)
end)