<!-- TODO rewrite: I wrote these docs with a very bad head cold. -->

# Portals

Portals in LuaX diverge from Portals in React. However, this is for good reason.
React relies on the HTML+JavaScript DOM model to select an output, but a
solution such as that would interfere with LuaX's UI library agnosticism.
Instead of using `createPortal`, `Portal` is a class that one must instantiate,
once per component instance. 

To display children using a portal, you can render `<Portal.Outlet />` and
insert children to `<Portal.Inlet />`. `<Portal.Provider />` and `use_portal`
exist to provide Portals to components far below in the hierarchy.

## Example

```lua
local PortalChild = LuaX(function (props)
    -- See PortalRoot re: "my-portal"
    local MyPortal = use_portal("my-portal")

    return [[
        <MyPortal.Inlet>
            Hello Portal!
        </MyPortal.Inlet>
    ]]
end)

local PortalRoot = LuaX(function ()
    local MyPortal = use_memo(function ()
        -- Portal.create optionally takes a name, allowing you to distinguish 
        -- which portal you wish to use if there are multiple in the scope.
        return Portal.create("my-portal")
    end)
    
    return [[
        <>
            <MyPortal.Outlet />

            <MyPortal.Provider>
                <SomeComponent>
                    <PortalChild />
                </SomeComponent>
            </MyPortal.Provider>
        </>
    ]]
end)
```

Some notes regarding this example:
 1. There may be multiple inlets for a single portal, but only one distinct
    outlet. Multiple outlets can be rendered, but this application is not
    supported and would result in either identical content on all of the outlets
    or an error.
 2. Passing a `Portal` between components can be done using props as well, but
    `Portal.Provider` provides a value for an internal context

