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

-- Show the blips for all the stops we plan to make
Route.ShowBlips = function(route)
    for _, s in pairs(route.stops) do
        BusStop.ShowBlip(s, true, BlipColor.White)
    end
end

-- Hides all the blips in the route
Route.HideBlips = function(route)
    for _, s in pairs(route.stops) do
        BusStop.HideBlip(s)
    end
end


Route.RegisterEvents = function(ESX)
    --TODO: Implement this functionality
    --[[
    RegisterNetEvent(E.RouteActive)
    AddEventHandler(E.RouteActive, Route.ActivateRoute)
    
    RegisterNetEvent(E.RouteDeactive)
    AddEventHandler(E.RouteDeactive, Route.DeactivateRoute)
    ]]
end