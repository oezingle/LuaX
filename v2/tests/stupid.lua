local create_element = require "v2.create_element"

-- a stupid test to make sure my implemntation isn't bad

local function stupid_little_component (children)
    return children
end

local element = create_element("box", {
    children = {
        create_element("text", {
            children = {
                "I'm a text node"
            }
        }),
        create_element("text", {
            children = "I'm a harder text node!"
        }),
        create_element(stupid_little_component, {
            
        })
    }
})

element:_print_heirarchy()