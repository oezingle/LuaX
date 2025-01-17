if  not ... then error"this file must be loaded via require()" end
local folder_of_this_file=(...):match"(.-%.)[^%.]+$" or ""
local uuid="lib_LuaX"
local function loader(libraryname) if libraryname:sub(1, # uuid) == uuid then local resolved_path=folder_of_this_file .. libraryname:sub(2 +  # uuid)
return function () return require(resolved_path) end end end
local vanilla_searchpath=package.searchpath
local function modified_searchpath(name,path,sep,rep) if name:sub(1, # uuid) == uuid then local resolved_path=folder_of_this_file .. name:sub(2 +  # uuid)
return vanilla_searchpath(resolved_path,path,sep,rep) end
return vanilla_searchpath(name,path,sep,rep) end
local function add_custom_loader() table.insert(package.searchers or package.loaders,loader)
package.searchpath=modified_searchpath end
add_custom_loader()