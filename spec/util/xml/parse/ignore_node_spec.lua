local ignore_node = require("v3.util.xml.ignore_node")

describe("ignore_node", function()
    it("works for comments", function()
        local node = {
            type = "comment"
        }

        assert.truthy(ignore_node(node))
    end)

    it("works for text", function()
        local node = {
            name = '#text',
            type = 'text',
            value = '            '
        }

        assert.truthy(ignore_node(node))
    end)
end)
