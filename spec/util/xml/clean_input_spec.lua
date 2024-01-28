
local xml_clean_input = require("v3.util.xml.clean_input")

-- TODO FIXME this shit

describe("clean_input", function ()
    it("cleans the beginning", function ()
        local clean = xml_clean_input([[
            <Element>
                
                <Typography>I'm text 1!</Typography>


                <Typography>
                    
                    I'm text 2!
                    
                </Typography>

            </Element>
        ]])

        -- print()
        -- print(clean)
    end)
end)