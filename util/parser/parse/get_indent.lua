local function get_indent(str) local indent=str:match">\n(%s-)%S"
return indent or "" end
return get_indent