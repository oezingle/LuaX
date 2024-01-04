local function value_to_xml(value)
    local value_type = type(value)

    if value_type == "string" then
        return string.format("%q", value_type)
    end

    if value_type == "number" or value_type == "boolean" then
        return tostring(value)
    end
end

local function props_to_string(props)
    local entries = {}

    for prop, value in pairs(props) do
        if prop ~= "children" then
            table.insert(entries, string.format("%s=%s", prop, value_to_xml(value)))
        end
    end

    return table.concat(entries, " ")
end

local function Div(props)
    return "<div" .. props_to_string(props) .. ">\n" .. table.concat(props.children, "\n") .. "\n</div>"
end
