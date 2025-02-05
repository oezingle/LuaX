local function can_modify_child(child,container,key) local existing_children=container:get_children_by_key(key)
if  not existing_children then return false,existing_children end
if  # existing_children ~= 0 then return false,existing_children end
local existing_child=existing_children
if  not existing_child.get_type then return false,existing_children end
if existing_child:get_type() ~= child.type then return false,existing_children end
return true,existing_child end
return can_modify_child