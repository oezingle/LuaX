
---@param doc string
---@return string
local function replace_fragments(doc)
    local rep = doc
        :gsub("<>", "<Fragment>")
        :gsub("</>", "</Fragment>")

    return rep
end

return replace_fragments