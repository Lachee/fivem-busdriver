Route = {}
Route.active = {}

Route.SetGps = function(route)
    ClearGpsMultiRoute()
    StartGpsMultiRoute(8, true, false)
    for _, s in pairs(route.stops) do
        AddPointToGpsMultiRoute(s.x+.0, s.y+.0, s.z+.0)
    end
    SetGpsMultiRouteRender(true)
end

--[[
Route.ActivateRoute = function(route)
    print('route', 'activating route', route.id)
    if not Route.active[route.id] then
    end

    local routeInfo = Route.active[route.id]
    routeInfo.usage = routeInfo.usage + 1
end

Route.DeactivateRoute = function(route)
    print('route', 'deactivating route', route.id)
    if not Route.active[route.id] then return end
    
    local routeInfo = Route.active[route.id]
    routeInfo.usage = routeInfo.usage - 1
    if routeInfo.usage <= 0 then

    end
end
]]


Route.RegisterEvents = function(ESX)
    --TODO: Implement this functionality
    --[[
    RegisterNetEvent(E.RouteActive)
    AddEventHandler(E.RouteActive, Route.ActivateRoute)
    
    RegisterNetEvent(E.RouteDeactive)
    AddEventHandler(E.RouteDeactive, Route.DeactivateRoute)
    ]]
end